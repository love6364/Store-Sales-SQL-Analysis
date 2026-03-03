Create database sales_store;
use sales_store;

select * from sales_store;

-- Create Clean Copy Table

CREATE TABLE sales AS
SELECT * FROM sales_store;


-- Remove Duplicates

SELECT transaction_id, COUNT(*)
FROM sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;


DELETE s1 FROM sales s1
JOIN sales s2 
ON s1.transaction_id = s2.transaction_id
AND s1.transaction_id IS NOT NULL
AND s1.rowid > s2.rowid;

-- Rename Columns

ALTER TABLE sales
CHANGE quantiy quantity INT;

ALTER TABLE sales
CHANGE prce price FLOAT;


-- Check Datatypes

DESCRIBE sales;


-- Check Null Values

SELECT 
SUM(transaction_id IS NULL) AS transaction_id_nulls,
SUM(customer_id IS NULL) AS customer_id_nulls,
SUM(customer_name IS NULL) AS customer_name_nulls,
SUM(customer_age IS NULL) AS customer_age_nulls,
SUM(gender IS NULL) AS gender_nulls,
SUM(product_id IS NULL) AS product_id_nulls,
SUM(product_name IS NULL) AS product_name_nulls,
SUM(product_category IS NULL) AS product_category_nulls,
SUM(quantity IS NULL) AS quantity_nulls,
SUM(price IS NULL) AS price_nulls,
SUM(payment_mode IS NULL) AS payment_mode_nulls,
SUM(purchase_date IS NULL) AS purchase_date_nulls,
SUM(status IS NULL) AS status_nulls
FROM sales;



DELETE FROM sales
WHERE transaction_id IS NULL;

-- Data Cleaning Updates

-- Standardize Gender

UPDATE sales
SET gender = 'M'
WHERE gender = 'Male';

UPDATE sales
SET gender = 'F'
WHERE gender = 'Female';

-- Standardize Payment Mode

UPDATE sales
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC';

-- DATA ANALYSIS

-- Top 5 Selling Products

SELECT product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Most Cancelled Products

SELECT product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status = 'cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC
LIMIT 5;


-- Peak Purchase Time

SELECT 
CASE 
    WHEN HOUR(time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
    WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
    WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
    ELSE 'EVENING'
END AS time_of_day,
COUNT(*) AS total_orders
FROM sales
GROUP BY time_of_day
ORDER BY total_orders DESC;

-- Top 5 Highest Spending Customers
SELECT 
customer_name,
CONCAT('₹ ', FORMAT(SUM(price * quantity), 0)) AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(price * quantity) DESC
LIMIT 5;

-- Highest Revenue Product Category
SELECT product_category,
ROUND(SUM(price * quantity), 0) AS revenue
FROM sales
GROUP BY product_category
ORDER BY revenue DESC;

-- Cancellation Rate Per Category

SELECT product_category,
ROUND(SUM(status='cancelled') * 100.0 / COUNT(*), 2) AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC;

-- Most Preferred Payment Mode

SELECT payment_mode, COUNT(*) AS total_count
FROM sales
GROUP BY payment_mode
ORDER BY total_count DESC;

-- Age Group Purchase Behavior
SELECT 
CASE 
    WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
    WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
    WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
    ELSE '51+'
END AS age_group,
SUM(price * quantity) AS total_purchase
FROM sales
GROUP BY age_group
ORDER BY FIELD(age_group, '18-25', '26-35', '36-50', '51+');

-- Monthly Sales Trend

UPDATE sales
SET purchase_date = STR_TO_DATE(purchase_date, '%d-%m-%Y');
SELECT 
DATE_FORMAT(purchase_date, '%Y-%m') AS month_year,
SUM(price * quantity) AS total_sales,
SUM(quantity) AS total_quantity
FROM sales
GROUP BY month_year
ORDER BY month_year;

-- Gender vs Product Category

SELECT 
product_category,
SUM(gender = 'M') AS Male,
SUM(gender = 'F') AS Female
FROM sales
GROUP BY product_category
ORDER BY product_category;