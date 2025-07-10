import os
import boto3
from dotenv import load_dotenv
from botocore.exceptions import NoCredentialsError

# Load .env
load_dotenv()

# Environment Variables
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = os.getenv('AWS_REGION')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')

# Initialize S3 client
s3 = boto3.client('s3',
                  region_name=AWS_REGION,
                  aws_access_key_id=AWS_ACCESS_KEY_ID,
                  aws_secret_access_key=AWS_SECRET_ACCESS_KEY)

def upload_files(local_folder, s3_prefix="raw/"):
    for file_name in os.listdir(local_folder):
        file_path = os.path.join(local_folder, file_name)
        if os.path.isfile(file_path):
            try:
                s3.upload_file(file_path, S3_BUCKET_NAME, f"{s3_prefix}{file_name}")
                print(f"Uploaded: {file_name} → s3://{S3_BUCKET_NAME}/{s3_prefix}{file_name}")
            except FileNotFoundError:
                print(f"File not found: {file_path}")
            except NoCredentialsError:
                print("AWS credentials not found.")
            except Exception as e:
                print(f"Error uploading {file_name}: {e}")

if __name__ == "__main__":
    upload_files("data")
