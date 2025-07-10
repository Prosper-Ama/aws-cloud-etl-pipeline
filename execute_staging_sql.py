import psycopg2
import os
from dotenv import load_dotenv

# Load credentials from .env
load_dotenv()

# Load credentials from environment
REDSHIFT_HOST = os.getenv("REDSHIFT_HOST", "my-redshift-workgroup.637423212398.ca-central-1.redshift-serverless.amazonaws.com")
REDSHIFT_PORT = os.getenv("REDSHIFT_PORT", "5439")
REDSHIFT_DATABASE = os.getenv("REDSHIFT_DATABASE", "dev")
REDSHIFT_USER = os.getenv("REDSHIFT_USER", "admin")
REDSHIFT_PASSWORD = os.getenv("REDSHIFT_PASSWORD")

SQL_FILE_PATH = "/Users/mac/Documents/Prosper_Python/ETL_Design/create_staging_tables.sql"

def load_sql_file(filepath):
    with open(filepath, "r") as f:
        return f.read()

def execute_sql_from_file(filepath, connection):
    sql_commands = load_sql_file(filepath)
    # Split commands in case the file contains multiple statements separated by ';'
    commands = [cmd for cmd in sql_commands.split(';') if cmd.strip()]
    
    cursor = connection.cursor()
    try:
        for command in commands:
            cursor.execute(command)
        connection.commit()
        print("SQL from file executed successfully.")
    except Exception as e:
        print("Error executing SQL:")
        print(e)
        connection.rollback()
    finally:
        cursor.close()

def main():
    conn = None
    try:
        print("Connecting to Redshift...")
        conn = psycopg2.connect(
            host="my-redshift-workgroup.637423212398.ca-central-1.redshift-serverless.amazonaws.com",
            port=5439,
            dbname="dev",
            user=os.getenv("REDSHIFT_USER"),
            password=os.getenv("REDSHIFT_PASSWORD")
        )
        print("Connection successful.")
        
        print("Executing SQL from file...")
        execute_sql_from_file(SQL_FILE_PATH, conn)

    except Exception as ex:
        print(f"Failed to connect or run SQL: {ex}")
        
    finally:
        if conn:
            conn.close()
            print("Connection closed.")

if __name__ == "__main__":
    main()