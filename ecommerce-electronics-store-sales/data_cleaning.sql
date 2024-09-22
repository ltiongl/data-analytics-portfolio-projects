-- E-Commerce Electronics Store Data Analysis
-- https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store/data

USE ecommerce_electronics_store;

SELECT * FROM `events`
LIMIT 5;

-- 1. Data Cleaning

CREATE TABLE `events_staging` LIKE `events`;

INSERT INTO `events_staging`
SELECT * FROM `events`
LIMIT 5;

-- 1.1. Verify Duplicates

WITH cte_duplicates AS (
	SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY `event_time`, `event_type`, `category_id`, `category_code`, 
                                       `brand`, `price`, `user_id`, `user_session`) AS row_num
    FROM `events_staging`
)
SELECT
    COUNT(*) AS duplicate_count
FROM cte_duplicates
WHERE row_num > 1;

SELECT COUNT(*) AS count  
FROM `events_staging`;

-- There are a total of 884 duplicates out of 885129 data.

-- Determine duplicates

WITH cte_duplicates AS (
	SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY `event_time`, `event_type`, `category_id`, `category_code`, 
                                       `brand`, `price`, `user_id`, `user_session`) AS row_num
    FROM `events_staging`
)
SELECT
    *
FROM cte_duplicates
WHERE row_num > 1;

-- Verify the duplicates validation randomly

SELECT
	*
FROM `events_staging`
WHERE `event_time` = '2021-02-03 04:10:24 UTC' AND
	  `event_type` = 'view' AND 
      `product_id` = '695598' AND 
      `category_id` = '2144415921169498184' AND
      `category_code` = '' AND
      `brand` = '' AND
      `price` = '13.49' AND 
      `user_id` = '1515915625599506498' AND 
      `user_session` = 'mTIBjTAUJb';

-- Duplicates are valid. There are 2 duplicates of this data as reported.

-- Remove duplicates

CREATE TABLE `events_updated` AS
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY `event_time`, `event_type`, `category_id`, `category_code`, 
									`brand`, `price`, `user_id`, `user_session`) AS row_num
FROM `events_staging`;

DELETE FROM `events_updated`
WHERE row_num > 1;

ALTER TABLE `events_updated`
DROP COLUMN row_num;

-- Duplicated-free table is renamed to `events_updated`.

-- Verify duplicates removal

WITH cte_duplicates AS (
	SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY `event_time`, `event_type`, `category_id`, `category_code`, 
                                       `brand`, `price`, `user_id`, `user_session`) AS row_num
    FROM `events_updated`
)
SELECT
    *
FROM cte_duplicates
WHERE row_num > 1;	

SELECT COUNT(*) AS count
FROM `events_updated`;

SELECT * 
FROM `events_updated`
LIMIT 5;
    
-- Duplicates have been cleaned. Cleaned table has 884245 data.

-- 1.2. Handle null values / blank values
-- Verify null data

SELECT * 
FROM `events_updated`
WHERE
    `event_time` IS NULL OR
    `event_type` IS NULL OR 
    `product_id` IS NULL OR 
    `category_id` IS NULL OR
	`category_code` IS NULL OR 
    `brand` IS NULL OR 
    `price` IS NULL OR
    `user_id` IS NULL OR
    `user_session` IS NULL;
    
-- No null data.

-- Verify empty data

SELECT 
	SUM(CASE WHEN `event_time` = '' THEN 1 ELSE 0 END) AS event_time_blank_count,
    SUM(CASE WHEN `event_type` = '' THEN 1 ELSE 0 END) AS event_type_blank_count,
    SUM(CASE WHEN `product_id` = '' THEN 1 ELSE 0 END) AS product_id_blank_count,
    SUM(CASE WHEN `category_id` = '' THEN 1 ELSE 0 END) AS category_id_blank_count,
    SUM(CASE WHEN `category_code` = '' THEN 1 ELSE 0 END) AS category_code_blank_count,
    SUM(CASE WHEN `brand` = '' THEN 1 ELSE 0 END) AS brand_blank_count,
    SUM(CASE WHEN `user_id` = '' THEN 1 ELSE 0 END) AS user_id_blank_count,
    SUM(CASE WHEN `user_session` = '' THEN 1 ELSE 0 END) AS user_session_blank_count
FROM `events_updated`; 

-- `category_code` has 236039 blanks, `brand` has 212164 blanks, `user_session` has 162 blanks. 

-- Create a column `category` to record only the main category.
-- Extract the main `category_code` to new column `category`

ALTER TABLE `events_updated`
ADD COLUMN `category` VARCHAR(255);

UPDATE `events_updated`
SET `category` = SUBSTRING_INDEX(`category_code`, '.', 1);

SELECT * FROM `events_updated`
LIMIT 5;

-- Fill in `category` blanks as 'others'

UPDATE `events_updated`
SET `category` = 'others'
WHERE `category` = '';

SELECT 
	COUNT(`category`) AS count
FROM `events_updated`
WHERE `category` = 'others';

-- Remove unused columns: `category_id`, `category_code`, `brand`

ALTER TABLE `events_updated`
DROP COLUMN `category_id`;

ALTER TABLE `events_updated`
DROP COLUMN `category_code`;

ALTER TABLE `events_updated`
DROP COLUMN `brand`;

SELECT *
FROM `events_updated`
LIMIT 100;

SELECT 
	COUNT(DISTINCT `user_id`) AS user_id_count,
    COUNT(DISTINCT `user_session`) AS user_session_count
FROM `events_updated`;

-- Fill in the blanks in `user_session` with NULL

UPDATE `events_updated`
SET `user_session` = NULL
WHERE `user_session` = '';

SELECT
	SUM(CASE WHEN `user_session` IS NULL THEN 1 ELSE 0 END) AS null_count
FROM `events_updated`;

-- 1.3. Fix data type

DESCRIBE `events_updated`;

-- `event_time` is in 'TEXT' data type ('2020-09-24 11:57:06 UTC'), it needs to be changed to 'DATETIME' data type. 

UPDATE `events_updated`
SET `event_time` = STR_TO_DATE(SUBSTRING_INDEX(`event_time`, ' ', 2), '%Y-%m-%d %H:%i:%s');

ALTER TABLE `events_updated`
MODIFY COLUMN `event_time` DATETIME;

DESCRIBE `events_updated`;

-- Data type of `event_time` is now 'DATETIME'.

-- 1.4. Verify data date range

-- Check `event_time` range

SELECT
	MIN(DATE(`event_time`)) AS min_date,
    MAX(DATE(`event_time`)) AS max_date
FROM `events_updated`;

-- Date ranges from '2020-09-24' to '2021-02-28'.

-- '2020-09' only has data from 24th onward. Remove data from '2020-09' for fair comparison across the months.

DELETE FROM `events_updated` 
WHERE DATE_FORMAT(`event_time`, '%Y-%m') = '2020-09';

-- Verify change

SELECT
	MIN(DATE(`event_time`)) AS min_date,
    MAX(DATE(`event_time`)) AS max_date
FROM `events_updated`;

-- Date ranges from '2020-10'01' to '2021-02-28'.

-- Data cleaning has completed.