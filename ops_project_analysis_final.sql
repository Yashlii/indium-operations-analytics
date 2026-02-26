-- =========================================
-- PROJECT: Operations & Sales Analysis
-- TOOL: MySQL
-- DATASET: Superstore Sales Dataset
-- OBJECTIVE:
-- Analyze sales, profit, discounts and operational performance
-- =========================================

CREATE DATABASE ops_project;
USE ops_project;

-- Table creation (raw import stage)
CREATE TABLE orders (
    row_id INT,
    order_id VARCHAR(50),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
) CHARACTER SET latin1;

-- Data load
LOAD DATA LOCAL INFILE 'path_to_csv'
INTO TABLE orders
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Convert text dates to DATE format
SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET order_date = STR_TO_DATE(order_date,'%m/%d/%Y'),
    ship_date  = STR_TO_DATE(ship_date,'%m/%d/%Y');

ALTER TABLE orders
MODIFY order_date DATE,
MODIFY ship_date DATE;

SET SQL_SAFE_UPDATES = 1;

-- =========================================
-- KPI SUMMARY
-- =========================================

SELECT 
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
ROUND(AVG(discount),2) AS avg_discount,
ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM orders;

/* Observation:

Total orders: ~5009

Total sales: ~$2.29M

Profit margin: ~12%

Average discount: ~16%
Overall business profitable but discount impact needs monitoring. */

-- =========================================
-- REGION PERFORMANCE
-- =========================================

SELECT region,
ROUND(SUM(sales),2) AS sales,
ROUND(SUM(profit),2) AS profit
FROM orders
GROUP BY region
ORDER BY sales DESC;

/* Observation:

West region highest sales & profit

Central region weaker
Regional optimization possible.*/


-- =========================================
-- CATEGORY PERFORMANCE
-- =========================================

SELECT category,
ROUND(SUM(sales),2) AS sales,
ROUND(SUM(profit),2) AS profit
FROM orders
GROUP BY category;

/* Observation:

Technology most profitable

Furniture lower margins
Pricing strategy may need review. */


-- =========================================
-- MONTHLY SALES TREND
-- =========================================

SELECT 
DATE_FORMAT(order_date,'%Y-%m') AS month,
ROUND(SUM(sales),2) AS sales,
ROUND(SUM(profit),2) AS profit
FROM orders
GROUP BY month
ORDER BY month;

/* Observation:

Strong Q4 spikes

Seasonal trends visible

Useful for forecasting & planning. */


-- =========================================
-- DISCOUNT IMPACT
-- =========================================

SELECT 
discount,
ROUND(AVG(profit),2) AS avg_profit,
ROUND(SUM(sales),2) AS sales
FROM orders
GROUP BY discount
ORDER BY discount;

/* Observation:

Discounts above 30% → negative profit

High discounting hurting margins

Suggest cap discount strategy.*/


-- =========================================
-- Order count per discount
-- =========================================

SELECT discount,
COUNT(*) AS orders
FROM orders
GROUP BY discount;

/* -- OBSERVATION (DISCOUNT ORDER COUNT):
-- Majority of orders occur at 0% and 20% discount levels.
-- Very few orders exist at extremely high discounts (45%+).
-- However, higher discount ranges show negative average profit.
-- This indicates discounts are being used to push volume,
-- but excessive discounts are damaging profitability.
-- Recommendation: keep discounts within 0–20% range for sustainable margins.*/

-- =========================================
-- LOSS-MAKING PRODUCTS
-- =========================================

SELECT product_name,
ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY product_name
HAVING total_profit < 0
ORDER BY total_profit;

/* Observation:
Several high-revenue products generate losses.
Requires pricing or discount review. */

