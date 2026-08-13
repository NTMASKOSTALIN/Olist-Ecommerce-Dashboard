#Creating database
CREATE DATABASE Ecom;

#using the DB
USE Ecom;

#Creating customers Table
CREATE TABLE customers (
customer_id VARCHAR(50) UNIQUE PRIMARY KEY,
customer_unique_id VARCHAR(50),
customer_zip_code VARCHAR(10),
customer_city VARCHAR(50),
customer_state VARCHAR(50));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_customers.csv' 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT* FROM customers;

-- Checking Tot rows
SELECT COUNT(*) AS Tot_row FROM customers;

-- DUPLICATES CHECK
-- Primary Key Validation (Verifying schema UNIQUE constraints held during ETL)
SELECT customer_id, COUNT(*) as occurrence_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate check for recurring shipping location pattern
SELECT customer_unique_id, customer_zip_code, customer_city, customer_state, COUNT(*) as occurrence_count
FROM customers
GROUP BY customer_unique_id, customer_zip_code, customer_city, customer_state
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- STANDARDIZATION 
-- Check for hidden leading/trailing spaces
SELECT customer_zip_code, customer_city, customer_state, COUNT(*) AS tot_lead_trail_spaces
FROM customers
WHERE customer_zip_code != TRIM(customer_zip_code) OR
	  customer_city != TRIM(customer_city) OR
	  customer_state != TRIM(customer_state)
GROUP BY customer_zip_code, customer_city, customer_state;

-- checking valid state
SELECT customer_state, COUNT(*) AS state_count
FROM customers
GROUP BY customer_state
HAVING state_count > 1
ORDER BY state_count ASC;

-- Unknown state check
SELECT DISTINCT customer_state
FROM customers
WHERE customer_state NOT IN ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS',
'MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO');

-- Checking customer city name error
SELECT customer_city, COUNT(*) AS city_count
FROM customers
GROUP BY customer_city
ORDER BY city_count DESC;

-- Checking for city name error
SELECT DISTINCT customer_city, COUNT(*) AS volume
FROM customers
WHERE customer_city REGEXP '[0-9!@#$%^&*()_+=\\[\\]{};:"\\|<>/?,]'
   OR customer_city REGEXP '[Ã©¶¼¿€™‡]'
GROUP BY customer_city
ORDER BY volume DESC;

-- upper case check
SELECT COUNT(*) AS uppercase
FROM customers
WHERE customer_city COLLATE utf8mb4_bin REGEXP '[A-Z]';

-- Zip code length consistency check
SELECT LENGTH(customer_zip_code) AS zip_length , COUNT(*) AS zip_code_length, 
CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(),2), '%') AS percentage
FROM customers
GROUP BY LENGTH(customer_zip_code);

-- ID Length consistency check
SELECT LENGTH(customer_id) AS customer_id_length, LENGTH(customer_unique_id) AS customer_unique_id_length, COUNT(*) AS error_volume
FROM customers
WHERE LENGTH(customer_id) != 32 
   OR LENGTH(customer_unique_id) != 32 
GROUP BY customer_id_length, customer_unique_id_length;

-- NULL/MISSING VALUES CHECK
SELECT SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id)='' THEN 1 ELSE 0 END) AS missing_customer_id,
SUM(CASE WHEN customer_unique_id IS NULL OR TRIM(customer_unique_id)='' THEN 1 ELSE 0 END) AS missing_customer_unique_id,
SUM(CASE WHEN customer_zip_code IS NULL OR TRIM(customer_zip_code)='' THEN 1 ELSE 0 END) AS missing_customer_zip_code,
SUM(CASE WHEN customer_city IS NULL OR TRIM(customer_city)='' THEN 1 ELSE 0 END) AS missing_customer_city,
SUM(CASE WHEN customer_state IS NULL OR TRIM(customer_state)='' THEN 1 ELSE 0 END) AS missing_customer_state
FROM customers;

-- LOGIC & SANITY CHECKS
-- Tot orders & Unique customers count check (verifying the unique customers must be less than orders)
SELECT COUNT(customer_id) AS tot_orders, COUNT(DISTINCT customer_unique_id) AS Unique_customers
FROM customers;

-- Checking Top 5 highest orders by State (Verifying does obvious top Brazil's cities get most orders)
SELECT customer_state,  COUNT(*) AS Tot_orders
FROM customers
GROUP BY customer_state
ORDER BY Tot_orders DESC LIMIT 5;

-- Impossible/Multiple customer location check
SELECT customer_unique_id, COUNT(DISTINCT customer_zip_code) AS zip_count, COUNT(DISTINCT customer_city) AS city_count,
COUNT(DISTINCT customer_state) AS state_count
FROM customers
GROUP BY customer_unique_id
HAVING zip_count > 1 OR city_count > 1 OR state_count > 1
ORDER BY zip_count DESC, city_count DESC, state_count DESC;

-- Impossible/Multiple customer location Avg check
WITH Multi_loc AS 
(
SELECT customer_unique_id, 
       COUNT(DISTINCT customer_zip_code) AS zip_count, 
	   COUNT(DISTINCT customer_city) AS city_count,
	   COUNT(DISTINCT customer_state) AS state_count,
       COUNT(*) AS Tot_orders
FROM customers
GROUP BY customer_unique_id
HAVING zip_count > 1 OR city_count > 1 OR state_count > 1
ORDER BY zip_count DESC, city_count DESC, state_count DESC
)
SELECT COUNT(*) AS affected_customers,
	   CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers), 2), '%') AS pct_affected, 
	   (SELECT COUNT(DISTINCT customer_unique_id) FROM customers) AS total_unique_customers,
       ROUND(AVG(zip_count), 2) AS avg_zip_variance, 
       ROUND(AVG(city_count), 2) AS avg_city_variance, 
       ROUND(AVG(state_count), 2) AS avg_state_variance,
	   MAX(zip_count) AS max_zip_variance
FROM Multi_loc;


-- --------------------------------------------------------------------------------------------------------------------------------- --
-- --------------------------------------------------------------------------------------------------------------------------------- --

