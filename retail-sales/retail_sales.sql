-- Retail Sales Analysis
-- https://www.kaggle.com/datasets/abdullah0a/retail-sales-data-with-seasonal-trends-and-marketing

USE retail_sales;

-- 1. Data Cleaning
SELECT * FROM retail_sales;

CREATE TABLE retail_sales_staging LIKE retail_sales;

INSERT INTO retail_sales_staging
SELECT * FROM retail_sales;

-- 1.1. Remove duplicates
-- Verify duplicated lines.

WITH cte_duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY `Store ID`, `Product ID`, `Date`, `Units Sold`, `Sales Revenue (USD)`,
                                       `Discount Percentage`, `Marketing Spend (USD)`, `Store Location`, 
                                       `Product Category`, `Day of the Week`, `Holiday Effect`) AS row_num
    FROM retail_sales_staging
)
SELECT
	* 
FROM cte_duplicates
WHERE row_num > 1;

-- 1.2. Standardize the data
SELECT * FROM retail_sales_staging;

-- Verify strings in `Store Location` column
SELECT 
    DISTINCT `Store Location`,
    TRIM(`Store Location`)
FROM retail_sales_staging;

-- Verify strings in `Product Category` column
SELECT 
    DISTINCT `Product Category`,
    TRIM(`Product Category`)
FROM retail_sales_staging;
	
-- Verify data consistency in `Store Location` column
SELECT 
    DISTINCT `Store Location`
FROM retail_sales_staging
ORDER BY 1;

-- Verify data consistency in `Product Category` column
SELECT 
    DISTINCT `Product Category`
FROM retail_sales_staging
ORDER BY 1;

-- Verify data type
DESCRIBE retail_sales_staging;

UPDATE retail_sales_staging
SET `Date` = STR_TO_DATE(`Date`, '%Y-%m-%d');

ALTER TABLE retail_sales_staging
MODIFY COLUMN `Date` DATE;

SELECT * FROM retail_sales_staging;

-- 1.3. Handle null values / blank values
-- Verify null data
SELECT * 
FROM retail_sales_staging
WHERE 
    `Product ID` IS NULL OR 
    `Date` IS NULL OR 
    `Units Sold` IS NULL OR
    `Sales Revenue (USD)` IS NULL OR
    `Discount Percentage` IS NULL OR
    `Marketing Spend (USD)` IS NULL OR 
    `Store Location` IS NULL OR
    `Product Category` IS NULL OR 
    `Day of the Week` IS NULL OR
    `Holiday Effect` IS NULL;

-- 2. Data Exploration
SELECT * FROM retail_sales_staging;

-- 2.1. Effectiveness of marketing spend 
-- 2.1.1. Marketing spend impact on revenue

WITH cte_revenue AS (
    SELECT
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_marketing_spend,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_marketing_spend,
        AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Marketing Spend (USD)` ELSE 0 END) AS avg_marketing_spend
    FROM
        retail_sales_staging
)
SELECT
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue;

-- 2.1.2. Marketing spend impact on revenue by `Product Category`

WITH cte_revenue AS (
    SELECT
        `Product Category`,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_marketing_spend,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_marketing_spend,
        AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Marketing Spend (USD)` ELSE 0 END) AS avg_marketing_spend
    FROM
        retail_sales_staging
	GROUP BY `Product Category`
)
SELECT
    `Product Category`,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;

-- 2.1.3. Marketing spend impact on revenue by `Day of the Week`,

WITH cte_revenue AS (
    SELECT
        `Day of the Week`,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_marketing_spend,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_marketing_spend,
        AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Marketing Spend (USD)` ELSE 0 END) AS avg_marketing_spend
    FROM
        retail_sales_staging
	GROUP BY `Day of the Week`
)
SELECT
    `Day of the Week`,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;

-- 2.1.4. Marketing spend impact on revenue by `Holiday Effect`

WITH cte_revenue AS (
    SELECT
        `Holiday Effect`,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_marketing_spend,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_marketing_spend,
        AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Marketing Spend (USD)` ELSE 0 END) AS avg_marketing_spend
    FROM
        retail_sales_staging
	GROUP BY `Holiday Effect`
)
SELECT
    `Holiday Effect`,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;

-- 2.1.5. Marketing spend impact on revenue by `year`

WITH cte_revenue AS (
    SELECT
        Year(`Date`) AS `year`,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_marketing_spend,
        ROUND(AVG(CASE WHEN `Marketing Spend (USD)` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_marketing_spend,
        AVG(CASE WHEN `Marketing Spend (USD)` > 0 THEN `Marketing Spend (USD)` ELSE 0 END) AS avg_marketing_spend
    FROM
        retail_sales_staging
	GROUP BY `year`
)
SELECT
    `year`,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;

-- 2.2. Effectiveness of discount strategy
-- 2.2.1. Discount impact on revenue

SELECT
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging;

-- 2.2.2. Discount impact on revenue by `Product Category`

SELECT
    `Product Category`,
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging
GROUP BY `Product Category`
ORDER BY avg_revenue_with_discount DESC;

-- 2.2.3. Discount impact on revenue by `Day of the Week`

SELECT
    `Day of the Week`,
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging
GROUP BY `Day of the Week`
ORDER BY avg_revenue_with_discount DESC;

-- 2.2.4. Discount impact on revenue by `Holiday Effect`

SELECT
    `Holiday Effect`,
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging
GROUP BY `Holiday Effect`
ORDER BY avg_revenue_with_discount DESC;

-- 2.3. Sales Trend
-- 2.3.1. Sales trend over year

SELECT
    YEAR(`Date`) AS `year`,
    ROUND(SUM(`Sales Revenue (USD)`), 2) AS total_revenue
FROM retail_sales_staging
GROUP BY `year`
ORDER By `year`;

-- Check date range
SELECT
    MIN(`Date`) AS first_date,
    MAX(`Date`) AS last_date
FROM retail_sales_staging;

-- 2.3.2. Seasonal sales trend 

SELECT
    `Holiday Effect`,
    ROUND(AVG(`Sales Revenue (USD)`), 2) AS average_revenue
FROM retail_sales_staging
GROUP BY `Holiday Effect`
ORDER BY average_revenue DESC;

-- 2.3.3. Sales trend by `Day of the Week`

SELECT
    `Day of the Week`,
    ROUND(AVG(`Sales Revenue (USD)`), 2) AS average_revenue
FROM retail_sales_staging
GROUP BY `Day of the Week`
ORDER BY average_revenue DESC;

-- 2.3.4. Sales trend by `Product Category`

SELECT 
    `Product Category`,
    ROUND(SUM(`Sales Revenue (USD)`), 2) AS total_revenue
FROM retail_sales_staging
GROUP BY `Product Category`
ORDER BY total_revenue DESC;

-- 2.3.5. Sales trend by `Store Location`

SELECT 
    `Store Location`,
    ROUND(SUM(`Sales Revenue (USD)`), 2) AS total_revenue
FROM retail_sales_staging
GROUP BY `Store Location`
ORDER BY total_revenue DESC
LIMIT 5;
