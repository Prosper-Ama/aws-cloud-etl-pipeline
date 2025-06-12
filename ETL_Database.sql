-- Check to see if data was loaded
SELECT * From customers;

-- MANUAL CLEANING BEFORE INSERTION TO FINAL TABLES

-- ADDING PRIMARY KEYS TO EACH TABLE
-- Employees table
ALTER TABLE employees
ADD CONSTRAINT pk_employees PRIMARY KEY ("Employee_ID");

-- Customers table
ALTER TABLE customers
ADD CONSTRAINT pk_customers PRIMARY KEY ("Customer_ID");

-- Products table
ALTER TABLE products
ADD CONSTRAINT pk_products PRIMARY KEY ("Product_ID");

-- Stores table
ALTER TABLE stores
ADD CONSTRAINT pk_stores PRIMARY KEY ("Store_ID");

-- Orders table
ALTER TABLE orders
ADD CONSTRAINT pk_orders PRIMARY KEY ("Order_ID");

-- Show duplicates to create composite key on order_item table
SELECT "Order_ID", "Product_ID", COUNT(*) AS duplicates
FROM order_items
GROUP BY "Order_ID", "Product_ID"
HAVING COUNT(*) > 1;

-- Remove duplicates but keep one occurrence
DELETE FROM order_items
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM order_items
    GROUP BY "Order_ID", "Product_ID"
);

-- Adding pk to Order Items table (composite primary key)
ALTER TABLE order_items
ADD CONSTRAINT pk_order_items PRIMARY KEY ("Order_ID", "Product_ID");



-- ADDING FOREIGN KEYS

-- 1. orders.Customer_ID → customers.Customer_ID
-- ALTER TABLE orders
-- ADD CONSTRAINT fk_orders_customers
-- FOREIGN KEY ("Customer_ID") REFERENCES customers("Customer_ID");
	 
-- 2. orders.Store_ID → stores.Store_ID
ALTER TABLE orders
ADD CONSTRAINT fk_orders_stores
FOREIGN KEY ("Store_ID") REFERENCES stores("Store_ID");

-- 3. employees.Store_ID → stores.Store_ID
ALTER TABLE employees
ADD CONSTRAINT fk_employees_stores
FOREIGN KEY ("Store_ID") REFERENCES stores("Store_ID");

-- 4. order_items.Order_ID → orders.Order_ID
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY ("Order_ID") REFERENCES orders("Order_ID");

-- 5. order_items.Product_ID → products.Product_ID
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY ("Product_ID") REFERENCES products("Product_ID");


-- CHANGE DATATYPES
-- Changing dates to dateframe
ALTER TABLE employees
ALTER COLUMN "Hire_Date" TYPE DATE
USING "Hire_Date"::DATE;

ALTER TABLE orders
ALTER COLUMN "Order_Date" TYPE DATE
USING "Order_Date"::DATE;

-- Changing address to VARCHAR
ALTER TABLE customers
ALTER COLUMN "Address" TYPE VARCHAR(255);

-- Changing Salary column to numeric for precision
ALTER TABLE employees
ALTER COLUMN "Salary" TYPE NUMERIC(10,2) USING "Salary"::NUMERIC;


-- CHECK FOR DUPLICATES
-- Customer table
SELECT "Customer_ID", COUNT(*)
FROM customers
GROUP BY "Customer_ID"
HAVING COUNT(*) > 1;

-- Employees table
SELECT "Employee_ID", COUNT(*)
FROM employees
GROUP BY "Employee_ID"
HAVING COUNT(*) > 1;

--Products table
SELECT "Product_ID", COUNT(*)
FROM products
GROUP BY "Product_ID"
HAVING COUNT(*) > 1;

-- Stores table
SELECT "Store_ID", COUNT(*)
FROM stores
GROUP BY "Store_ID"
HAVING COUNT(*) > 1;

--Orders table
SELECT "Order_ID", COUNT(*)
FROM orders
GROUP BY "Order_ID"
HAVING COUNT(*) > 1;