#Creating Orders table 
CREATE TABLE orders (
order_id VARCHAR(50) UNIQUE PRIMARY KEY,
customer_id VARCHAR(50) ,
order_status VARCHAR(50),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME, 
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_orders.csv' 
INTO TABLE orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(order_id, customer_id, order_status, @v_purchase, @v_approved, @v_carrier, @v_customer, @v_estimated)
SET 
order_purchase_timestamp = NULLIF(@v_purchase, ''),
order_approved_at = NULLIF(@v_approved, ''),
order_delivered_carrier_date = NULLIF(@v_carrier, ''),
order_delivered_customer_date = NULLIF(@v_customer, ''),
order_estimated_delivery_date = NULLIF(@v_estimated, '');

SELECT* FROM orders;

-- Rows check
SELECT COUNT(*) AS Tot_rows FROM orders;

-- DUPLICATES CHECK
-- Primary Key Validation (Verifying schema UNIQUE constraints held during ETL)
SELECT order_id, COUNT(*) AS occurance_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Duplicates check for orders
SELECT COUNT(*) AS Occurance_count, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, 
order_delivered_customer_date, order_estimated_delivery_date
FROM orders
GROUP BY customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, 
order_delivered_customer_date, order_estimated_delivery_date
HAVING Occurance_count > 1;

-- STANDARDIZATION
-- order_status character error check
SELECT order_status, COUNT(*) AS status_count
FROM orders
GROUP BY order_status;

-- Check for hidden leading/trailing spaces for order_status
SELECT order_status, COUNT(*) AS tot_lead_trail_spaces
FROM orders
WHERE order_status != TRIM(order_status)
GROUP BY order_status;

-- ID Length Consistency Check
SELECT LENGTH(order_id) AS order_id_len, LENGTH(customer_id) AS customer_id_len, COUNT(*) AS error_volume
FROM orders
WHERE LENGTH(order_id) != 32 
   OR LENGTH(customer_id) != 32 
GROUP BY order_id_len, customer_id_len;

-- NULL/MISSING VALUES CHECK
SELECT SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END) AS missing_customer_id, 
    SUM(CASE WHEN order_status IS NULL OR TRIM(order_status) = '' THEN 1 ELSE 0 END) AS missing_statuses,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS misng_ord_purchase_dt,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS misng_ord_approval_dt,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS misng_delvrd_carrier_dt,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS misng_delvrd_cust_dt,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS misng_delvrd_estmtd_dt
FROM orders;

