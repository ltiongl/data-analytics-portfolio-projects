-- E-Commerce Electronics Store Data Analysis
-- https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store/data

USE ecommerce_electronics_store;

SELECT * FROM `events_updated`
LIMIT 100;

-- 2. Data Exploration

-- 2.1. Revenue

-- Total revenue by month

SELECT 
	DATE_FORMAT(`event_time`, '%Y-%m') AS `year-month`,
	ROUND(SUM(price), 2) AS total_revenue
FROM `events_updated`
WHERE `event_type` = 'purchase'
GROUP BY `year-month`
ORDER BY total_revenue DESC;

-- Within the 5 months, '2021-01' has the highest revenue: 1487263.82.
-- Total revenue increased from '2020-10' to '2021-01', ad slightly drop in '2021-02'.

-- Total revenue by month and category

SELECT 
	DATE_FORMAT(`event_time`, '%Y-%m') AS `year-month`,
    `category`,
	ROUND(SUM(price), 2) AS total_revenue
FROM `events_updated`
WHERE `event_type` = 'purchase'
GROUP BY `year-month`, `category`
ORDER BY `year-month`, total_revenue DESC;

-- Computers and electronics are at the top ranking of revenue every month.

-- Total revenue by hour

SELECT 
	HOUR(`event_time`) AS `hour`,
	ROUND(SUM(price), 2) AS total_revenue
FROM `events_updated`
WHERE `event_type` = 'purchase'
GROUP BY `hour`
ORDER BY total_revenue DESC;

-- The top purchase hours are at hour 11, 10, 12. The lowest are 0, 2, 1.

-- Total revenue by hour for each month

WITH cte_ranking AS (
	SELECT
		DATE_FORMAT(`event_time`, '%Y-%m') AS `year-month`,
		HOUR(`event_time`) AS `hour`,
		ROUND(SUM(price), 2) AS total_revenue,
		RANK() OVER (PARTITION BY DATE_FORMAT(`event_time`, '%Y-%m') ORDER BY SUM(price) DESC) AS rank_desc,
        RANK() OVER (PARTITION BY DATE_FORMAT(`event_time`, '%Y-%m') ORDER BY SUM(price) ASC) AS rank_asc
	FROM `events_updated`
	WHERE `event_type` = 'purchase'
	GROUP BY `year-month`, `hour`
),
cte_top_3 AS (
	SELECT *
	FROM cte_ranking
    WHERE rank_desc <= 3
),
cte_bottom_3 AS (
	SELECT *
	FROM cte_ranking
    WHERE rank_asc <= 3
)
SELECT
	t.`year-month` AS `year-month`,
	t.`hour` AS `hour (top_ranking)`,
	t.total_revenue AS total_revenue_top,
    b.`hour` AS `hour (bottom_ranking)`,
	b.total_revenue AS total_revenue_bottom
FROM
	cte_top_3 t
		JOIN
	cte_bottom_3 b ON t.`year-month` = b.`year-month` AND t.rank_desc = b.rank_asc
ORDER BY t.`year-month`, t.rank_desc;

-- Most purchase were done in day time, while midnight has the least purchase in every month.

-- 2.2. Conversion Rate (CR)

-- Determine `event_type`

SELECT
	DISTINCT `event_type`
FROM `events_updated`;

-- There are 'view', 'cart' and 'puchase' event types.

WITH cte_purchase AS (
SELECT
	`user_session`,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `user_session`
)
SELECT
	ROUND(SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / COUNT(`user_session`) * 100.0, 2) AS conversion_rate
FROM cte_purchase;

-- Session-based conversion rate is 5%.

