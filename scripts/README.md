# Aurora connection helper

This folder contains a small helper script to retrieve DB credentials from AWS Secrets Manager and connect to an Aurora Postgres cluster.

Usage

Install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Run (example using AWS profile `Lexi`):

```bash
python3 scripts/connect_aurora.py \
  --secret-arn arn:aws:secretsmanager:eu-west-1:619564767671:secret:rds!cluster-34a76e81-8fe9-4ec6-a65f-98a9d08e76bc-0sacoH \
  --profile Lexi \
  --sslrootcert /certs/global-bundle.pem \
  --query "SELECT NOW();"
```

Or provide connection fields directly:

```bash
python3 scripts/connect_aurora.py --host my-host --user postgres --password secret --query "SELECT 1;"
```

Notes

- If using SSO or temporary credentials, run `aws sso login --profile <profile>` or ensure `AWS_SESSION_TOKEN` is present.
- The script prefers CLI args over values stored in the secret.