-- NULL percentage per column
SELECT CONCAT(ROUND(SUM(CASE WHEN order_approved_at   IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), '%') AS Perc_misng_ord_approval_dt,
CONCAT(ROUND(SUM(CASE WHEN order_delivered_carrier_date  IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_misng_delvrd_carrier_dt,
CONCAT(ROUND(SUM(CASE WHEN order_delivered_customer_date  IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_misng_delvrd_cust_dt
FROM orders;

-- Order_approved_date Null values distribution check
SELECT order_status, COUNT(*) AS count
FROM orders
WHERE order_approved_at IS NULL OR TRIM(order_approved_at)= ''
GROUP BY order_status;

-- Order_approved_date Null details check
SELECT* FROM orders
WHERE order_approved_at IS NULL OR TRIM(order_approved_at)= '';

-- Order delivered but payment not approved
SELECT * FROM orders
WHERE (order_approved_at IS NULL OR TRIM(order_approved_at)= '') AND 
order_status = 'delivered';

-- Detailed check of Order delivered but payment not approved
SELECT CASE 
        WHEN p.payment_type IS NULL THEN 'Missing Payment Record'
        ELSE 'Payment Found' 
    END AS financial_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(p.payment_value) AS total_revenue_at_risk
FROM orders o
LEFT JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered' 
AND (o.order_approved_at IS NULL OR TRIM(o.order_approved_at) = '')
GROUP BY financial_status;

-- Dataset check of order delivered but payment not found
SELECT o.order_id, o.order_status, o.order_delivered_customer_date, p.payment_type, 
p.payment_installments, p.payment_value
FROM orders o
LEFT JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered' 
AND (o.order_approved_at IS NULL OR TRIM(o.order_approved_at) = '');

-- Order_delivered_carrier_date Null values distribution check
SELECT order_status, COUNT(*) AS count
FROM orders
WHERE order_delivered_carrier_date IS NULL OR TRIM(order_delivered_carrier_date)= ''
GROUP BY order_status;

-- Order_delivered_carrier_date Null details check
SELECT* FROM orders
WHERE order_delivered_carrier_date IS NULL OR TRIM(order_delivered_carrier_date)= '';

-- order_delivered_customer_date Null values distribution check
SELECT order_status, COUNT(*) AS count
FROM orders
WHERE order_delivered_customer_date IS NULL OR TRIM(order_delivered_customer_date)= ''
GROUP BY order_status;

-- order_delivered_customer_date Null details check
SELECT* FROM orders
WHERE order_delivered_customer_date IS NULL OR TRIM(order_delivered_customer_date)= '';

-- CROSS TABLE & LOGIC CHECKS
-- checking if any order is placed by customer that does not exist in customer table
SELECT COUNT(o.order_id) AS orphaned_orders
FROM customers c
RIGHT JOIN orders o ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL;

-- checking if any customers have not placed any order
SELECT COUNT(c.customer_id) AS zero_order_customers
FROM customers c
LEFT JOIN orders o ON o.customer_id=c.customer_id
WHERE o.order_id IS NULL;

-- 1 to 1 business logic check (Every unique customer must have only 1 order_id)
SELECT c.customer_id, COUNT(o.order_id) AS tot_order_purchased
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY c.customer_id
HAVING tot_order_purchased > 1;

-- Checking Top 5 highest orders by State (Verifying does obvious top Brazil's cities get most orders)
SELECT c.customer_state, COUNT(o.order_id) AS Top_5_states
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_state
ORDER BY Top_5_states DESC LIMIT 5;

-- Dataset timeline check
SELECT MIN(order_purchase_timestamp) AS first_order_date, MAX(order_purchase_timestamp) AS last_order_date
FROM orders;

-- Timeline & Chronological Anomaly Check
SELECT 
    -- 1. Physical Impossibilities
    SUM(CASE WHEN order_delivered_customer_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS delivered_before_purchase,
    SUM(CASE WHEN order_delivered_carrier_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS shipped_before_purchase,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS delivered_before_shipped,
    SUM(CASE WHEN order_estimated_delivery_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS estimated_before_purchase,
    
    -- 2. Business Logic Flags
    SUM(CASE WHEN order_delivered_customer_date < order_approved_at THEN 1 ELSE 0 END) AS delivered_before_payment_approved,
    SUM(CASE WHEN order_status IN ('canceled', 'unavailable') AND order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) AS ghost_shipments,
    
    -- 3. System Sync Delays
    SUM(CASE WHEN order_approved_at > order_delivered_carrier_date THEN 1 ELSE 0 END) AS carrier_scanned_before_payment_sync
FROM orders;

-- Time-Travel carrier_scanned_before_payment_sync inspection
SELECT*
FROM orders
WHERE order_approved_at > order_delivered_carrier_date 
LIMIT 15;

-- Time-Travel delivered_before_payment_approved inspection
SELECT*
FROM orders
WHERE order_delivered_customer_date < order_approved_at
LIMIT 15;

-- Time-travel Ghost shipment inspection
SELECT* FROM orders
WHERE order_status IN ('canceled', 'unavailable') AND order_delivered_customer_date IS NOT NULL;

-- Time-Travel shipped_before_purchase inspection
SELECT* FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;

-- Time-Travel delivered_before_shipped inspection
 SELECT* FROM orders
 WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- Date difference check 
SELECT MAX(DATEDIFF(order_approved_at, order_purchase_timestamp)) AS Max_days_to_approve,
MAX(DATEDIFF(order_delivered_carrier_date, order_approved_at)) AS Max_days_to_carrier,
MAX(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)) AS Max_days_in_transit,
MAX(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS Max_tot_delivery_days
FROM orders;

-- --------------------------------------------------------------------------------------------------------------------------------- --
-- --------------------------------------------------------------------------------------------------------------------------------- --

#Creating Sellers table
CREATE TABLE sellers(
seller_id VARCHAR(50) UNIQUE PRIMARY KEY,
seller_zip_code VARCHAR(10),
seller_city VARCHAR(50),
seller_state VARCHAR(50));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_sellers.csv' 
INTO TABLE sellers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT* FROM sellers;

-- Tot row count
SELECT COUNT(*) AS Tot_rows FROM sellers;

-- Duplicates check 
-- Primary Key Validation (Verifying schema UNIQUE constraints held during ETL)
SELECT seller_id, COUNT(*) as occurrence_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Standardization
-- Hidden Leading/Trailing spaces check
SELECT seller_zip_code, seller_city, seller_state
FROM sellers
WHERE seller_zip_code != TRIM(seller_zip_code)
OR seller_city != TRIM(seller_city)
OR seller_state != TRIM(seller_state);

-- seller state consistency check
SELECT LENGTH(seller_state) AS state_length, count(*) AS state_count
FROM sellers
GROUP BY state_length;

-- Unknown state check
SELECT DISTINCT seller_state
FROM sellers
WHERE seller_state NOT IN ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS',
'MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO');

-- Checking for city name error
SELECT DISTINCT seller_city, COUNT(*) AS volume
FROM sellers
WHERE seller_city REGEXP '[0-9!@#$%^&*()_+=\\[\\]{};:"\\|<>/?,]'
   OR seller_city REGEXP '[Ã©¶¼¿€™‡]'
GROUP BY seller_city
ORDER BY volume DESC;

-- uppercase check
SELECT COUNT(*) AS uppercase
FROM sellers
WHERE seller_city COLLATE utf8mb4_bin REGEXP '[A-Z]';

-- Zip code length consistency check
SELECT LENGTH(seller_zip_code) AS Zip_length, COUNT(*) AS zip_count, 
CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(),2), '%') AS Percentage
FROM sellers
GROUP BY Zip_length;

-- Standardization: ID Length Consistency Check
SELECT LENGTH(seller_id) AS seller_id_len, COUNT(*) AS error_volume
FROM sellers
WHERE LENGTH(seller_id) != 32 
GROUP BY seller_id_len;

-- Null values check
SELECT SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id)= '' THEN 1 ELSE 0 END) AS missing_seller_id,
SUM(CASE WHEN seller_zip_code IS NULL OR TRIM(seller_zip_code)= '' THEN 1 ELSE 0 END) AS missing_seller_zip_code,
SUM(CASE WHEN seller_city IS NULL OR TRIM(seller_city)= '' THEN 1 ELSE 0 END) AS missing_seller_city,
SUM(CASE WHEN seller_state IS NULL OR TRIM(seller_state)= '' THEN 1 ELSE 0 END) AS missing_seller_state
FROM sellers;

-- Logic checks 
-- Geographic density check
SELECT seller_zip_code, seller_city, seller_state, COUNT(*) AS occurance_count
FROM sellers 
GROUP BY seller_zip_code, seller_city, seller_state
HAVING occurance_count>1
ORDER BY occurance_count DESC;

-- --------------------------------------------------------------------------------------------------------------------------------- --
-- --------------------------------------------------------------------------------------------------------------------------------- --

#Creating Products Table
CREATE TABLE products (
product_id VARCHAR(50) UNIQUE PRIMARY KEY,
product_category_name VARCHAR(50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_gm INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(product_id, product_category_name, @v_name_len, @v_desc_len, @v_photos, @v_weight, @v_length, @v_height, @v_width)
SET 
product_name_length = NULLIF(@v_name_len, ''),
product_description_length = NULLIF(@v_desc_len, ''),
product_photos_qty = NULLIF(@v_photos, ''),
product_weight_gm = NULLIF(@v_weight, ''),
product_length_cm = NULLIF(@v_length, ''),
product_height_cm = NULLIF(@v_height, ''),
product_width_cm = NULLIF(@v_width, '');

SELECT* FROM products;

-- Tot row count
SELECT COUNT(*) AS Tot_rows FROM products;

-- Duplicates check 
-- Primary Key Validation (Verifying schema UNIQUE constraints held during ETL)
SELECT product_id, COUNT(*) as occurrence_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Standardization
-- Leading/Trailing space check
SELECT COUNT(*) AS lead_trail_space_tot, product_category_name
FROM products
WHERE product_category_name != TRIM(product_category_name)
GROUP BY product_category_name;

-- product_cat_name validation check
SELECT product_category_name, COUNT(*)
FROM products
GROUP BY product_category_name
ORDER BY COUNT(*) DESC;

-- ID Length Consistency Check
SELECT LENGTH(product_id) AS product_id_len, COUNT(*) AS error_volume
FROM products
WHERE LENGTH(product_id) != 32 
GROUP BY product_id_len;

-- Upper case check
SELECT COUNT(*) AS uppercase
FROM products
WHERE product_category_name COLLATE utf8mb4_bin REGEXP '[A-Z]';

-- Null value check
SELECT SUM(CASE WHEN product_category_name IS NULL OR TRIM(product_category_name)= '' THEN 1 ELSE 0 END) AS mssng_prod_cat_name,
SUM(CASE WHEN product_name_length IS NULL OR TRIM(product_name_length)= '' THEN 1 ELSE 0 END) AS mssng_prod_name_length,
SUM(CASE WHEN product_description_length IS NULL OR TRIM(product_description_length)= '' THEN 1 ELSE 0 END) AS mssng_prod_desc_length,
SUM(CASE WHEN product_photos_qty IS NULL OR TRIM(product_photos_qty)= '' THEN 1 ELSE 0 END) AS mssng_prod_photos_qty,
SUM(CASE WHEN product_weight_gm IS NULL OR TRIM(product_weight_gm)= '' THEN 1 ELSE 0 END) AS mssng_prod_weight_gm,
SUM(CASE WHEN product_length_cm IS NULL OR TRIM(product_length_cm)= '' THEN 1 ELSE 0 END) AS mssng_prod_length_cm,
SUM(CASE WHEN product_height_cm IS NULL OR TRIM(product_height_cm)= '' THEN 1 ELSE 0 END) AS mssng_prod_height_cm,
SUM(CASE WHEN product_width_cm IS NULL OR TRIM(product_width_cm)= '' THEN 1 ELSE 0 END) AS mssng_prod_width_cm
FROM products;

-- NULL percentage per column
SELECT CONCAT(ROUND(SUM(CASE WHEN  product_name_length IS NULL OR TRIM(product_name_length)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), '%') AS Perc_mssng_prod_name_length,
CONCAT(ROUND(SUM(CASE WHEN product_description_length IS NULL OR TRIM(product_description_length)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_mssng_prod_desc_length,
CONCAT(ROUND(SUM(CASE WHEN product_photos_qty IS NULL OR TRIM(product_photos_qty)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_mssng_prod_photos_qty,
CONCAT(ROUND(SUM(CASE WHEN product_weight_gm IS NULL OR TRIM(product_weight_gm)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_mssng_prod_weight_gm,
CONCAT(ROUND(SUM(CASE WHEN product_length_cm IS NULL OR TRIM(product_length_cm)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_mssng_prod_length_cm,
CONCAT(ROUND(SUM(CASE WHEN product_height_cm IS NULL OR TRIM(product_height_cm)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_mssng_prod_heigth_cm,
CONCAT(ROUND(SUM(CASE WHEN product_width_cm IS NULL OR TRIM(product_width_cm)= '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),'%')AS Perc_mssng_prod_width_cm
FROM products;

-- Logic checks 
-- Top 5 common products sold
SELECT product_category_name, COUNT(*) AS Total_items
FROM products
GROUP BY product_category_name
ORDER BY Total_items DESC LIMIT 5;

-- Physical Logic Check: Impossible Dimensions (Zero or Negative values)
SELECT SUM(CASE WHEN product_weight_gm <= 0 THEN 1 ELSE 0 END) AS zero_weight_errors,
       SUM(CASE WHEN product_length_cm <= 0 THEN 1 ELSE 0 END) AS zero_length_errors,
       SUM(CASE WHEN product_height_cm <= 0 THEN 1 ELSE 0 END) AS zero_height_errors,
       SUM(CASE WHEN product_width_cm <= 0 THEN 1 ELSE 0 END) AS zero_width_errors
FROM products;

SELECT* FROM products
WHERE product_weight_gm <= 0 ;

-- UI/UX Logic Check: No photos + No description 
SELECT product_category_name, COUNT(*) as empty_shell_count
FROM products
WHERE (product_photos_qty = 0 OR product_photos_qty IS NULL)
  AND (product_description_length = 0 OR product_description_length IS NULL)
GROUP BY product_category_name
ORDER BY empty_shell_count DESC;

-- ------------------------------------------------------------------------------------------------------------------------------- --
-- ------------------------------------------------------------------------------------------------------------------------------- --

#Creating order_items Table
CREATE TABLE order_items (
order_id VARCHAR(50),
order_item_id INT,
product_id VARCHAR(50),
seller_id VARCHAR(50),
shipping_limit_date DATETIME,
price DECIMAL(10,2),
freight_value DECIMAL(10,2),
PRIMARY KEY (order_id, order_item_id),
FOREIGN KEY(order_id) REFERENCES orders(order_id),
FOREIGN KEY(product_id) REFERENCES products(product_id),
FOREIGN KEY(seller_id) REFERENCES sellers(seller_id));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_order_items.csv' 
INTO TABLE order_items 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(order_id, order_item_id, product_id, seller_id, @v_shipping, price, freight_value)
SET 
shipping_limit_date = NULLIF(@v_shipping, '');

SELECT* FROM order_items;

-- Tot rows count
SELECT COUNT(*) AS Tot_rows FROM order_items;

-- Duplicates check 
-- Primary Key Validation (Verifying schema UNIQUE constraints held during ETL)
SELECT order_id, order_item_id, COUNT(*) as occurrence_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Full Row Duplicate Check (Verifying no identical transactional logs)
SELECT order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value, COUNT(*) AS occurrence_count
FROM order_items
GROUP BY order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value
HAVING occurrence_count > 1;

-- Standardization
-- Leading/Trailing space check
SELECT COUNT(*) AS hidden_space_errors
FROM order_items
WHERE order_id != TRIM(order_id)
   OR product_id != TRIM(product_id)
   OR seller_id != TRIM(seller_id);
   
-- ID Lenght consistency check
SELECT LENGTH(order_id) AS order_id_len, LENGTH(product_id) AS product_id_len, LENGTH(seller_id) AS seller_id_len,
COUNT(*) AS error_volume
FROM order_items
WHERE LENGTH(order_id) != 32 
   OR LENGTH(product_id) != 32 
   OR LENGTH(seller_id) != 32
GROUP BY order_id_len, product_id_len, seller_id_len;

--  Null values check
SELECT SUM(CASE WHEN product_id IS NULL OR TRIM(product_id)='' THEN 1 ELSE 0 END) AS missing_product_id,
SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id)='' THEN 1 ELSE 0 END) AS missing_seller_id,
SUM(CASE WHEN shipping_limit_date IS NULL OR TRIM(shipping_limit_date)='' THEN 1 ELSE 0 END) AS missing_shipping_limit_date,
SUM(CASE WHEN price IS NULL OR TRIM(price)='' THEN 1 ELSE 0 END) AS missing_price,
SUM(CASE WHEN freight_value IS NULL OR TRIM(freight_value)='' THEN 1 ELSE 0 END) AS missing_freight_value
FROM order_items;

-- Min/Max/Avg checks
-- Checking Price's Mathematical details
SELECT Min(price), MAX(Price), AVG(Price)
FROM order_items;

-- Checking Freight Value's Mathematical details
SELECT Min(freight_value), MAX(freight_value), AVG(freight_value)
FROM order_items;

-- Logic checks
-- Negative values check
SELECT  SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_price_errors,
SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight_errors
FROM order_items;

-- Verifying every item links to a valid order, product, and seller
SELECT (SELECT COUNT(*) FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id WHERE o.order_id IS NULL) AS orphaned_orders,
(SELECT COUNT(*) FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id WHERE p.product_id IS NULL) AS orphaned_products,
(SELECT COUNT(*) FROM order_items oi LEFT JOIN sellers s ON oi.seller_id = s.seller_id WHERE s.seller_id IS NULL) AS orphaned_sellers;

-- Time-Travel Check
-- A shipping limit deadline cannot logically exist BEFORE the order purchase timestamp
SELECT COUNT(oi.order_item_id) AS time_travel_errors
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.shipping_limit_date < o.order_purchase_timestamp;

-- ------------------------------------------------------------------------------------------------------------------------------- --
-- ------------------------------------------------------------------------------------------------------------------------------- --

#Creating order_payments table
CREATE TABLE order_payments (
order_id VARCHAR(50),
payment_sequential INT,
payment_type VARCHAR(50),
payment_installments INT,
payment_value DECIMAL(10,2),
PRIMARY KEY (order_id, payment_sequential),
FOREIGN KEY (order_id) REFERENCES orders(order_id));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_order_payments.csv' 
INTO TABLE order_payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT* FROM order_payments;

-- Tot rows check
SELECT COUNT(*) AS Tot_rows FROM order_payments;

-- Duplicates check
SELECT order_id, payment_sequential, COUNT(*) AS occurance
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING occurance>1
ORDER BY occurance DESC;

-- Full Row Duplicate Check (Verifying no identical transactional logs)
SELECT order_id, payment_sequential, payment_type, payment_installments, payment_value, COUNT(*) AS occurrence_count
FROM order_payments
GROUP BY order_id, payment_sequential, payment_type, payment_installments, payment_value
HAVING occurrence_count > 1;

-- Standardization
-- Leading/Trailing space check
SELECT payment_type, COUNT(*) AS hidden_space
FROM order_payments
WHERE payment_type <> TRIM(payment_type)
GROUP BY payment_type;

-- NULL Values check
SELECT SUM(CASE WHEN payment_sequential IS NULL OR TRIM(payment_sequential)= '' THEN 1 ELSE 0 END) AS missing_payment_sequential,
SUM(CASE WHEN payment_type IS NULL OR TRIM(payment_type)= '' THEN 1 ELSE 0 END) AS missing_payment_type,
SUM(CASE WHEN payment_installments IS NULL OR TRIM(payment_installments)= '' THEN 1 ELSE 0 END) AS missing_payment_installments,
SUM(CASE WHEN payment_value IS NULL OR TRIM(payment_value)= '' THEN 1 ELSE 0 END) AS missing_payment_value
FROM order_payments;

-- Logic checks
-- Payment_types validation
SELECT payment_type, COUNT(*) AS payment_types, COALESCE(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 3), '%') AS Percentage
FROM order_payments
GROUP BY payment_type
ORDER BY COUNT(*) DESC;

-- Negatives check
SELECT COUNT(payment_value) AS Negative_count
FROM order_payments
WHERE payment_value < 0;

-- Min, Max & Avg payment values
SELECT MIN(payment_value) AS Lowest_payment, MAX(payment_value) AS Highest_payment, AVG(payment_value) AS Avg_payment
FROM order_payments;

-- Installments check (Only credit card should have installments more than 1)
SELECT payment_type, MAX(payment_installments) AS max_installments, ROUND(AVG(payment_installments), 1) AS avg_installments
FROM order_payments
GROUP BY payment_type;

-- Orphan check 
SELECT COUNT(*) AS orphaned_payments
FROM order_payments op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Business Logic Check: Suspicious Double-Charges
-- Checking orders with multiple identical payment types and values (potential API glitches)
SELECT order_id, payment_type, payment_value, COUNT(*) AS duplicate_charges
FROM order_payments
GROUP BY order_id, payment_type, payment_value
HAVING duplicate_charges > 1
ORDER BY duplicate_charges DESC;

-- ------------------------------------------------------------------------------------------------------------------------------- --
-- ------------------------------------------------------------------------------------------------------------------------------- --

#Creating Table order_reviews
CREATE TABLE order_reviews (
review_id VARCHAR(50),
order_id VARCHAR(50),
review_score INT,
review_comment_title VARCHAR(225),
review_comment_message TEXT,
review_creation_date DATETIME,
review_answer_timestamp DATETIME,
PRIMARY KEY (review_id, order_id),
FOREIGN KEY (order_id) REFERENCES orders(order_id));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_order_reviews.csv' 
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
ESCAPED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(review_id, order_id, review_score, @v_title, @v_message, @v_creation, @v_answer)
SET 
review_comment_title = NULLIF(@v_title, ''),
review_comment_message = NULLIF(@v_message, ''),
review_creation_date = NULLIF(@v_creation, ''),
review_answer_timestamp = NULLIF(@v_answer, '');

SELECT* FROM order_reviews;

-- Total rows count
SELECT COUNT(*) AS Tot_rows FROM order_reviews;

-- Duplicates check
SELECT review_id, order_id, COUNT(*) AS occurance
FROM order_reviews
GROUP BY review_id, order_id
HAVING occurance>1
ORDER BY occurance DESC;

-- Full Row Duplicate Check (Verifying no identical transactional logs)
SELECT review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp,
COUNT(*) AS occurrence_count
FROM order_reviews
GROUP BY review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp
HAVING occurrence_count > 1;

-- Standardization
-- Leading/Trailing space check
SELECT COUNT(*) AS lead_trial_space
FROM order_reviews
WHERE review_comment_title <> TRIM(review_comment_title) 
OR review_comment_message != TRIM(review_comment_message);

-- Leading/Trailing space sample view
SELECT *
FROM order_reviews
WHERE review_comment_title <> TRIM(review_comment_title) 
OR review_comment_message != TRIM(review_comment_message);

-- Truncate check
SELECT MAX(LENGTH(review_comment_title)) AS max_title_length, MAX(LENGTH(review_comment_message)) AS max_message_length
FROM order_reviews;

-- Review_score scale check (Rating should be between 1 - 5)
SELECT review_score, COUNT(*) AS score_count, CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2), '%') AS Percentage
FROM order_reviews
GROUP BY review_score;

-- Null check
SELECT SUM(CASE WHEN review_score IS NULL OR TRIM(review_score)='' THEN 1 ELSE 0 END) AS missing_review_score,
SUM(CASE WHEN review_comment_title IS NULL OR TRIM(review_comment_title)='' THEN 1 ELSE 0 END) AS missing_review_comment_title,
SUM(CASE WHEN review_comment_message IS NULL OR TRIM(review_comment_message)='' THEN 1 ELSE 0 END) AS missing_review_comment_message,
SUM(CASE WHEN review_creation_date IS NULL OR TRIM(review_creation_date)='' THEN 1 ELSE 0 END) AS missing_review_creation_date,
SUM(CASE WHEN review_answer_timestamp IS NULL OR TRIM(review_answer_timestamp)='' THEN 1 ELSE 0 END) AS missing_review_answer_timestamp
FROM order_reviews;

-- NULL percentage per column
SELECT CONCAT(ROUND(SUM(CASE WHEN review_comment_title IS NULL OR TRIM(review_comment_title)='' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), '%') AS missing_review_comment_title,
CONCAT(ROUND(SUM(CASE WHEN review_comment_message IS NULL OR TRIM(review_comment_message)='' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), '%') AS missing_review_comment_message
FROM order_reviews;

-- Logic checks 
-- Checking orders with multiple reviews
SELECT COUNT(*) AS orders_with_multiple_reviews
FROM ( SELECT order_id
       FROM order_reviews
       GROUP BY order_id
       HAVING COUNT(review_id) > 1
) AS multi_review_orders;

-- Time travel error 
SELECT COUNT(*) AS time_travel_error
FROM order_reviews
WHERE review_answer_timestamp < review_creation_date;

-- Verifying every review links to a valid order in the database
SELECT COUNT(r.review_id) AS orphaned_reviews
FROM order_reviews r
LEFT JOIN orders o ON r.order_id=o.order_id
WHERE o.order_id IS NULL;

-- Checking reviews where customers given review before orders purchased.
SELECT COUNT(r.review_id) AS impossible_reviews
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE r.review_creation_date < o.order_purchase_timestamp;

-- Cross-Table Business Logic: Premature Reviews
-- Checking how many reviews were written BEFORE the item was actually delivered
SELECT COUNT(r.review_id) AS premature_reviews
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE r.review_creation_date < o.order_delivered_customer_date;

-- Business Impact Analysis: Premature Reviews Driving Negative Scores
-- Checking review scale where the review form was sent at least 1 full day before delivery
SELECT r.review_score, COUNT(r.review_id) AS premature_bad_reviews, 
CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2), '%') AS Percentage
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE r.review_creation_date < o.order_delivered_customer_date
AND DATEDIFF(o.order_delivered_customer_date, r.review_creation_date) >= 1
AND r.review_score IN (1, 2, 3, 4, 5)
GROUP BY r.review_score 
ORDER BY r.review_score ASC;

-- --------------------------------------------------------------------------------------------------------------------------------- --
-- --------------------------------------------------------------------------------------------------------------------------------- --
#Creating geolocation table
CREATE TABLE geolocation (
geolocation_zip_code VARCHAR(10),
geolocation_lat DECIMAL(10,6),
geolocation_lng DECIMAL(10,6),
geolocation_city VARCHAR(50),
geolocation_state VARCHAR(50));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/olist_geolocation.csv' 
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT* FROM geolocation LIMIT 10;

-- Tot_rows count
SELECT COUNT(*) AS Tot_rows FROM geolocation;

-- Duplicates check
SELECT geolocation_zip_code, COUNT(*) AS occurance
FROM geolocation
GROUP BY geolocation_zip_code
ORDER BY occurance desc;

-- Standardization
-- Leading/Trialing space check
SELECT COUNT(*) AS lead_trial_error
FROM geolocation
WHERE geolocation_city <> TRIM(geolocation_city);

-- Leading/Trialing space validation
SELECT*
FROM geolocation
WHERE geolocation_city <> TRIM(geolocation_city);

-- Checking for city name error
SELECT DISTINCT geolocation_city, COUNT(*) AS volume
FROM geolocation
WHERE geolocation_city REGEXP '[0-9!@#$%^&*()_+=\\[\\]{};:"\\|<>/?,]'
   OR geolocation_city REGEXP '[Ã©¶¼¿€™‡]'
GROUP BY geolocation_city
ORDER BY volume DESC;
 
 -- Uppercase check
 SELECT COUNT(*) AS uppercase
FROM geolocation
WHERE geolocation_city COLLATE utf8mb4_bin REGEXP '[A-Z]';
 
-- Leading/Trialing space check
SELECT COUNT(*) AS lead_trial_error
FROM geolocation
WHERE geolocation_state <> TRIM(geolocation_state);

-- checking valid state
SELECT geolocation_state, COUNT(*) AS state_count
FROM geolocation
GROUP BY geolocation_state
HAVING state_count > 1
ORDER BY state_count ASC;

-- Unknown state check
SELECT DISTINCT geolocation_state
FROM geolocation
WHERE geolocation_state NOT IN ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS',
'MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO');

-- Zip code length consistency check
SELECT LENGTH(geolocation_zip_code) AS Zip_length, COUNT(*) AS zip_length_count,
CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2), '%') AS Percentage
FROM geolocation
GROUP BY Zip_length;

-- Null values check
--  Null values check
SELECT SUM(CASE WHEN geolocation_zip_code IS NULL OR TRIM(geolocation_zip_code)='' THEN 1 ELSE 0 END) AS missing_geolocation_zip_code,
SUM(CASE WHEN geolocation_lat IS NULL OR TRIM(geolocation_lat)='' THEN 1 ELSE 0 END) AS missing_geolocation_lat,
SUM(CASE WHEN geolocation_lng IS NULL OR TRIM(geolocation_lng)='' THEN 1 ELSE 0 END) AS missing_geolocation_lng,
SUM(CASE WHEN geolocation_city IS NULL OR TRIM(geolocation_city)='' THEN 1 ELSE 0 END) AS missing_geolocation_city,
SUM(CASE WHEN geolocation_state IS NULL OR TRIM(geolocation_state)='' THEN 1 ELSE 0 END) AS missing_geolocation_state
FROM geolocation;

-- Logic checks 
-- Geospatial Logic Check: "Null Island" Default Coordinates
SELECT COUNT(*) AS zero_coordinates
FROM geolocation
WHERE geolocation_lat = 0 AND geolocation_lng = 0;

-- Geospatial Logic Check: Out of Bounds Coordinates (Outside Brazil)
-- Brazil roughly falls between Lat (5.27 to -33.75) and Lng (-34.79 to -73.98)
SELECT COUNT(*) AS impossible_coordinates
FROM geolocation
WHERE geolocation_lat > 5.274388 OR geolocation_lat < -33.751169
OR geolocation_lng > -34.793147 OR geolocation_lng < -73.982830;

SELECT*
FROM geolocation
WHERE geolocation_lat > 5.274388 OR geolocation_lat < -33.751169
OR geolocation_lng > -34.793147 OR geolocation_lng < -73.982830;

-- Cross-Table Logic Check: Unmapped Customer Zip Codes
-- Finding how many unique customer zip codes are entirely missing from our spatial data
SELECT COUNT(DISTINCT c.customer_zip_code) AS unmapped_zip_codes
FROM customers c
LEFT JOIN geolocation g ON c.customer_zip_code = g.geolocation_zip_code
WHERE g.geolocation_zip_code IS NULL;

-- --------------------------------------------------------------------------------------------------------------------------------- --
-- --------------------------------------------------------------------------------------------------------------------------------- --

#Creating table prod_cat_name_transl
CREATE TABLE Prod_cat_name_transl (
prod_cat_name VARCHAR (100),
prod_cat_eng_name VARCHAR(100));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/File/product_category_name_translation.csv' 
INTO TABLE Prod_cat_name_transl
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT* FROM Prod_cat_name_transl;

-- Total Row Check
SELECT COUNT(*) AS Tot_rows 
FROM Prod_cat_name_transl;

-- Duplicates check
SELECT prod_cat_name, COUNT(*) AS occurance
FROM Prod_cat_name_transl
GROUP BY prod_cat_name
HAVING COUNT(*) > 1;

-- Standardization
-- Leading/Trialing space check
SELECT COUNT(*) AS lead_trial_error
FROM Prod_cat_name_transl
WHERE prod_cat_name != TRIM(prod_cat_name)
OR prod_cat_eng_name != TRIM(prod_cat_eng_name);

-- Checking for uppercase letters or standard spaces (instead of underscores)
SELECT *
FROM prod_cat_name_transl
WHERE prod_cat_name COLLATE utf8mb4_bin REGEXP '[A-Z ]' 
   OR prod_cat_eng_name COLLATE utf8mb4_bin REGEXP '[A-Z ]';

-- NUll values check
SELECT SUM(CASE WHEN prod_cat_name IS NULL OR TRIM(prod_cat_name) = '' THEN 1 ELSE 0 END) AS missing_prod_cat_name,
SUM(CASE WHEN prod_cat_eng_name IS NULL OR TRIM(prod_cat_eng_name) = '' THEN 1 ELSE 0 END) AS missing_prod_cat_eng_name
FROM Prod_cat_name_transl;

-- Logic check
-- Finding Un-translated Product Categories
SELECT DISTINCT p.product_category_name AS missing_translation
FROM Prod_cat_name_transl pt
RIGHT JOIN products p ON pt.prod_cat_name=p.product_category_name
WHERE p.product_category_name IS NOT NULL 
AND pt.prod_cat_name IS NULL;

-- Checking if multiple Portuguese categories accidentally map to the exact same English category
SELECT prod_cat_eng_name, COUNT(prod_cat_name) AS mapped_portuguese_categories
FROM prod_cat_name_transl
GROUP BY prod_cat_eng_name
HAVING mapped_portuguese_categories > 1;

-- ================================================================================================================================= --
-- ================================================================================================================================= --
-- ================================================================================================================================= --
-- ================================================================================================================================= --

#Data cleaning
-- Creating Working Copies for Data Cleaning
CREATE TABLE customers_clean AS SELECT * FROM customers;
CREATE TABLE orders_clean AS SELECT * FROM orders;
CREATE TABLE sellers_clean AS SELECT * FROM sellers;
CREATE TABLE products_clean AS SELECT * FROM products;
CREATE TABLE order_items_clean AS SELECT * FROM order_items;
CREATE TABLE order_payments_clean AS SELECT * FROM order_payments;
CREATE TABLE order_reviews_clean AS SELECT * FROM order_reviews;
CREATE TABLE geolocation_clean AS SELECT * FROM geolocation;
CREATE TABLE Prod_cat_name_transl_clean AS SELECT * FROM Prod_cat_name_transl;

#Customers Table:
-- No cleaning required

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Order Table:
-- sample data
SELECT* FROM orders_clean LIMIT 10;

-- Dropping records (shipped before purchase & delivered before shipping)
DELETE FROM orders_clean
WHERE order_delivered_carrier_date < order_purchase_timestamp 
OR order_delivered_customer_date < order_delivered_carrier_date;

-- validatng physical impossibilities
SELECT SUM(CASE WHEN order_delivered_carrier_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS shipped_before_purchase,
SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS delivered_before_shipped
FROM orders_clean;

SET SQL_SAFE_UPDATES= 0;

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Sellers Table:
SELECT* FROM sellers_clean LIMIT 10;

UPDATE sellers_clean
SET seller_city = TRIM(REGEXP_REPLACE(seller_city, '(/|,|\\().*', ''));

-- This nullifies emails and pure numbers
UPDATE sellers_clean SET seller_city = NULL WHERE seller_city LIKE '%@%' OR seller_city REGEXP '^[0-9]+$';
   
-- Patch the missing cities using the zip code mapping from the geolocation table
UPDATE sellers_clean s
JOIN (SELECT geolocation_zip_code, geolocation_city
      FROM geolocation
      GROUP BY geolocation_zip_code, geolocation_city
) g ON s.seller_zip_code = g.geolocation_zip_code
SET s.seller_city = g.geolocation_city
WHERE s.seller_city IS NULL;

-- Checking for city name error
SELECT DISTINCT seller_city, COUNT(*) AS volume
FROM sellers_clean
WHERE seller_city REGEXP '[0-9!@#$%^&*()_+=\\[\\]{};:"\\|<>/?,]'
   OR seller_city REGEXP '[Ã©¶¼¿€™‡]'
GROUP BY seller_city
ORDER BY volume DESC;

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Products table
SELECT* FROM products_clean LIMIT 10;

-- Filling Null Values
UPDATE products_clean SET product_category_name = CASE 
WHEN product_category_name IS NULL OR TRIM(product_category_name)= '' 
THEN 'Unknown' ELSE product_category_name 
END,
product_name_length= COALESCE(product_name_length, 0),
product_description_length=  COALESCE(product_description_length, 0),
product_photos_qty= COALESCE(product_photos_qty, 0)
WHERE product_photos_qty IS NULL OR TRIM(product_photos_qty)= '';

UPDATE products_clean SET 
product_weight_gm = CASE WHEN product_weight_gm <= 0 THEN NULL ELSE product_weight_gm END;

-- checking null values
SELECT SUM(CASE WHEN product_category_name IS NULL OR TRIM(product_category_name)= '' THEN 1 ELSE 0 END) AS mssng_prod_cat_name,
SUM(CASE WHEN product_name_length IS NULL OR TRIM(product_name_length)= '' THEN 1 ELSE 0 END) AS mssng_prod_name_length,
SUM(CASE WHEN product_description_length IS NULL OR TRIM(product_description_length)= '' THEN 1 ELSE 0 END) AS mssng_prod_desc_length,
SUM(CASE WHEN product_photos_qty IS NULL OR TRIM(product_photos_qty)= '' THEN 1 ELSE 0 END) AS mssng_prod_photos_qty,
SUM(CASE WHEN product_weight_gm IS NULL OR TRIM(product_weight_gm)= '' THEN 1 ELSE 0 END) AS mssng_prod_weight_gm,
SUM(CASE WHEN product_length_cm IS NULL OR TRIM(product_length_cm)= '' THEN 1 ELSE 0 END) AS mssng_prod_length_cm,
SUM(CASE WHEN product_height_cm IS NULL OR TRIM(product_height_cm)= '' THEN 1 ELSE 0 END) AS mssng_prod_height_cm,
SUM(CASE WHEN product_width_cm IS NULL OR TRIM(product_width_cm)= '' THEN 1 ELSE 0 END) AS mssng_prod_width_cm
FROM products_clean;

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Order Items
SELECT* FROM order_items_clean;
-- No cleaning required

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Order Payments
SELECT* FROM Order_payments_clean;

-- No cleaning required

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Order Reviews
SELECT* FROM order_reviews_clean LIMIT 10;

-- Removing leading/Trialing spaces from comment title & comment message
UPDATE order_reviews_clean SET review_comment_title= TRIM(review_comment_title), review_comment_message= TRIM(review_comment_message);

-- Validating Trialing/leading spaces removal
SELECT COUNT(*) AS lead_trial_blank_count
FROM order_reviews_clean
WHERE review_comment_title!= TRIM(review_comment_title)
OR review_comment_message!= TRIM(review_comment_message);

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Geolocation

SELECT* FROM geolocation_clean LIMIT 10;

-- Removing Leading/Trialing space;
UPDATE geolocation_clean SET geolocation_city = TRIM(geolocation_city);

-- Leading/Trialing space validation
SELECT*
FROM geolocation_clean
WHERE geolocation_city <> TRIM(geolocation_city);


CREATE TABLE geolocation_clean2 AS
SELECT geolocation_zip_code, AVG(geolocation_lat) AS center_latitude, AVG(geolocation_lng) AS center_longitude
FROM geolocation_clean
WHERE geolocation_lat <= 5.274388 AND geolocation_lat >= -33.751169
AND geolocation_lng <= -34.793147 AND geolocation_lng >= -73.982830
GROUP BY geolocation_zip_code;

-- Validating
SELECT COUNT(*) AS impossible_coordinates
FROM geolocation_clean2
WHERE center_latitude > 5.274388 OR center_latitude < -33.751169
OR center_longitude > -34.793147 OR center_longitude < -73.982830;

SELECT COUNT(*) AS Tot_rows FROM geolocation_clean2;

-- ------------------------------------------------------------------------------------------------------------------------------- --

#Product Category Name Translation Table

SELECT* FROM Prod_cat_name_transl_clean;

-- Adding untranslated new rows
INSERT INTO Prod_cat_name_transl_clean (prod_cat_name, prod_cat_eng_name)
VALUES
('pc_gamer', 'pc_gamer'),
('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_food_preparers');

-- Updating the blank/null categories in the main products table
UPDATE products
SET product_category_name = 'uncategorized'
WHERE product_category_name IS NULL OR TRIM(product_category_name) = '';

-- Adding the matching mapping to the translation dictionary
INSERT INTO Prod_cat_name_transl_clean (prod_cat_name, prod_cat_eng_name)
VALUES ('uncategorized', 'uncategorized');

-- Finding Un-translated Product Categories
SELECT DISTINCT p.product_category_name AS missing_translation
FROM Prod_cat_name_transl_clean pt
RIGHT JOIN products p ON pt.prod_cat_name=p.product_category_name
WHERE p.product_category_name IS NOT NULL 
AND pt.prod_cat_name IS NULL;

-- ========================================================================================================================================================= --
-- ========================================================================================================================================================= --
-- ========================================================================================================================================================= --
-- ========================================================================================================================================================= --

#Master Table creation
CREATE TABLE olist_master AS
-- Pre aggregating - Order Payments
WITH order_payments_agg AS (
SELECT order_id, SUM(payment_value) AS total_payment_value, 
				 MAX(payment_type) AS payment_type, 
                 MAX(payment_installments) AS payment_installments,
                 COUNT(*) AS payment_rows
FROM order_payments_clean
GROUP BY order_id
),
-- Pre aggregation - Order Reviews
order_reviews_agg AS (
-- Latest review score from multiple reviews
SELECT order_id, SUBSTRING(GROUP_CONCAT(review_score ORDER BY review_creation_date DESC), 1, 1) AS review_score,
				 MAX(review_creation_date) AS review_creation_date
FROM order_reviews_clean 
GROUP BY order_id
),

-- Pre aggregation - Order Items
order_items_agg AS (
SELECT order_id, COUNT(*) AS total_items, 
                 SUM(price) AS total_items_price,
				 SUM(freight_value) AS total_freight_value,
-- Primary seller = seller with highest priced item in the order
SUBSTRING(GROUP_CONCAT(seller_id ORDER BY price DESC), 1, 32) AS primary_seller_id,
-- Primary product = highest priced item in the order
SUBSTRING(GROUP_CONCAT(product_id ORDER BY price DESC), 1, 32) AS primary_product_id
FROM order_items_clean
GROUP BY order_id
)

-- MAIN JOIN

SELECT 
-- customers table
c.customer_id,
c.customer_unique_id,
c.customer_zip_code,
c.customer_city,
c.customer_state,
-- Orders table
o.order_id,
o.order_status,
o.order_purchase_timestamp,
o.order_approved_at,
o.order_delivered_carrier_date,
o.order_delivered_customer_date,
o.order_estimated_delivery_date,
-- Order Payment table
p.total_payment_value,
p.payment_type,
p.payment_installments,
p.payment_rows,
-- Order Items table
i.total_items,
i.total_items_price,
i.total_freight_value,
i.primary_seller_id,
i.primary_product_id,
-- Seller table
s.seller_zip_code,
s.seller_city,
s.seller_state,
-- Products table
pr.product_category_name        AS product_category_name_pt,
t.prod_cat_eng_name             AS product_category_name_en,
pr.product_weight_gm,
pr.product_photos_qty,
pr.product_name_length,
pr.product_description_length,
-- Order Review table
r.review_score,
r.review_creation_date,
-- Geolocation table
gc.center_latitude AS customer_lat,
gc.center_longitude AS customer_lng

-- Joins

FROM orders_clean o

-- Every order has a valid customer — confirmed 0 orphans in profiling
INNER JOIN customers_clean c ON o.customer_id = c.customer_id

-- Some cancelled orders may have no payment record
LEFT JOIN order_payments_agg p ON o.order_id = p.order_id

-- Some cancelled orders may have no items dispatched
LEFT JOIN order_items_agg i ON o.order_id = i.order_id

-- Seller joined via primary_seller_id from order_items_agg
LEFT JOIN sellers_clean s ON i.primary_seller_id = s.seller_id

-- Product joined via primary_product_id from order_items_agg
LEFT JOIN products_clean pr ON i.primary_product_id = pr.product_id

-- English translation for product category
LEFT JOIN Prod_cat_name_transl_clean t ON pr.product_category_name = t.prod_cat_name

-- Not all orders have a review
LEFT JOIN order_reviews_agg r ON o.order_id = r.order_id

-- 157 unmapped zips will produce NULL lat/lng — retained intentionally
LEFT JOIN geolocation_clean2 gc ON c.customer_zip_code = gc.geolocation_zip_code;


-- Master checks Olist_master
SELECT* FROM olist_master;

-- Row count comparison check
SELECT (SELECT COUNT(*) FROM  orders_clean) AS orders_clean_count,
       (SELECT COUNT(*) FROM Olist_master) AS Olist_tot_rows,
	   (SELECT COUNT(*) FROM  orders_clean) -
       (SELECT COUNT(*) FROM Olist_master) AS difference;
       
-- Revenue checks
SELECT (SELECT ROUND(SUM(payment_value), 2) FROM order_payments_clean)  AS raw_payments_total,
       (SELECT ROUND(SUM(total_payment_value), 2) FROM olist_master)     AS master_total;
-- These will NOT match exactly (master excludes cancelled/no-payment orders)

-- Checking all delivered orders received payments
SELECT COUNT(*) AS delivered_missing_payment
FROM olist_master
WHERE order_status = 'delivered'
AND total_payment_value IS NULL;

-- Column completeness overview
SELECT
    COUNT(*)                                                               AS total_rows,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END)            AS null_customer,
    SUM(CASE WHEN total_payment_value IS NULL THEN 1 ELSE 0 END)           AS null_payment,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END)                  AS null_review,
    SUM(CASE WHEN product_category_name_en IS NULL THEN 1 ELSE 0 END)      AS null_category,
    SUM(CASE WHEN customer_lat IS NULL THEN 1 ELSE 0 END)                  AS null_geolocation,
    SUM(CASE WHEN primary_seller_id IS NULL THEN 1 ELSE 0 END)             AS null_seller
FROM olist_master;

SELECT* FROM olist_master
WHERE order_status IN ('canceled', 'unavailable') AND order_delivered_customer_date IS NOT NULL;
