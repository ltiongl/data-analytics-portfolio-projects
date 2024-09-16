# Retail Sales Analysis

## Project Overview
This project analyses the retail sales using two different approaches:  
1. Data exploration using `MySQL` and data visualization using `Tableau Dashboard`   
2. Data exploration and model building using `Python`  

These approches explore the retail sales data from different perspectives, providing a more comprehensive understanding of the analysis.

## Key Objectives
* **Marketing analysis**: evaluate the impact of marketing spend and discount strategy on sales.
* **Seasonal trend analysis**: examine how holiday and days in a week impact sales.
* **Predictive modeling**: build and evaluate models to forecast future sales based on historical data.
* **Visualization dashboard**: create visualization dashboard to summarize the analysis findings.

## Software and Tools
* **Python version**: `Python 3.9.10`  
* **Python packages**: `pandas`, `matplotlib`, `seaborn`, `sklearn`   
* **Tableau**: `Tableau Desktop Public Edition 2024.2.0`    
* **MySQL Workbench**: `MySQL Workbench Version 8.0.38`  

## Data Source
The dataset is obtained from `Kaggle`: [Retail Sales Data with Seasonal Trends & Marketing](https://www.kaggle.com/datasets/abdullah0a/retail-sales-data-with-seasonal-trends-and-marketing).  

---

## Table of Contents
* [Approach 1: Analyzing Data using MySQL + Tableau](#approach-1-analyzing-data-using-mysql--tableau)
  - [Data Cleaning](#data-cleaning)
  - [Data Exploration / EDA](#data-exploration--eda)
  - [Data Visualization](#data-visualization)
  - [Summary of Findings from MySQL and Tableau](#summary-of-findings-from-mysql-and-tableau-analysis)
* [Approach 2: Analyzing Data using Python](#approach-2-analyzing-data-using-python)
  - [Data Cleaning and Initial Data Exploration](#data-cleaning-and-initial-data-exploration)
  - [Data Exploration / EDA](#data-exploration--eda-1)
  - [Data Modeling](#data-modeling)
  - [Summary of Findings from Python](#summary-of-findings-from-python)
* [Conclusion](#conclusion)
    
---

## Approach 1: Analyzing Data using MySQL + Tableau

### Data Cleaning
#### 1. Verify duplicated lines
```mysql 
WITH cte_duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY `Store ID`, `Product ID`, `Date`, `Units Sold`, `Sales Revenue (USD)`,
                                       `Discount Percentage`, `Marketing Spend (USD)`, `Store Location`, 
                                       `Product Category`, `Day of the Week`,`Holiday Effect`) AS row_num
    FROM retail_sales_staging
)
SELECT
    * 
FROM cte_duplicates
WHERE row_num > 1;
```
> There is no duplicated data. 

#### 2. Standardize the data
```mysql
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
```
> The data doesn't have stadardization issue, except the data type of `Date` is modified to `DATE` format.

#### 3. Verify null data  
```mysql
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
```
> Null data doesn't exist.

#### 4. Data cleaning summary
* The dataset doesn't contain any duplicated or null data.
* There is no standardization issue in the dataset.
* The data type of `Date` is changed to `DATE` data type.

### Data Exploration / EDA
The data exploration focuses on analysing the effectiveness of marketing spend and discount strategy.

#### 1. Effectiveness of marketing spend
The effectiveness of marketing spend is evaluated across the entire dataset, and further analyzed by product category, day of the week, holiday effects, and year.

#### 1.1 Marketing spend impact on the entire sales revenue 
```mysql
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
```
<img width="54" alt="image" src="https://github.com/user-attachments/assets/fa1f0a61-d967-4d58-b15f-a2a0fd5d73a9">

#### 1.2. Marketing spend impact on sales revenue by product category
```mysql
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
```
<img width="193" alt="image" src="https://github.com/user-attachments/assets/ae44caea-bda9-40a5-86e3-ec3a79293ec6">

#### 1.3. Marketing spend impact on sales revenue by day of the week
```mysql
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
```
<img width="183" alt="image" src="https://github.com/user-attachments/assets/dc79ccb8-5fc5-412c-8ec9-32d37de38670">

#### 1.4. Marketing spend impact on sales revenue by holiday effect
```mysql
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
```
<img width="166" alt="image" src="https://github.com/user-attachments/assets/0e5a6f54-25e9-4d1f-8b23-0fac7f4335c7">

#### 1.5. Marketing spend impact on sales revenue by year
```mysql
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
```
<img width="100" alt="image" src="https://github.com/user-attachments/assets/4b1f803b-7731-404d-a967-a8ce351e7d11">

#### 1.6. Effectiveness of marketing spend summary
* The ROMI (Return on Marketing Investment) metric only shows positive results when marketing spend is applied during holidays, suggesting that seasonal marketing is effective.
* The ROMI result for 2024 is not considered, as there is only one day of data available for that year.

#### 2. Effectiveness of discount strategy
The effectiveness of discount strategy is evaluated across the entire dataset, and further analyzed by product category, day of the week, holiday effects, and year.

#### 2.1. Discount impact on the entire sales revenue
```mysql
SELECT
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging;
```

<img width="451" alt="image" src="https://github.com/user-attachments/assets/15c4e215-8d74-4992-be27-6f452a4923d9">

#### 2.2. Discount impact on sales revenue by product category
```mysql
SELECT
    `Product Category`,
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging
GROUP BY `Product Category`
ORDER BY avg_revenue_with_discount DESC;
```
<img width="591" alt="image" src="https://github.com/user-attachments/assets/1a807be4-b2ff-4475-8784-5eafc692d860">

#### 2.3. Discount impact on sales revenue by day of the week
```mysql
SELECT
    `Day of the Week`,
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging
GROUP BY `Day of the Week`
ORDER BY avg_revenue_with_discount DESC;
```
<img width="580" alt="image" src="https://github.com/user-attachments/assets/b0f169bb-6e3a-4b55-9d33-c458f07e431a">

#### 2.4. Discount impact on sales revenue by holiday effect
```mysql
SELECT
    `Holiday Effect`,
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging
GROUP BY `Holiday Effect`
ORDER BY avg_revenue_with_discount DESC;
```
<img width="564" alt="image" src="https://github.com/user-attachments/assets/e1928d12-adba-4f61-b61e-8cc2c6470314">

#### 2.5. Effectiveness of discount strategy summary
* Days with a discount strategy exhibit lower average sales revenue compared to days without a discount strategy across all metrics.
* The discount strategy does not have a positive impact on sales revenue.
  
#### 3. Sales revenue trend
This section explores the sales revenue trend by year, holiday effect, day of the week, product category, and store location.

#### 3.1. Sales revenue trend over years
```mysql
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
```
<img width="163" alt="image" src="https://github.com/user-attachments/assets/b7f800dd-6054-498e-9474-3537a2304ff4">
<img width="190" alt="image" src="https://github.com/user-attachments/assets/92721a25-b1ce-4424-a5fe-5dad368c05ba">

#### 3.2. Seasonal sales revenue trend
```mysql
SELECT
    `Holiday Effect`,
    ROUND(AVG(`Sales Revenue (USD)`), 2) AS average_revenue
FROM retail_sales_staging
GROUP BY `Holiday Effect`
ORDER BY average_revenue DESC;
```
<img width="253" alt="image" src="https://github.com/user-attachments/assets/7c359dcb-1977-42ea-acc5-f55b94b60807">

#### 3.3. Sales revenue trend by day of the week
```mysql
SELECT
    `Day of the Week`,
    ROUND(AVG(`Sales Revenue (USD)`), 2) AS average_revenue
FROM retail_sales_staging
GROUP BY `Day of the Week`
ORDER BY average_revenue DESC;
```
<img width="270" alt="image" src="https://github.com/user-attachments/assets/a22294d7-f56e-4323-ab93-6a69ab12ce24">


#### 3.4. Sales revenue trend by product category
```mysql
SELECT
    `Product Category`,
    ROUND(SUM(`Sales Revenue (USD)`), 2) AS total_revenue
FROM retail_sales_staging
GROUP BY `Product Category`
ORDER BY total_revenue DESC;
```
<img width="256" alt="image" src="https://github.com/user-attachments/assets/e4c886eb-2e3e-4cbe-bf96-6500b22d34cf">
   
#### 3.5. Sales revenue trend by store location
```mysql
SELECT 
    `Store Location`,
    ROUND(SUM(`Sales Revenue (USD)`), 2) AS total_revenue
FROM retail_sales_staging
GROUP BY `Store Location`
ORDER BY total_revenue DESC
LIMIT 5;
```
<img width="235" alt="image" src="https://github.com/user-attachments/assets/c31faad1-547a-4015-921a-3af3fc45615e">

#### 3.6. Sales revenue trend summary
* Sales revenue for 2022 and 2023 remained relatively consistent, indicating stable performance across both years.
* Sales revenue for 2024 is excluded from the analysis due to the limited data, which only includes the first day of the year.
* The seasonal sales trend indicates that holidays generate nearly double the sales revenue compared to non-holiday periods.
* Sales revenue is the highest on Sundays and Saturdays, outperforming weekdays.
* Electronics and furniture are the top contributors to sales revenue, followed by clothing and groceries.
* The stores in Congo, Korea, and Anguilla lead in sales revenue generation.

#### 4. Data exploration summary
* The analysis reveals that the ROMI (Return on Marketing Investment) metric is positively impacted only when marketing spend is allocated during holidays, indicating that seasonal marketing strategies are effective. 
* Conversely, the implementation of a discount strategy consistently results in lower average sales revenue compared to periods without discounts, suggesting that discount strategies do not positively influence sales revenue.

### Data Visualization
The data is visualized in an interactive Tableau dashboard, which can be explored [here](https://public.tableau.com/app/profile/lily.tiong/viz/retail_sales_17264041202470/SalesDashboard?publish=yes).     
  
The dashboard presents Key Performance Indicators (KPIs) of `Total Sales Revenue` and `Total Marketing Spend`, with a performance comparison between 2022 and 2023.   
   
The `Total Sales Revenue` KPI indicates a nearly flat growth rate, with sales revenue showing almost no increase between 2022 and 2023. In contrast, total marketing spend decreased by approximately 0.04% in 2023 compared to 2022.   
   
The overall ROMI (Return on Marketing Investment) metric is negative for both years. In 2022, ROMI was positive for electronics, during holidays, and on Sundays and Tuesdays. On the other hand, in 2023, ROMI was positive for clothing, and on Thursdays, Fridays, and Saturdays. There is no consistent trend in ROMI across the two years.  
   
Regarding the impact of discount strategies, only the holiday period in 2023 showed a slight improvement in sales revenue, though the increase was not substantial.    

<kbd>
<img src="https://github.com/user-attachments/assets/5b5f9313-9980-4504-8b9a-63a03073989b">
</kbd> 
    
<kbd>
<img src="https://github.com/user-attachments/assets/8720141f-3b18-4579-938a-ed79cfdd7c2c">
</kbd> 

### Summary of Findings from MySQL and Tableau Analysis
* The analysis indicates that while marketing spend and discount strategies occasionally yield positive results in specific instances, their overall impact on sales revenue is minimal and lacks consistency over time. This suggests that neither marketing spend nor discount strategies are effectively driving substantial increases in sales revenue.  
* However, given that the data is limited to only two years, these conclusions may not be entirely conclusive. Notably, marketing spend during holidays appears to have a more favorable impact on sales revenue, suggesting that focusing on holiday promotions could be a promising strategy for further exploration.   

## Approach 2: Analyzing Data using Python

### Data Cleaning and Initial Data Exploration
```python
df.info()
```
    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 30000 entries, 0 to 29999
    Data columns (total 11 columns):
     #   Column                 Non-Null Count  Dtype  
    ---  ------                 --------------  -----  
     0   Store ID               30000 non-null  object 
     1   Product ID             30000 non-null  int64  
     2   Date                   30000 non-null  object 
     3   Units Sold             30000 non-null  int64  
     4   Sales Revenue (USD)    30000 non-null  float64
     5   Discount Percentage    30000 non-null  int64  
     6   Marketing Spend (USD)  30000 non-null  int64  
     7   Store Location         30000 non-null  object 
     8   Product Category       30000 non-null  object 
     9   Day of the Week        30000 non-null  object 
     10  Holiday Effect         30000 non-null  bool   
    dtypes: bool(1), float64(1), int64(4), object(5)
    memory usage: 2.3+ MB

#### 1. Verify null data
```python
df.isnull().sum()
```
    Store ID                 0
    Product ID               0
    Date                     0
    Units Sold               0
    Sales Revenue (USD)      0
    Discount Percentage      0
    Marketing Spend (USD)    0
    Store Location           0
    Product Category         0
    Day of the Week          0
    Holiday Effect           0
    dtype: int64

> There is no null data.

#### 2. Verify duplicated lines
```python
df.duplicated().sum()
```
    np.int64(0)
    
> There is no duplicated data.

#### 3. Fix the data
```python
# Change `Date` to Date format
df['Date'] = pd.to_datetime(df['Date'], format='%Y-%m-%d')
```
```python
# Verify `Date` data type
df.info()
```
    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 30000 entries, 0 to 29999
    Data columns (total 11 columns):
     #   Column                 Non-Null Count  Dtype         
    ---  ------                 --------------  -----         
     0   Store ID               30000 non-null  object        
     1   Product ID             30000 non-null  int64         
     2   Date                   30000 non-null  datetime64[ns]
     3   Units Sold             30000 non-null  int64         
     4   Sales Revenue (USD)    30000 non-null  float64       
     5   Discount Percentage    30000 non-null  int64         
     6   Marketing Spend (USD)  30000 non-null  int64         
     7   Store Location         30000 non-null  object        
     8   Product Category       30000 non-null  object        
     9   Day of the Week        30000 non-null  object        
     10  Holiday Effect         30000 non-null  bool          
    dtypes: bool(1), datetime64[ns](1), float64(1), int64(4), object(4)
    memory usage: 2.3+ MB

> `Date` data type has been updated to `datetime64`.

#### 4. Initial data exploration
```python
# Initial Data Exploration
df.head()
```
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Store ID</th>
      <th>Product ID</th>
      <th>Date</th>
      <th>Units Sold</th>
      <th>Sales Revenue (USD)</th>
      <th>Discount Percentage</th>
      <th>Marketing Spend (USD)</th>
      <th>Store Location</th>
      <th>Product Category</th>
      <th>Day of the Week</th>
      <th>Holiday Effect</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Spearsland</td>
      <td>52372247</td>
      <td>2022-01-01</td>
      <td>9</td>
      <td>2741.69</td>
      <td>20</td>
      <td>81</td>
      <td>Tanzania</td>
      <td>Furniture</td>
      <td>Saturday</td>
      <td>False</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Spearsland</td>
      <td>52372247</td>
      <td>2022-01-02</td>
      <td>7</td>
      <td>2665.53</td>
      <td>0</td>
      <td>0</td>
      <td>Mauritania</td>
      <td>Furniture</td>
      <td>Sunday</td>
      <td>False</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Spearsland</td>
      <td>52372247</td>
      <td>2022-01-03</td>
      <td>1</td>
      <td>380.79</td>
      <td>0</td>
      <td>0</td>
      <td>Saint Pierre and Miquelon</td>
      <td>Furniture</td>
      <td>Monday</td>
      <td>False</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Spearsland</td>
      <td>52372247</td>
      <td>2022-01-04</td>
      <td>4</td>
      <td>1523.16</td>
      <td>0</td>
      <td>0</td>
      <td>Australia</td>
      <td>Furniture</td>
      <td>Tuesday</td>
      <td>False</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Spearsland</td>
      <td>52372247</td>
      <td>2022-01-05</td>
      <td>2</td>
      <td>761.58</td>
      <td>0</td>
      <td>0</td>
      <td>Swaziland</td>
      <td>Furniture</td>
      <td>Wednesday</td>
      <td>False</td>
    </tr>
  </tbody>
</table>
</div>

```python
df.describe()
```
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Product ID</th>
      <th>Date</th>
      <th>Units Sold</th>
      <th>Sales Revenue (USD)</th>
      <th>Discount Percentage</th>
      <th>Marketing Spend (USD)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>3.000000e+04</td>
      <td>30000</td>
      <td>30000.000000</td>
      <td>30000.000000</td>
      <td>30000.000000</td>
      <td>30000.000000</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>4.461294e+07</td>
      <td>2022-12-31 15:51:24.480000256</td>
      <td>6.161967</td>
      <td>2749.509593</td>
      <td>2.973833</td>
      <td>49.944033</td>
    </tr>
    <tr>
      <th>min</th>
      <td>3.636541e+06</td>
      <td>2022-01-01 00:00:00</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>2.228600e+07</td>
      <td>2022-07-02 00:00:00</td>
      <td>4.000000</td>
      <td>882.592500</td>
      <td>0.000000</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>4.002449e+07</td>
      <td>2023-01-01 00:00:00</td>
      <td>6.000000</td>
      <td>1902.420000</td>
      <td>0.000000</td>
      <td>1.000000</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>6.559352e+07</td>
      <td>2023-07-03 00:00:00</td>
      <td>8.000000</td>
      <td>3863.920000</td>
      <td>0.000000</td>
      <td>100.000000</td>
    </tr>
    <tr>
      <th>max</th>
      <td>9.628253e+07</td>
      <td>2024-01-01 00:00:00</td>
      <td>56.000000</td>
      <td>27165.880000</td>
      <td>20.000000</td>
      <td>199.000000</td>
    </tr>
    <tr>
      <th>std</th>
      <td>2.779759e+07</td>
      <td>NaN</td>
      <td>3.323929</td>
      <td>2568.639288</td>
      <td>5.974530</td>
      <td>64.401655</td>
    </tr>
  </tbody>
</table>
</div>

```python
df.shape
```
    (30000, 11)
    
```python
df.columns
```
    Index(['Store ID', 'Product ID', 'Date', 'Units Sold', 'Sales Revenue (USD)',
           'Discount Percentage', 'Marketing Spend (USD)', 'Store Location',
           'Product Category', 'Day of the Week', 'Holiday Effect'],
          dtype='object')

Check number of item in the categorical columns.
```python
df['Store ID'].nunique()
```
    1
```python
df['Store Location'].nunique()
```
    243
```python
df['Product ID'].nunique()
```
    42
```python
df['Product Category'].nunique()
```
    4
    
#### 5. Data cleaning summary
*  No null value or duplicated value is found in the dataset.
*  `Date` column data type is updated to `datetime64`.
*  There are 30,000 rows and 11 columns in the dataset.
*  There is only one unique value in `Store ID`, hence the column can be ignored and dropped.

```python
# Drop column 'Store ID'
df = df.drop('Store ID', axis=1)
```

### Data Exploration / EDA
The data is analyzed through univariate, bivariate, multivariate and time series approaches, covering both numerical and categorical variables.   

#### 1. Prepration
```python
# Import libraries
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
```
```python
df.columns
```
    Index(['Product ID', 'Date', 'Units Sold', 'Sales Revenue (USD)',
           'Discount Percentage', 'Marketing Spend (USD)', 'Store Location',
           'Product Category', 'Day of the Week', 'Holiday Effect'],
          dtype='object')

```python
# Identify significant numerical and categorical variables
numerical_col = ['Units Sold', 'Sales Revenue (USD)', 'Marketing Spend (USD)']
categorical_col = ['Product Category', 'Discount Percentage', 'Day of the Week', 'Holiday Effect']
```
```python
# Set plot style
plt.style.use('ggplot')
```

#### 2. Univariate analysis

#### 2.1. Distribution of numerical variables
```python
for col in numerical_col:
    plt.figure(figsize=(10, 5))
    sns.histplot(df[col], kde=True, bins=30)
    plt.title(f'Distribution of {col}')
    plt.xlabel(col)
    plt.ylabel('Count')
    plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/7059c957-0387-46fb-83d4-9d1c35c0bfb8">
</kbd> 
<br> <br>  
<kbd>
<img src="https://github.com/user-attachments/assets/2c4a084e-9afc-4ac9-96ad-011905f3c2dc">
</kbd>    
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/6d0946b0-8f68-4dcf-bf98-f9916c221dd3">
</kbd>
    
#### 3. Bivariate analysis

#### 3.1. Box plots of numerical variables vs. categorical variables
```python
for col_c in categorical_col:
    for col_n in numerical_col:
        plt.figure(figsize=(10,5)) 
        if col_c == 'Day of the Week' or col_c == 'Discount Percentage':
            sns.boxplot(x=df[col_c], y=df[col_n], palette='mako', hue=df[col_c], legend=False)
        else:
            median_values = df.groupby(col_c)[col_n].median()
            sorted_categories = median_values.sort_values(ascending=False).index
            sns.boxplot(x=df[col_c], y=df[col_n], order=sorted_categories, palette='mako', hue=df[col_c], legend=False)
        plt.title(f'{col_n} by {col_c}')
        plt.xlabel(col_c)
        plt.ylabel(col_n)
        plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/aaa76089-3a3b-4f8c-a11d-d4e51254b6fb">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/aedf6c8f-9034-4bea-ab52-39dd2a417ea8">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/12ce1b77-da0b-4176-a599-d2f2dd540819">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/90fa0a0f-c32e-42b4-96c6-a2e1d0e699e0">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/714e6763-6ac9-4e44-a6cf-02aa53de0891">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/170a44b4-a35e-421c-9343-5e12625029d2">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/414098f0-0b2a-456a-a8b0-ec85912152a6">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/4974c8ef-7eea-418e-8e46-7e4fe4d2531a">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/c628a116-17aa-4c48-a2b6-6b9629d36a61">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/2b44a1fe-f3d6-403e-bda6-0ee6a89b8c9f">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/35bf54fa-8afa-41f5-a05d-c0ffe9e94472">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/85cf152b-c018-41fb-b352-c11e25446098">
</kbd>

#### 4. Multivariate analysis
#### 4.1. Pairplot of numerical variales
```python
plt.figure(figsize=(10,5))
sns.pairplot(df[numerical_col])
plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/4a51af65-f1c3-46ea-9672-7e44bc4e3f1f">
</kbd>

#### 4.2. Heatmap of numerical variables
```python
# corr = df.select_dtypes(include=[np.number])
corr = df[numerical_col].corr()
plt.figure(figsize=(10, 5))
# Generate a custom diverging colormap
cmap = sns.diverging_palette(20, 230, as_cmap=True)
sns.heatmap(corr, annot=True, cmap=cmap, vmin=-1, fmt='.2f')
plt.title('Heatmap of Retail Sales')
plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/20df6623-7619-45df-aa41-2a3d485f3f52">
</kbd>

#### 5. Time series analysis
```python
# Analysis by month
for col in numerical_col:
    plt.figure(figsize=(15, 5))
    df['Year-Month'] = df['Date'].dt.to_period('M')
    df_grouped = df.groupby('Year-Month')[col].sum().reset_index()
    df_grouped['Year-Month'] = df_grouped['Year-Month'].astype(str)
    
    # Exclude 2024 January because there is only one day data in that month
    df_grouped = df_grouped[:-1]
    sns.lineplot(data=df_grouped, x='Year-Month', y=col, marker='o')
    plt.title(f'{col} Trend')
    plt.xlabel('Year-Month')
    plt.ylabel(col)
    plt.xticks(rotation=45)
    plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/e98def7a-e6e4-4f68-b321-9f401213c3ad">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/570b3880-5c1e-49a1-8926-2a93fedf3c92">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/b591d886-1a0f-4251-ba46-589655448d01">
</kbd>

#### 6. Data exploration summary
* The distributions of `Units Sold`, `Sales Revenue (USD)`, and `Marketing Spend (USD)` are right-skewed.
* Among the product categories, `Electronics` leads with the highest units sold and sales revenue, followed by `Clothing`, `Furniture`, and `Groceries`.
* In terms of marketing spend, `Electronics` also tops the list, followed by `Groceries`, then `Clothing`, and `Furniture`.
* The discount percentage has minimal impact on both units sold and sales revenue.
* There is a slightly higher number of units sold and increased sales revenue on weekends (Saturday and Sunday) compared to weekdays, though the difference is not significant.
* Sales and units sold tend to perform better during holidays, whereas marketing spend appears unaffected by holidays.
* From the correlation analysis, only `Sales Revenue (USD)` and `Units Sold` show a notable linear relationship. `Marketing Spend (USD)` does not show a strong correlation with either `Sales Revenue (USD)` or `Units Sold`, suggesting that marketing spend has a limited impact on revenue. This is further supported by the heatmap, where `Marketing Spend (USD)` shows a near-zero correlation with both sales revenue and units sold.
* The time series analysis reveals that `Sales Revenue (USD)` reaches its lowest point in February, followed by a consistent rise, peaking in December, likely due to year-end seasonal events. Meanwhile, `Marketing Spend (USD)` also dips in February but remains relatively stable, fluctuating around $62,000 throughout the year.

### Data Modeling
#### 1. Data preprocessing
```python
# Define Libraries

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import MinMaxScaler, OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error

from sklearn.linear_model import LinearRegression, Lasso, Ridge
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.neighbors import KNeighborsRegressor
```
```python
# Define features and target variable
# 'Sales Revenue (USD)' and 'Units Sold' are target variables. 
#   Since 'Sales Revenue (USD)' is corrarelated with 'Sales Revenue (USD)' and 
#   'Units Sold' is not the main prediction target, 
#   only 'Sales Revenue (USD)' is defined as the target variable.

X = df[['Product ID','Store Location', 'Product Category', 'Day of the Week',
        'Discount Percentage', 'Marketing Spend (USD)', 'Holiday Effect']]
y = df['Sales Revenue (USD)']
```
```python
# Split data to train set and test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
```
```python
# Preprocess variables
numerical_col = ['Marketing Spend (USD)']
categorical_col = ['Product ID', 'Store Location', 'Discount Percentage', 'Product Category', 'Day of the Week']
bool_col = ['Holiday Effect']

preprocessor = ColumnTransformer (
    transformers = [
        ('num', MinMaxScaler(), numerical_col),
        ('bool', 'passthrough', bool_col),
        ('cat', OneHotEncoder(), categorical_col)
    ]
)
```
#### 2. Model building and running

```python
# Define function for data modeling

results = []

def evaluate_model(model, X_train, y_train, X_test, y_test, model_name):
    pipeline = Pipeline(steps=[('preprocessor', preprocessor), ('model', model)])

    # Train data
    pipeline.fit(X_train, y_train)

    # Predict using test data
    y_pred = pipeline.predict(X_test)

    # Plot predictions vs actuals 
    plt.figure(figsize=(10, 5))
    plt.scatter(y_test, y_pred, alpha=0.5, label='Predicted', color='orange')
    plt.xlabel('Actual Sales Revenue (USD)')
    plt.ylabel('Predicted Sales Revenue (USD)')
    plt.title(f'{model_name}: Predicted vs. Actual Sales Revenue')
    plt.plot([min(y_test), max(y_test)], [min(y_test), max(y_test)], 'r--', lw=2, label='Actual')
    plt.legend()
    plt.show()
    
    # Calculate evaluation metrics of R² and RMSE
    r2 = r2_score(y_test, y_pred)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    mae = mean_absolute_error(y_test, y_pred)
    
    # Print results
    print(f"{model_name} Model:")
    print(f"R²: {r2:.3f}")
    print(f"RMSE: {rmse:.3f}")
    print(f"MAE: {mae:.3f}\n")
    
    # Save to results list
    results.append({'Model': model_name, 'R²': r2, 'RMSE': rmse, 'MAE': mae})
```
```python
# Define models

models = {
    'Linear Regression': LinearRegression(),
    'Lasso Regression': Lasso(alpha=0.1),
    'Ridge Regression': Ridge(alpha=1.0),  
    'Random Forest': RandomForestRegressor(),
    'K-Neighbors Regressor': KNeighborsRegressor(),
    'Gradient Boosting': GradientBoostingRegressor(),
}
```
```python
# Evaluate the models
for model_name, model in models.items():
    evaluate_model(model, X_train, y_train, X_test, y_test, model_name)

# Save results to DataFrame
df_results = pd.DataFrame(results)
```
<kbd>
<img src="https://github.com/user-attachments/assets/48949b48-f8b4-41a1-8f63-222e1bd44e64">
</kbd>
<br><br>

    Linear Regression Model:
    R²: 0.542
    RMSE: 1753.735
    MAE: 1144.072

<kbd>
<img src="https://github.com/user-attachments/assets/5e74e54c-0b97-4472-a861-790e68ce4bb3">
</kbd>
<br><br>

    Lasso Regression Model:
    R²: 0.542
    RMSE: 1752.215
    MAE: 1141.092

<kbd>
<img src="https://github.com/user-attachments/assets/def1c87c-d448-43b3-80cd-07ba87723949">
</kbd>
<br><br>

    Ridge Regression Model:
    R²: 0.542
    RMSE: 1753.603
    MAE: 1143.667

<kbd>
<img src="https://github.com/user-attachments/assets/2b05fb4e-dd44-4602-9b81-c4e064836d36">
</kbd>
<br><br>

    Random Forest Model:
    R²: 0.469
    RMSE: 1887.285
    MAE: 1204.186

<kbd>
<img src="https://github.com/user-attachments/assets/8f3c6e4c-5fc2-4560-b4ee-143b871ccffe">
</kbd>
<br><br>

    K-Neighbors Regressor Model:
    R²: 0.445
    RMSE: 1930.370
    MAE: 1246.313

<kbd>
<img src="https://github.com/user-attachments/assets/e553794a-6f44-4305-b6f3-1540cd1a7353">
</kbd>
<br><br>

    Gradient Boosting Model:
    R²: 0.504
    RMSE: 1823.641
    MAE: 1245.398
    
```python
# Plot R² chart
plt.figure(figsize=(10, 5))
sns.barplot(x='R²', y='Model', data=df_results, color='#1f77b4')
plt.title('Model Performance by R² Score')
plt.show()

# Plot RMSE chart
plt.figure(figsize=(10, 5))
sns.barplot(x='RMSE', y='Model', data=df_results, color='#1f77b4')
plt.title('Model Performance by RMSE')
plt.show()

# Plot MAE chart
plt.figure(figsize=(10, 5))
sns.barplot(x='MAE', y='Model', data=df_results, color='#1f77b4')
plt.title('Model Performance by MAE')
plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/caa95141-13d7-45fd-b68b-eefb57f1d672">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/69f90117-a34c-4cc7-b133-65ae214dd219">
</kbd>
<br><br>
<kbd>
<img src="https://github.com/user-attachments/assets/1cab472b-0dfa-48ce-a6ef-7c1b9827ec30">
</kbd>

#### 3. Data modeling results summary 
* The regression models (`Linear Regression`, `Lasso Regression`, and `Ridge Regression`) performed the best among the models tested, each achieving an identical `R²` score of 0.542.   
* However, the `Lasso Regression` model slightly outperformed the others, with an `RMSE` of 1752.215 and an `MAE` of 1141.092.   
Despite these results, the overall model performance is suboptimal, aligning with the findings from the EDA, which revealed weak correlations between the features and the target variable.

### Summary of Findings from Python
* The discount strategy has minimal impact on sales revenue, and marketing spend shows a weak correlation with sales revenue. Neither the discount strategy nor marketing spend is effective in significantly boosting sales revenue.
* Sales revenue consistently peaks in December and reaches its lowest point in February each year.
* Weekends generate higher sales revenue compared to weekdays.
* Although the `Lasso Regression` model outperformed other models in predicting sales revenue, it achieved an R² score of 0.542, which indicates limited effectiveness in modeling.

## Conclusion
* Marketing analysis
  * The analyses conducted using MySQL, Tableau, and Python indicate that neither marketing spend nor discount strategies effectively boost sales revenue. Potential contributing factors may include inefficiencies in marketing expenditures and promotional efforts. Further investigation is needed to identify underlying issues and refine future sales strategies.  
* Seasonal trend analysis
  * Sales revenue significantly increases during holidays and weekends. This trend highlights opportunities to boost revenue by focusing on these key times.
* Predictive model
  * While the `Lasso Regression` model provides a framework for predicting future sales revenue, its predictive performance is currently suboptimal. Additional research and model development are necessary to identify a more accurate and reliable forecasting approach.
  

