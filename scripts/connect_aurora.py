#!/usr/bin/env python3
"""Fetch DB credentials from AWS Secrets Manager and connect to an Aurora Postgres cluster.

Usage examples:
  python3 scripts/connect_aurora.py --secret-arn <SECRET_ARN> --profile Lexi --query "SELECT now();"
  python3 scripts/connect_aurora.py --host my-host --user postgres --password secret --query "SELECT 1;"
"""
import argparse
import json
import sys
import boto3
from botocore.exceptions import ClientError, BotoCoreError
import psycopg2


def get_secret(session, secret_id):
    client = session.client("secretsmanager")
    try:
        resp = client.get_secret_value(SecretId=secret_id)
    except (ClientError, BotoCoreError) as e:
        raise

    if "SecretString" in resp and resp["SecretString"]:
        try:
            return json.loads(resp["SecretString"])
        except json.JSONDecodeError:
            return resp["SecretString"]
    else:
        # SecretBinary
        import base64

        decoded = base64.b64decode(resp["SecretBinary"])
        try:
            return json.loads(decoded)
        except json.JSONDecodeError:
            return decoded


def build_conn_params(args, secret):
    params = {}
    # Priority: explicit CLI args > secret fields
    params["host"] = args.host or secret.get("host") or secret.get("hostname")
    params["port"] = args.port or secret.get("port") or 5432
    params["dbname"] = args.dbname or secret.get("dbname") or secret.get("database") or "postgres"
    params["user"] = args.user or secret.get("username") or secret.get("user")
    params["password"] = args.password or secret.get("password")
    return params


def main():
    p = argparse.ArgumentParser(description="Connect to Aurora Postgres using AWS Secrets Manager and boto3")
    p.add_argument("--secret-arn", help="Secrets Manager secret ARN (JSON expected with username/password/host/dbname)")
    p.add_argument("--profile", help="AWS CLI profile name to use (optional)")
    p.add_argument("--host", help="DB host (overrides secret)")
    p.add_argument("--port", type=int, help="DB port (overrides secret)")
    p.add_argument("--dbname", help="Database name (overrides secret)")
    p.add_argument("--user", help="DB user (overrides secret)")
    p.add_argument("--password", help="DB password (overrides secret)")
    p.add_argument("--sslrootcert", help="Path to SSL root cert file (optional)")
    p.add_argument("--query", default="SELECT version();", help="SQL query to run")
    args = p.parse_args()


    if args.profile:
        session = boto3.Session(profile_name=args.profile)
    else:
        session = boto3.Session()

    # Check credentials before proceeding
    sts = session.client("sts")
    try:
        ident = sts.get_caller_identity()
        print(f"AWS identity: {ident.get('Arn', ident)}")
    except Exception as e:
        print("AWS credentials not found or invalid. Please run 'aws configure' or 'aws sso login'.", file=sys.stderr)
        sys.exit(10)

    secret = {}
    if args.secret_arn:
        try:
            secret = get_secret(session, args.secret_arn)
        except Exception as e:
            print("Failed to retrieve secret:", e, file=sys.stderr)
            sys.exit(2)

    conn_params = build_conn_params(args, secret if isinstance(secret, dict) else {})

    if not conn_params.get("host"):
        print("No DB host provided (via --host or secret).", file=sys.stderr)
        sys.exit(3)
    if not conn_params.get("user") or not conn_params.get("password"):
        print("Missing user or password (provide via --user/--password or store them in the secret).", file=sys.stderr)
        sys.exit(4)

    dsn = {
        "host": conn_params["host"],
        "port": conn_params["port"],
        "dbname": conn_params["dbname"],
        "user": conn_params["user"],
        "password": conn_params["password"],
    }

    if args.sslrootcert:
        dsn["sslmode"] = "verify-full"
        dsn["sslrootcert"] = args.sslrootcert
    else:
        dsn["sslmode"] = "require"

    try:
        conn = psycopg2.connect(**dsn)
    except Exception as e:
        print("Failed to connect to DB:", e, file=sys.stderr)
        sys.exit(5)

    try:
        cur = conn.cursor()
        cur.execute(args.query)
        rows = cur.fetchall()
        for r in rows:
            print(r)
        cur.close()
    finally:
        conn.close()


if __name__ == "__main__":
    main()
