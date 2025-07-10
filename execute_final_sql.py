import os
import psycopg2
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

REDSHIFT_HOST = os.getenv("REDSHIFT_HOST")
REDSHIFT_PORT = os.getenv("REDSHIFT_PORT", "5439")
REDSHIFT_DB = os.getenv("REDSHIFT_DB", "dev")
REDSHIFT_USER = os.getenv("REDSHIFT_USER")
REDSHIFT_PASSWORD = os.getenv("REDSHIFT_PASSWORD")

SQL_FILE_PATH = "/Users/mac/Documents/Prosper_Python/ETL_Design/create_final_tables.sql"  

# Connect and run SQL file
def run_sql_file(file_path):
    try:
        with open(file_path, "r") as f:
            sql = f.read()

        conn = psycopg2.connect(
            host="my-redshift-workgroup.637423212398.ca-central-1.redshift-serverless.amazonaws.com",
            port=5439,
            dbname="dev",
            user=os.getenv("REDSHIFT_USER"),
            password=os.getenv("REDSHIFT_PASSWORD")
        )
        cursor = conn.cursor()
        cursor.execute(sql)
        conn.commit()
        cursor.close()
        conn.close()
        print("Final tables and views created successfully.")
    except Exception as e:
        print(f"Failed to run SQL file: {e}")

if __name__ == "__main__":
    run_sql_file(SQL_FILE_PATH)