-- Order_Items table (Composite Key: Order_ID + Product_ID)
SELECT "Order_ID", "Product_ID", COUNT(*)
FROM order_items
GROUP BY "Order_ID", "Product_ID"
HAVING COUNT(*) > 1;

-- FINAL TABLES CREATION
-- Customers
CREATE TABLE final_customers (
    "Customer_ID" BIGINT PRIMARY KEY,
    "Full_Name" VARCHAR(100),
    "Email" VARCHAR(100),
    "Phone" VARCHAR(20),
    "Address" VARCHAR(255),
    "City" VARCHAR(50)
);

-- Employees
CREATE TABLE final_employees (
    "Employee_ID" BIGINT PRIMARY KEY,
    "Full_Name" VARCHAR(100),
    "Email" VARCHAR(100),
    "Phone" VARCHAR(20),
    "Job_Title" VARCHAR(50),
    "Salary" DOUBLE PRECISION,
	"Hire_Date" DATE,
    "Store_ID" BIGINT,
    FOREIGN KEY ("Store_ID") REFERENCES final_stores("Store_ID")
);

-- Products
CREATE TABLE final_products (
    "Product_ID" BIGINT PRIMARY KEY,
    "Name" VARCHAR(100),
    "Category" VARCHAR(50),
    "Price" DOUBLE PRECISION,
	"Stock_Quantity" BIGINT
);

-- Stores
CREATE TABLE final_stores (
    "Store_ID" BIGINT PRIMARY KEY,
    "Store_Name" VARCHAR(100),
    "City" VARCHAR(50),
    "State" VARCHAR(50),
	"Country" VARCHAR(50)
);

-- Orders
CREATE TABLE final_orders (
    "Order_ID" BIGINT PRIMARY KEY,
    "Customer_ID" BIGINT,
    "Store_ID" BIGINT,
    "Order_Date" DATE,
	"Total_Amount" DOUBLE PRECISION, 
    FOREIGN KEY ("Customer_ID") REFERENCES final_customers("Customer_ID"),
    FOREIGN KEY ("Store_ID") REFERENCES final_stores("Store_ID")
);

-- Order Items
CREATE TABLE final_order_items (
    "Order_ID" BIGINT,
    "Product_ID" BIGINT,
    "Quantity" INT,
    "Unit_Price" DOUBLE PRECISION,
    FOREIGN KEY ("Order_ID") REFERENCES final_orders("Order_ID"),
    FOREIGN KEY ("Product_ID") REFERENCES final_products("Product_ID")
);

-- INSERT ALREADY CLEANED DATA TO FINAL TABLES
-- Insert into Stores first (no dependencies)
INSERT INTO final_stores ("Store_ID", "Store_Name", "City", "State", "Country")
SELECT "Store_ID", "Store_Name", "City", "State", "Country"
FROM stores;

select * from orders

-- Insert into Customers
INSERT INTO final_customers ("Customer_ID", "Email", "Phone", "Address", "City", "Full_Name")
SELECT 
    "Customer_ID", 
    "Email",
    "Phone",
    "Address",
    "City",
	"Full_Name"
FROM customers;

-- Insert into Employees
INSERT INTO final_employees ("Employee_ID", "Full_Name", "Email", "Phone", "Job_Title", "Salary", "Hire_Date", "Store_ID")
SELECT 
    "Employee_ID",
    "Full_Name",
    "Email",
    "Phone",
    "Job_Title",
    "Salary",
	"Hire_Date",
    "Store_ID"
FROM employees;

-- Insert into Products
INSERT INTO final_products ("Product_ID", "Name", "Category", "Price", "Stock_Quantity")
SELECT 
    "Product_ID", 
    "Name", 
    "Category", 
    "Price",
	"Stock_Quantity"
FROM products;

-- Check for FK constraints
SELECT DISTINCT "Customer_ID"
FROM orders
WHERE "Customer_ID" NOT IN (SELECT "Customer_ID" FROM final_customers);

SELECT DISTINCT "Store_ID"
FROM orders
WHERE "Store_ID" NOT IN (SELECT "Store_ID" FROM final_customers);

