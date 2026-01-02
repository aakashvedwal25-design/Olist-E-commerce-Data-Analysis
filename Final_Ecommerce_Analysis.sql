SHOW TABLES;
SELECT * FROM customers_data;

CREATE TABLE customers_data (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/ECommerce (Project)/olist_customers_dataset.csv'
INTO TABLE customers_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from customers_data;


CREATE TABLE orders_data (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/New_folder[1]/New folder/order Dataset.csv'
INTO TABLE Orders_data  
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from orders_data;
select * from orders_data;


CREATE TABLE payments_data (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/ECommerce (Project)/olist_order_payments_dataset.csv'
INTO TABLE payments_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from payments_data;
select * from payments_data;


CREATE TABLE items_data (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY(order_id, order_item_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/New_folder[1]/New folder/Order_item dataset.csv'
INTO TABLE items_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from items_data;
select * from items_data;


CREATE TABLE products_data (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/New_folder[1]/New folder/product dataset.csv'
INTO TABLE products_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from products_data;
select * from products_data;


CREATE TABLE reviews_data (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/ECommerce (Project)/olist_order_reviews_dataset_clean.csv'
INTO TABLE reviews_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from reviews_data;
select * from reviews_data;


CREATE TABLE sellers_data (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/ECommerce (Project)/olist_sellers_dataset.csv'
INTO TABLE sellers_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from sellers_data;
select * from sellers_data;


CREATE TABLE geolocation_data (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Aakash/OneDrive/Documents/ECommerce (Project)/olist_geolocation_dataset.csv'
INTO TABLE geolocation_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM geolocation_data;

select * from payments_data;
select * from reviews_data;



-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------






#  E-Commerce Analytics Performance SQL Queries 





-- KPI-1. Weekday v/s Weekend (order_purchase_timestamp)--  (with total_orders and period)

WITH 
day_type_counts AS (
    SELECT 
        CASE 
            WHEN WEEKDAY(order_purchase_timestamp) IN (5, 6) 
                THEN 'Weekend'
            ELSE 'Weekday'
        END AS Period,
        COUNT(*) AS total_orders
    FROM orders_data
    GROUP BY Period
)
SELECT 
    Period,
    CONCAT(ROUND(total_orders / 1000, 2), 'K') AS total_orders,
    CONCAT(ROUND((total_orders / (SELECT SUM(total_orders) FROM day_type_counts)) * 100), '%') 
        AS percentage
FROM day_type_counts;
	
  

-- KPI-2. No. of orders by payment_type-- 

SELECT 
    p.payment_type,
    CONCAT(ROUND(COUNT(DISTINCT p.order_id) / 1000, 2), 'K') AS total_orders
FROM payments_data p
GROUP BY p.payment_type
ORDER BY COUNT(DISTINCT p.order_id) DESC;



-- KPI3. Count of Orders with Review Score 5 and Payment Type as Credit Card-- 

SELECT 
    CONCAT(ROUND(COUNT(DISTINCT r.order_id) / 1000, 2), 'K') AS total_orders
FROM reviews_data r
JOIN payments_data p
      ON r.order_id = p.order_id
WHERE r.review_score = 5
  AND p.payment_type = 'credit_card';
  
  
  
-- KPI4. Average number of days taken for order_delivered_customer_date for pet_shop-- 

SELECT 
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp))) 
        AS avg_delivery_days_pet_shop
FROM items_data oi
JOIN products_data p 
      ON oi.product_id = p.product_id
JOIN orders_data o 
      ON oi.order_id = o.order_id
WHERE p.product_category_name = 'pet_shop'
  AND o.order_delivered_customer_date IS NOT NULL;


  
-- KPI5.Average price and payment values from customers of sao paulo city-- 

SELECT 
    ROUND(AVG(oi.price)) AS avg_product_price_sp,
    ROUND(AVG(p.payment_value)) AS avg_payment_value_sp
FROM customers_data c
JOIN orders_data o 
    ON c.customer_id = o.customer_id
JOIN items_data oi
    ON o.order_id = oi.order_id
JOIN payments_data p
    ON o.order_id = p.order_id
WHERE c.customer_city = 'sao paulo';

