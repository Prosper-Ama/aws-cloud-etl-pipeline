-- STEP 1: FINAL TABLES

CREATE TABLE IF NOT EXISTS final_customers (
    "Customer_ID" BIGINT PRIMARY KEY,
    "Full_Name" VARCHAR(100),
    "Email" VARCHAR(100),
    "Phone" VARCHAR(20),
    "Address" VARCHAR(255),
    "City" VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS final_stores (
    "Store_ID" BIGINT PRIMARY KEY,
    "Store_Name" VARCHAR(100),
    "City" VARCHAR(50),
    "State" VARCHAR(50),
    "Country" VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS final_employees (
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

CREATE TABLE IF NOT EXISTS final_products (
    "Product_ID" BIGINT PRIMARY KEY,
    "Name" VARCHAR(100),
    "Category" VARCHAR(50),
    "Price" DOUBLE PRECISION,
    "Stock_Quantity" BIGINT
);

CREATE TABLE IF NOT EXISTS final_orders (
    "Order_ID" BIGINT PRIMARY KEY,
    "Customer_ID" BIGINT,
    "Store_ID" BIGINT,
    "Order_Date" DATE,
    "Total_Amount" DOUBLE PRECISION,
    FOREIGN KEY ("Customer_ID") REFERENCES final_customers("Customer_ID"),
    FOREIGN KEY ("Store_ID") REFERENCES final_stores("Store_ID")
);

CREATE TABLE IF NOT EXISTS final_order_items (
    "Order_ID" BIGINT,
    "Product_ID" BIGINT,
    "Quantity" INT,
    "Unit_Price" DOUBLE PRECISION,
    FOREIGN KEY ("Order_ID") REFERENCES final_orders("Order_ID"),
    FOREIGN KEY ("Product_ID") REFERENCES final_products("Product_ID")
);


-- Redshift doesn't support IF NOT EXISTS with ADD COLUMN
ALTER TABLE final_customers ADD COLUMN "Is_Placeholder" BOOLEAN DEFAULT FALSE;
ALTER TABLE final_stores ADD COLUMN "Is_Placeholder" BOOLEAN DEFAULT FALSE;


-- Insert final stores (deduplicated)
INSERT INTO final_stores ("Store_ID", "Store_Name", "City", "State", "Country")
SELECT DISTINCT "Store_ID", "Store_Name", "City", "State", "Country"
FROM stores
WHERE "Store_ID" IS NOT NULL
  AND "Store_ID" NOT IN (SELECT "Store_ID" FROM final_stores);

-- Insert final customers
INSERT INTO final_customers ("Customer_ID", "Full_Name", "Email", "Phone", "Address", "City")
SELECT DISTINCT "Customer_ID", "Full_Name", "Email", "Phone", "Address", "City"
FROM customers
WHERE "Customer_ID" IS NOT NULL
  AND "Customer_ID" NOT IN (SELECT "Customer_ID" FROM final_customers);

-- Insert final products
INSERT INTO final_products ("Product_ID", "Name", "Category", "Price", "Stock_Quantity")
SELECT DISTINCT "Product_ID", "Name", "Category", "Price", "Stock_Quantity"
FROM products
WHERE "Product_ID" IS NOT NULL
  AND "Product_ID" NOT IN (SELECT "Product_ID" FROM final_products);

-- Insert missing stores (for broken FK in employees)
INSERT INTO final_stores ("Store_ID", "Store_Name", "City", "State", "Country", "Is_Placeholder")
SELECT DISTINCT "Store_ID", 'Unknown', 'Unknown', 'Unknown', 'Unknown', TRUE
FROM employees
WHERE "Store_ID" IS NOT NULL
  AND "Store_ID" NOT IN (SELECT "Store_ID" FROM final_stores);

-- Insert final employees
INSERT INTO final_employees ("Employee_ID", "Full_Name", "Email", "Phone", "Job_Title", "Salary", "Hire_Date", "Store_ID")
SELECT DISTINCT "Employee_ID", "Full_Name", "Email", "Phone", "Job_Title", "Salary", "Hire_Date", "Store_ID"
FROM employees
WHERE "Employee_ID" IS NOT NULL
  AND "Employee_ID" NOT IN (SELECT "Employee_ID" FROM final_employees);

-- Insert missing customers or stores for orders
INSERT INTO final_customers ("Customer_ID", "Full_Name", "Email", "Phone", "Address", "City", "Is_Placeholder")
SELECT DISTINCT "Customer_ID", 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', TRUE
FROM orders
WHERE "Customer_ID" IS NOT NULL
  AND "Customer_ID" NOT IN (SELECT "Customer_ID" FROM final_customers);

INSERT INTO final_stores ("Store_ID", "Store_Name", "City", "State", "Country", "Is_Placeholder")
SELECT DISTINCT "Store_ID", 'Unknown', 'Unknown', 'Unknown', 'Unknown', TRUE
FROM orders
WHERE "Store_ID" IS NOT NULL
  AND "Store_ID" NOT IN (SELECT "Store_ID" FROM final_stores);

-- Insert final orders
INSERT INTO final_orders ("Order_ID", "Customer_ID", "Store_ID", "Order_Date", "Total_Amount")
SELECT DISTINCT "Order_ID", "Customer_ID", "Store_ID", "Order_Date", "Total_Amount"
FROM orders
WHERE "Order_ID" IS NOT NULL
  AND "Order_ID" NOT IN (SELECT "Order_ID" FROM final_orders);

-- Insert missing products for order_items
INSERT INTO final_products ("Product_ID", "Name", "Category", "Price", "Stock_Quantity")
SELECT DISTINCT "Product_ID", 'Unknown', 'Unknown', 0.0, 0
FROM order_items
WHERE "Product_ID" IS NOT NULL
  AND "Product_ID" NOT IN (SELECT "Product_ID" FROM final_products);

-- Insert final order items
INSERT INTO final_order_items ("Order_ID", "Product_ID", "Quantity", "Unit_Price")
SELECT DISTINCT "Order_ID", "Product_ID", "Quantity", "Unit_Price"
FROM order_items
WHERE ("Order_ID", "Product_ID") NOT IN (
    SELECT "Order_ID", "Product_ID" FROM final_order_items
);


-- STEP 3: DATA MART VIEWS

CREATE OR REPLACE VIEW v_sales_per_store AS
SELECT s."Store_ID", s."Store_Name", SUM(o."Total_Amount") AS total_sales
FROM final_orders o
JOIN final_stores s ON o."Store_ID" = s."Store_ID"
GROUP BY s."Store_ID", s."Store_Name";

CREATE OR REPLACE VIEW v_top_products_by_quantity AS
SELECT p."Product_ID", p."Name", SUM(oi."Quantity") AS total_quantity
FROM final_order_items oi
JOIN final_products p ON oi."Product_ID" = p."Product_ID"
GROUP BY p."Product_ID", p."Name"
ORDER BY total_quantity DESC
LIMIT 4;

CREATE OR REPLACE VIEW v_employee_count_per_store AS
SELECT s."Store_ID", s."Store_Name", COUNT(e."Employee_ID") AS employee_count
FROM final_employees e
JOIN final_stores s ON e."Store_ID" = s."Store_ID"
GROUP BY s."Store_ID", s."Store_Name";

CREATE OR REPLACE VIEW v_revenue_per_city AS
SELECT c."City", SUM(o."Total_Amount") AS total_revenue
FROM final_orders o
JOIN final_customers c ON o."Customer_ID" = c."Customer_ID"
GROUP BY c."City"
ORDER BY total_revenue DESC;
