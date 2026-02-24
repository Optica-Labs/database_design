import os
from dotenv import load_dotenv
import psycopg2

# Load environment variables from .env file
load_dotenv()

SUPABASE_HOST = os.getenv('SUPABASE_HOST')
SUPABASE_PORT = os.getenv('SUPABASE_PORT', '5432')
SUPABASE_DB = os.getenv('SUPABASE_DB')
SUPABASE_USER = os.getenv('SUPABASE_USER')
SUPABASE_PASSWORD = os.getenv('SUPABASE_PASSWORD')
SCHEMA_PATH = os.getenv('SCHEMA_PATH', 'sql/schemas/schema.sql')

if not all([SUPABASE_HOST, SUPABASE_DB, SUPABASE_USER, SUPABASE_PASSWORD]):
    raise Exception("Missing required Supabase connection details in .env file.")

# Read schema SQL file
with open(SCHEMA_PATH, 'r') as f:
    schema_sql = f.read()

# Connect to Supabase PostgreSQL
conn = psycopg2.connect(
    host=SUPABASE_HOST,
    port=SUPABASE_PORT,
    dbname=SUPABASE_DB,
    user=SUPABASE_USER,
    password=SUPABASE_PASSWORD
)

try:
    with conn.cursor() as cur:
        cur.execute(schema_sql)
        conn.commit()
        print("Schema uploaded successfully.")
except Exception as e:
    print(f"Error uploading schema: {e}")
    conn.rollback()
finally:
    conn.close()
