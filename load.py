import os
import psycopg2
from dotenv import load_dotenv

# Load credentials from .env
load_dotenv()

# Redshift credentials
REDSHIFT_DB = os.getenv("REDSHIFT_DB")
REDSHIFT_USER = os.getenv("REDSHIFT_USER")
REDSHIFT_PASSWORD = os.getenv("REDSHIFT_PASSWORD")
REDSHIFT_HOST = os.getenv("REDSHIFT_HOST")
REDSHIFT_PORT = os.getenv("REDSHIFT_PORT", "5439")
IAM_ROLE_ARN = os.getenv("IAM_ROLE_ARN")
S3_BUCKET = os.getenv("S3_BUCKET_NAME", "prosper-etl-bucket")

# List of tables and S3 paths
TABLES = {
    "employees": f"s3://{S3_BUCKET}/transformed/employees.parquet",
    "customers": f"s3://{S3_BUCKET}/transformed/customers.parquet",
    "products": f"s3://{S3_BUCKET}/transformed/products.parquet",
    "stores": f"s3://{S3_BUCKET}/transformed/stores.parquet",
    "orders": f"s3://{S3_BUCKET}/transformed/orders.parquet",
    "order_items": f"s3://{S3_BUCKET}/transformed/order_items.parquet"
}

conn = None
try:
    # Connect to Redshift using environment variables
    conn = psycopg2.connect(
        host="my-redshift-workgroup.637423212398.ca-central-1.redshift-serverless.amazonaws.com",
        port=5439,
        dbname="dev",
        user=os.getenv("REDSHIFT_USER"),
        password=os.getenv("REDSHIFT_PASSWORD")
    )
    cursor = conn.cursor()

    # Load each file into its corresponding staging table
    for table, s3_path in TABLES.items():
        print(f"Loading {table} from {s3_path}")
        copy_command = f"""
            COPY {table}
            FROM '{s3_path}'
            IAM_ROLE '{IAM_ROLE_ARN}'
            FORMAT AS PARQUET;
        """
        try:
            cursor.execute(copy_command)
            conn.commit()
            print(f"Successfully loaded {table}.")
        except Exception as e:
            print(f"Error loading {table}: {e}")
            conn.rollback()

    cursor.close()
    print("All staging tables loaded into Redshift successfully.")

except Exception as ex:
    print(f"Database connection failed: {ex}")

finally:
    if conn:
        conn.close()