WITH cte_purchase AS (
SELECT
	`user_id`,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_id` IS NOT NULL
GROUP BY `user_id`
)
SELECT
	ROUND(SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / COUNT(`user_id`) * 100.0, 2) AS conversion_rate
FROM cte_purchase;

-- User-based conversion rate is 5.27%

-- Conversion rate by month

WITH cte_purchase AS (
SELECT
	DATE_FORMAT(`event_time`, '%Y-%m') AS `year-month`,
	`user_session`,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `year-month`, `user_session`
)
SELECT
	`year-month`,
	ROUND(SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / COUNT(`user_session`) * 100.0, 2) AS conversion_rate
FROM cte_purchase
GROUP BY `year-month`;

-- '2020-10': 4.32%, '2020-11': 4.51%, '2020-12': 5.06%, '2021-01': 5.54%, '2021-02': 5.56%

-- 2.3. Average Order Value (AOV)

WITH cte_purchase AS (
SELECT
	`user_session`,
    SUM(CASE WHEN `event_type` = 'purchase' THEN `price` ELSE 0 END) AS revenue,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `user_session`
)
SELECT
    ROUND(SUM(revenue) / SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END), 2) AS average_order_value
FROM cte_purchase;

-- Average order value is 212.07

-- Average Order Value (AOV) by month

WITH cte_purchase AS (
SELECT
	DATE_FORMAT(`event_time`, '%Y-%m') AS `year-month`,
	`user_session`,
    SUM(CASE WHEN `event_type` = 'purchase' THEN `price` ELSE 0 END) AS revenue,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `year-month`, `user_session`
)
SELECT
	`year-month`,
    ROUND(SUM(revenue) / SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END), 2) AS average_order_value
FROM cte_purchase
GROUP BY `year-month`;

-- '2020-10': 135.46, '2020-11': 160.54, '2020-12': 187.2, '2021-01': 272.84, '2021-02': 278.18

-- 2.4. Cart Abandonment Rate (CAR)

WITH cte_purchase AS (
SELECT
	`user_session`,
    SUM(CASE WHEN `event_type` = 'cart' THEN 1 ELSE 0 END) AS num_cart,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `user_session`
)
SELECT
	ROUND((1 - (SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN num_cart > 0 THEN 1 ELSE 0 END))) * 100.0, 2) AS cart_abandonment_rate
FROM cte_purchase;

-- Cart abondentment rate is 41.04%

-- Cart Abandonment Rate (CAR) by month

WITH cte_purchase AS (
SELECT
	DATE_FORMAT(`event_time`, '%Y-%m') AS `year-month`,
	`user_session`,
    SUM(CASE WHEN `event_type` = 'cart' THEN 1 ELSE 0 END) AS num_cart,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `year-month`, `user_session`
)
SELECT
	`year-month`,
	ROUND((1 - (SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN num_cart > 0 THEN 1 ELSE 0 END))) * 100.0, 2) AS cart_abandonment_rate
FROM cte_purchase
GROUP BY `year-month`;

-- '2020-10': 39.51%, '2020-11': 39.81%, '2020-12': 40.49%, '2021-01': 42.79%, '2021-02': 42.19%

-- 2.4. Create new table for total revenue, CR, AOV, CAR

CREATE TABLE `kpi` (
	`Year-Month` VARCHAR(10),
    `Total Revenue` DOUBLE,
    `Conversion Rate` FLOAT,
    `Average Order Value` FLOAT,
    `Cart Abandonment Rate` FLOAT
);

INSERT INTO `kpi`
WITH cte_purchase AS (
SELECT
	DATE_FORMAT(`event_time`, '%Y-%m') AS `Year-Month`,
	`user_session`,
    SUM(CASE WHEN `event_type` = 'purchase' THEN `price` ELSE 0 END) AS revenue,
    SUM(CASE WHEN `event_type` = 'cart' THEN 1 ELSE 0 END) AS num_cart,
	SUM(CASE WHEN `event_type` = 'purchase' THEN 1 ELSE 0 END) AS num_purchase
FROM `events_updated`
WHERE `user_session` IS NOT NULL
GROUP BY `Year-Month`, `user_session`
)
SELECT
	`Year-Month`,
    ROUND(SUM(revenue), 2) AS `Total Revenue`,
	ROUND(SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / COUNT(`user_session`) * 100.0, 2) AS `Conversion Rate`,
    ROUND(SUM(revenue) / SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END), 2) AS `Average Order Value`,
    ROUND((1 - (SUM(CASE WHEN num_purchase > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN num_cart > 0 THEN 1 ELSE 0 END))) * 100.0, 2) AS `Cart Abandonment Rate`
FROM cte_purchase
GROUP BY `Year-Month`;

SELECT * 
FROM `kpi`;

-- 2.5. Prepare `event_updated` table for Tableau

CREATE TABLE `events_export` AS
SELECT * FROM `events_updated`;

SELECT * FROM `events_export`;

UPDATE `events_export`
SET `price` = 0 
WHERE `event_type` != 'purchase';

ALTER TABLE `events_export`
DROP COLUMN `product_id`;

ALTER TABLE `events_export`
DROP COLUMN `user_id`;

-- Data exploration has completed.
