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

if not all([SUPABASE_HOST, SUPABASE_DB, SUPABASE_USER, SUPABASE_PASSWORD]):
    raise Exception("Missing required Supabase connection details in .env file.")

try:
    conn = psycopg2.connect(
        host=SUPABASE_HOST,
        port=SUPABASE_PORT,
        dbname=SUPABASE_DB,
        user=SUPABASE_USER,
        password=SUPABASE_PASSWORD,
        connect_timeout=10
    )
    with conn.cursor() as cur:
        cur.execute("SELECT NOW();")
        result = cur.fetchone()
        print(f"Connection successful. Current time: {result[0]}")
    conn.close()
except Exception as e:
    print(f"Connection failed: {e}")