-- Fix Fk contraints
-- Add Is_Placeholder columns
ALTER TABLE final_customers
    ADD COLUMN IF NOT EXISTS "Is_Placeholder" BOOLEAN DEFAULT FALSE;

ALTER TABLE final_stores
    ADD COLUMN IF NOT EXISTS "Is_Placeholder" BOOLEAN DEFAULT FALSE;

-- Insert missing customers with placeholders
INSERT INTO final_customers (
    "Customer_ID", "Full_Name", "Email", "Phone", "Address", "City", "Is_Placeholder"
)
SELECT DISTINCT
    o."Customer_ID",
    'Unknown Name',
    CONCAT('user', o."Customer_ID", '@example.com'),
    '000-000-0000',
    'Unknown Address',
    'Unknown City',
    TRUE
FROM orders o
WHERE o."Customer_ID" NOT IN (
    SELECT "Customer_ID" FROM final_customers
);

-- Insert missing stores with placeholders
INSERT INTO final_stores (
    "Store_ID", "Store_Name", "City", "State", "Country", "Is_Placeholder"
)
SELECT DISTINCT
    o."Store_ID",
    'Unknown Store',
    'Unknown City',
    'Unknown State',
    'Unknown Country',
    TRUE
FROM orders o
WHERE o."Store_ID" IS NOT NULL
  AND o."Store_ID" NOT IN (
      SELECT "Store_ID" FROM final_stores
  );

-- Insert into Orders
INSERT INTO final_orders ("Order_ID", "Customer_ID", "Store_ID", "Order_Date", "Total_Amount")
SELECT 
    "Order_ID", 
    "Customer_ID", 
    "Store_ID", 
    "Order_Date",
	"Total_Amount"
FROM orders;

-- Insert into Order Items
INSERT INTO final_order_items ("Order_ID", "Product_ID", "Quantity", "Unit_Price")
SELECT 
    "Order_ID", 
    "Product_ID", 
    "Quantity", 
    "Unit_Price" 
FROM order_items;

-- Check for successful insertion
SELECT COUNT(*) FROM final_customers;
SELECT COUNT(*) FROM final_employees;
SELECT COUNT(*) FROM final_orders;
SELECT COUNT(*) FROM final_order_items;


-- DATA MARTS
-- We’ll use views for simplicity as they always reflect the latest data
-- Sales Per Store
CREATE VIEW v_sales_per_store AS
SELECT 
    s."Store_ID",
    s."Store_Name",
    SUM(o."Total_Amount") AS total_sales
FROM final_orders o
JOIN final_stores s ON o."Store_ID" = s."Store_ID"
GROUP BY s."Store_ID", s."Store_Name";


-- Top 4 Products Based on Quantity Sold
CREATE VIEW v_top_products_by_quantity AS
SELECT 
    p."Product_ID",
    p."Name",
    SUM(oi."Quantity") AS total_quantity
FROM final_order_items oi
JOIN final_products p ON oi."Product_ID" = p."Product_ID"
GROUP BY p."Product_ID", p."Name"
ORDER BY total_quantity DESC
LIMIT 4;

-- Employee Count Per Store
CREATE VIEW v_employee_count_per_store AS
SELECT 
    s."Store_ID",
    s."Store_Name",
    COUNT(e."Employee_ID") AS employee_count
FROM final_employees e
JOIN final_stores s ON e."Store_ID" = s."Store_ID"
GROUP BY s."Store_ID", s."Store_Name";


-- Revenue Per City
CREATE VIEW v_revenue_per_city AS
SELECT 
    c."City",
    SUM(o."Total_Amount") AS total_revenue
FROM final_orders o
JOIN final_customers c ON o."Customer_ID" = c."Customer_ID"
GROUP BY c."City"
ORDER BY total_revenue DESC;

	
-- Using the views
SELECT * FROM v_employee_count_per_store;

SELECT * FROM v_revenue_per_city;

SELECT * FROM v_sales_per_store;

SELECT * FROM v_top_products_by_quantity;
	