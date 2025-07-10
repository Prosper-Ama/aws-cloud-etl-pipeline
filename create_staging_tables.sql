DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;

CREATE TABLE IF NOT EXISTS employees (
    "Employee_ID" BIGINT,
    "Full_Name" VARCHAR(100),
    "Email" VARCHAR(100),
    "Phone" VARCHAR(30),
    "Job_Title" VARCHAR(50),
    "Salary" DOUBLE PRECISION,
    "Hire_Date" DATE,
    "Store_ID" BIGINT
);

CREATE TABLE IF NOT EXISTS customers (
    "Customer_ID" BIGINT,
    "Full_Name" VARCHAR(100),
    "Email" VARCHAR(100),
    "Phone" VARCHAR(30),
    "Address" VARCHAR(255),
    "City" VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
    "Product_ID" BIGINT,
    "Name" VARCHAR(100),
    "Category" VARCHAR(50),
    "Price" DOUBLE PRECISION,
    "Stock_Quantity" BIGINT
);

CREATE TABLE IF NOT EXISTS stores (
    "Store_ID" BIGINT,
    "Store_Name" VARCHAR(100),
    "City" VARCHAR(50),
    "State" VARCHAR(50),
    "Country" VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS orders (
    "Order_ID" BIGINT,
    "Customer_ID" BIGINT,
    "Store_ID" BIGINT,
    "Order_Date" DATE,
    "Total_Amount" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS order_items (
    "Order_ID" BIGINT,
    "Product_ID" BIGINT,
    "Quantity" BIGINT,
    "Unit_Price" DOUBLE PRECISION
);