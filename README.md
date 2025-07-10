# 📊 AWS Cloud-Based ETL Pipeline

A complete serverless ETL (Extract, Transform, Load) pipeline built using **AWS Lambda**, **S3**, and **Amazon Redshift**, provisioned with **Terraform** and powered by **Python**.

---

## Project Structure
```bash
ETL_Design/
├── data/ # Local test data files (CSV, JSON)
├── infrastructure/ # Terraform infrastructure as code
│ ├── redshift.tf
│ ├── lambda.tf
│ ├── s3.tf
│ ├── iam.tf
│ ├── stepfunctions.tf
│ ├── outputs.tf
│ ├── vars.tf
│ └── providers.tf
├── lambda_functions/ # Lambda transformation logic
│ ├── functions.py
│ ├── Dockerfile
│ ├── build_and_push.sh
│ └── requirements.txt
├── move_data_to_s3.py # Uploads raw files to S3
├── load.py # Loads transformed files into Redshift staging
├── create_staging_tables.sql # SQL for Redshift staging tables
├── create_final_tables.sql # SQL for Redshift final tables and views
├── execute_staging_sql.py # Executes staging DDL
├── execute_final_sql.py # Executes final DDL and view logic
├── .env # Stores environment variables (excluded from Git)
├── .gitignore # Git ignore config
└── README.md
```

## What It Does

1. **Extract** raw data from CSV and JSON in the `data/` folder
2. **Transform** using AWS Lambda (cleaning, merging, validation, enrichment)
3. **Load** transformed `.parquet` files into Amazon Redshift staging tables
4. **Insert** cleaned data into final tables with foreign key resolution
5. **Create** views (data marts) for analytics

---

## Technologies Used

- **AWS S3** – Storage for raw and transformed data
- **AWS Lambda (Dockerized)** – ETL logic execution
- **Amazon Redshift Serverless** – Data warehouse
- **Terraform** – Infrastructure provisioning
- **Python (pandas, boto3)** – Data transformation and orchestration
- **Parquet** – Efficient data format for Redshift Spectrum

---

## Views Created

- `v_sales_per_store` – Total sales per store  
- `v_top_products_by_quantity` – Top 4 most-sold products  
- `v_employee_count_per_store` – Employee distribution per store  
- `v_revenue_per_city` – Total revenue by customer city  

---

## How to Run Locally

1. **Upload raw data to S3**  
   ```bash
   python move_data_to_s3.py
   
2. **Run Lambda ETL (triggered by AWS Step Functions or manually)3**  
   
3. **Load transformed data into Redshift from the root directory**  
   ```bash
   python load.py

4. **Create staging/final tables and views from the root directory**  
   ```bash
   python execute_staging_sql.py 
   python execute_final_sql.py

## Environment Variables (.env)
- ⚠️ Add this file to `.gitignore` to keep credentials secure.

## Git Ignore (.gitignore)
```bash
.env
*.parquet
__pycache__/
.terraform/
.DS_Store
*.zip
```
## Terraform Usage
```bash
cd infrastructure/
terraform init
terraform apply
```
Make sure your AWS CLI is authenticated (aws configure)

## Author
Prosper Amamgbo

Data Engineer

https://github.com/Prosper-Ama



   
