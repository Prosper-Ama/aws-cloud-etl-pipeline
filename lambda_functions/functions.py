import boto3
import pandas as pd
import os
import io
import json
import re

def is_valid_email(email):
    if not isinstance(email, str):
        return False
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(pattern, email))

def is_valid_phone(phone):
    if not isinstance(phone, str):
        return False
    pattern = r"^\+?\d{10,15}$"
    return bool(re.match(pattern, phone))

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket = os.environ.get('S3_BUCKET_NAME', 'prosper-etl-bucket')

    def read_csv(key):
        try:
            response = s3.get_object(Bucket=bucket, Key=f'raw/{key}')
            return pd.read_csv(io.BytesIO(response['Body'].read()))
        except Exception as e:
            print(f"Error reading {key}: {e}")
            return pd.DataFrame()

    # --- Extract ---
    df_employees = read_csv("employees.csv")
    df_customers = read_csv("customers.csv")
    df_products = read_csv("products.csv")
    df_stores = read_csv("stores.csv")

    # Extract orders JSON
    try:
        orders_resp = s3.get_object(Bucket=bucket, Key='raw/orders.json')
        orders_data = json.loads(orders_resp['Body'].read())
    except Exception as e:
        print(f"Error reading orders.json: {e}")
        orders_data = []

    # --- Basic Cleaning ---
    for df in [df_employees, df_customers, df_products, df_stores]:
        if not df.empty:
            str_cols = df.select_dtypes(include='object').columns
            df[str_cols] = df[str_cols].fillna("unknown")
            df.drop_duplicates(inplace=True)

    # --- Employees and Customers ---
    for df in [df_employees, df_customers]:
        if not df.empty:
            # Merge names
            df["Full_Name"] = df.get("First_Name", "").fillna("") + " " + df.get("Last_Name", "").fillna("")
            df.drop(columns=["First_Name", "Last_Name"], inplace=True, errors='ignore')

            # Ensure Email and Phone columns exist
            if "Email" not in df.columns:
                df["Email"] = "unknown"
            if "Phone" not in df.columns:
                df["Phone"] = "unknown"

            # Validate and truncate
            df["Email"] = df["Email"].apply(lambda x: x if is_valid_email(x) else "unknown")
            df["Phone"] = df["Phone"].apply(lambda x: x if is_valid_phone(x) else "unknown")
            df["Phone"] = df["Phone"].astype(str).str[:20]  # truncate to match Redshift schema

    # --- Orders Split ---
    orders_list, order_items_list = [], []
    for order in orders_data:
        orders_list.append([
            order.get("Order_ID"), order.get("Customer_ID"),
            order.get("Store_ID"), order.get("Order_Date"), order.get("Total_Amount")
        ])
        for item in order.get("Items", []):
            order_items_list.append([
                order.get("Order_ID"), item.get("Product_ID"),
                item.get("Quantity"), item.get("Unit_Price")
            ])

    df_orders = pd.DataFrame(orders_list, columns=["Order_ID", "Customer_ID", "Store_ID", "Order_Date", "Total_Amount"])
    df_order_items = pd.DataFrame(order_items_list, columns=["Order_ID", "Product_ID", "Quantity", "Unit_Price"])

    # --- Schema Alignment ---

    # Employees
    if not df_employees.empty:
        df_employees["Salary"] = pd.to_numeric(df_employees["Salary"], errors="coerce").fillna(0.0)
        df_employees["Hire_Date"] = pd.to_datetime(df_employees["Hire_Date"], errors='coerce')
        df_employees = df_employees.astype({
            "Employee_ID": "int64",
            "Full_Name": "str",
            "Email": "str",
            "Phone": "str",
            "Job_Title": "str",
            "Salary": "float64",
            "Store_ID": "int64"
        })
        df_employees = df_employees[["Employee_ID", "Full_Name", "Email", "Phone", "Job_Title", "Salary", "Hire_Date", "Store_ID"]]

    # Customers
    if not df_customers.empty:
        df_customers = df_customers.astype({
            "Customer_ID": "int64",
            "Full_Name": "str",
            "Email": "str",
            "Phone": "str",
            "Address": "str",
            "City": "str"
        })
        df_customers = df_customers[["Customer_ID", "Full_Name", "Email", "Phone", "Address", "City"]]

    # Products
    if not df_products.empty:
        df_products["Price"] = pd.to_numeric(df_products["Price"], errors="coerce").fillna(0.0)
        df_products["Stock_Quantity"] = pd.to_numeric(df_products["Stock_Quantity"], errors="coerce").fillna(0).astype("int64")

    # Stores
    if not df_stores.empty:
        df_stores["Store_ID"] = pd.to_numeric(df_stores["Store_ID"], errors="coerce").fillna(0).astype("int64")
        df_stores = df_stores.astype({
            "Store_Name": "str", "City": "str", "State": "str", "Country": "str"
        })
        df_stores = df_stores[["Store_ID", "Store_Name", "City", "State", "Country"]]
        
    # Orders
    if not df_orders.empty:
        df_orders["Order_Date"] = pd.to_datetime(df_orders["Order_Date"], errors='coerce')
        df_orders["Total_Amount"] = pd.to_numeric(df_orders["Total_Amount"], errors='coerce').fillna(0.0)

    # Order Items
    if not df_order_items.empty:
        df_order_items["Quantity"] = pd.to_numeric(df_order_items["Quantity"], errors="coerce").fillna(0).astype("int64")
        df_order_items["Unit_Price"] = pd.to_numeric(df_order_items["Unit_Price"], errors="coerce").fillna(0.0)

    # --- Save as Parquet and Upload to S3 ---
    dfs = {
        "employees": df_employees,
        "customers": df_customers,
        "products": df_products,
        "stores": df_stores,
        "orders": df_orders,
        "order_items": df_order_items
    }

    for name, df in dfs.items():
        if not df.empty:
            buffer = io.BytesIO()
            df.to_parquet(buffer, index=False)
            buffer.seek(0)
            s3.put_object(Bucket=bucket, Key=f'transformed/{name}.parquet', Body=buffer.getvalue())

    return {"status": "success", "tables": list(dfs.keys())}
