# Sale Retails Analysis

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
Python version: `Python 3.9.10`  
Python packages: `pandas`, `matplotlib`, `seaborn`, `sklearn`   
Tableau: `Tableau Desktop Public Edition 2024.2.0`    
MySQL Workbench: `MySQL Workbench Version 8.0.38`  

## Data Source
The dataset is obtained from `Kaggle`: [Retail Sales Data with Seasonal Trends & Marketing](https://www.kaggle.com/datasets/abdullah0a/retail-sales-data-with-seasonal-trends-and-marketing).  

---

## Table of Contents
* [Approach 1: MySQL + Tableau](#approach-1-mysql--tableau)
  - [Data Cleaning](data-cleaning)
  - [Data Exploration / EDA](#data-exploration--eda)
  - [Data Visualization](#data-visualization)
* [Approach 2: Python](#approach-2-python)
  - [Data Cleaning and Initial Data Exploration](#data-cleaning-and-initial-data-exploration)
  - [Data Exploration / EDA](#data-exploration--eda-1)
  - [Data Modeling](#data-modeling)
* [Conclusion](#conclusion)
    
---

## Approach 1: MySQL + Tableau

### Data Cleaning
##### 1. Verify duplicated lines
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
> * There is no duplicated data. 

##### 2. Standardize the data
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
> * The data doesn't have stadardization issue, except the data type of `Date` is modified to `DATE` format.

##### 3. Verify null data  
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
> * Null data doesn't exist.

##### Data cleaning summary

### Data Exploration / EDA
The data exploration focuses on analysing effectiveness of marketing spend and discount strategy.

#### Effectiveness of marketing spend
##### 1. Marketing spend impact on sales revenue
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
    avg_revenue_with_marketing_spend,
    avg_revenue_without_marketing_spend,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue;
```
<img width="622" alt="image" src="https://github.com/user-attachments/assets/6268d58f-e6f8-498f-a17a-8d594da2e15f">

##### 2. Marketing spend impact on sales revenue by product category
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
    avg_revenue_with_marketing_spend,
    avg_revenue_without_marketing_spend,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;
```
<img width="762" alt="image" src="https://github.com/user-attachments/assets/cda9fdc6-f405-4e95-b14b-f601d05c504d">

##### 3. Marketing spend impact on sales revenue by day of the week
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
	  avg_revenue_with_marketing_spend,
    avg_revenue_without_marketing_spend,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;
```
<img width="751" alt="image" src="https://github.com/user-attachments/assets/428af406-f740-4f05-9447-15518c687fd6">

##### 4. Marketing spend impact on sales revenue by holiday effect
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
	  avg_revenue_with_marketing_spend,
    avg_revenue_without_marketing_spend,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;
```
<img width="735" alt="image" src="https://github.com/user-attachments/assets/88f34c51-dc4a-4e46-bcfc-196d87198a84">

##### 5. Marketing spend impact on sales revenue by year
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
    avg_revenue_with_marketing_spend,
    avg_revenue_without_marketing_spend,
    ROUND(((avg_revenue_with_marketing_spend - avg_revenue_without_marketing_spend) - avg_marketing_spend) 
    / avg_marketing_spend, 2) AS romi
FROM cte_revenue
ORDER BY romi DESC;
```
<img width="669" alt="image" src="https://github.com/user-attachments/assets/3e30a4c0-b0a0-4e6e-a752-516e96998c91">

#### Effectiveness of discount strategy
##### 1. Discount impact on sales revenue
```mysql
SELECT
    ROUND(AVG(CASE WHEN `Discount Percentage` > 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_with_discount,
    ROUND(AVG(CASE WHEN `Discount Percentage` = 0 THEN `Sales Revenue (USD)` ELSE 0 END), 2) AS avg_revenue_without_discount
FROM
    retail_sales_staging;
```

<img width="451" alt="image" src="https://github.com/user-attachments/assets/15c4e215-8d74-4992-be27-6f452a4923d9">

##### 2. Discount impact on sales revenue by product category
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

##### 3. Discount impact on sales revenue by day of the week
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

##### 4. Discount impact on sales revenue by holiday effect
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

#### Sales revenue trend
##### 1. Sales revenue trend over years
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

##### 2. Seasonal sales revenue trend
```mysql
SELECT
    `Holiday Effect`,
	  ROUND(AVG(`Sales Revenue (USD)`), 2) AS average_revenue
FROM retail_sales_staging
GROUP BY `Holiday Effect`
ORDER BY average_revenue DESC;
```
<img width="253" alt="image" src="https://github.com/user-attachments/assets/7c359dcb-1977-42ea-acc5-f55b94b60807">

##### 3. Sales revenue trend by day of the week
```mysql
SELECT
    `Day of the Week`,
	  ROUND(AVG(`Sales Revenue (USD)`), 2) AS average_revenue
FROM retail_sales_staging
GROUP BY `Day of the Week`
ORDER BY average_revenue DESC;
```
<img width="270" alt="image" src="https://github.com/user-attachments/assets/a22294d7-f56e-4323-ab93-6a69ab12ce24">


##### 4. Sales revenue trend by product category
```mysql
SELECT
	`Product Category`,
	ROUND(SUM(`Sales Revenue (USD)`), 2) AS total_revenue
FROM retail_sales_staging
GROUP BY `Product Category`
ORDER BY total_revenue DESC;
```
<img width="256" alt="image" src="https://github.com/user-attachments/assets/e4c886eb-2e3e-4cbe-bf96-6500b22d34cf">
   
##### 5. Sales revenue trend by store location
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

##### Data exploration summary


### Data Visualization
The data is visualized in an interactive Tableau dashboard, which you can explore [here](https://public.tableau.com/app/profile/lily.tiong/viz/retail_sales_17264041202470/SalesDashboard?publish=yes).   
<kbd>
<img src="https://github.com/user-attachments/assets/5b5f9313-9980-4504-8b9a-63a03073989b">
</kbd> 

<kbd>
<img src="https://github.com/user-attachments/assets/8720141f-3b18-4579-938a-ed79cfdd7c2c">
</kbd> 

##### Data visualization summary



## Approach 2: Python

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

```python
df.duplicated().sum()
```
    np.int64(0)
    
There is no null data and duplicated data.

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

`Date` data type has been updated to `datetime64`.

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
    
##### Data cleaning summary
1. No null value or duplicated value is found in the dataset.
2. `Date` column data type is updated to `datetime64`.
3. There are 30,000 rows and 11 columns in the dataset.
4. There is only one unique value in `Store ID`, hence the column can be ignored and dropped.

```python
# Drop column 'Store ID'
df = df.drop('Store ID', axis=1)
```

### Data Exploration / EDA

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

#### Univariate Analysis

##### Distribution of Numerical Variables
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

<kbd>
<img src="https://github.com/user-attachments/assets/2c4a084e-9afc-4ac9-96ad-011905f3c2dc">
</kbd> 

<kbd>
<img src="https://github.com/user-attachments/assets/6d0946b0-8f68-4dcf-bf98-f9916c221dd3">
</kbd>

#### Bivariate Analysis

##### Box plots of numerical variables vs. categorical variables
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

<kbd>
<img src="https://github.com/user-attachments/assets/aedf6c8f-9034-4bea-ab52-39dd2a417ea8">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/12ce1b77-da0b-4176-a599-d2f2dd540819">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/90fa0a0f-c32e-42b4-96c6-a2e1d0e699e0">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/714e6763-6ac9-4e44-a6cf-02aa53de0891">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/170a44b4-a35e-421c-9343-5e12625029d2">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/414098f0-0b2a-456a-a8b0-ec85912152a6">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/4974c8ef-7eea-418e-8e46-7e4fe4d2531a">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/c628a116-17aa-4c48-a2b6-6b9629d36a61">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/2b44a1fe-f3d6-403e-bda6-0ee6a89b8c9f">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/35bf54fa-8afa-41f5-a05d-c0ffe9e94472">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/85cf152b-c018-41fb-b352-c11e25446098">
</kbd>

#### Multivariate Analysis
##### Pairplot of numerical variales
```python
plt.figure(figsize=(10,5))
sns.pairplot(df[numerical_col])
plt.show()
```

<kbd>
<img src="https://github.com/user-attachments/assets/4a51af65-f1c3-46ea-9672-7e44bc4e3f1f">
</kbd>

##### Heatmap of numerical variables
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

#### Time Series Analysis
```python
# Analysis by hour
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

<kbd>
<img src="https://github.com/user-attachments/assets/570b3880-5c1e-49a1-8926-2a93fedf3c92">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/b591d886-1a0f-4251-ba46-589655448d01">
</kbd>

##### Data exploration summary
1. The distributions of `Units Sold`, `Sales Revenue (USD)`, and `Marketing Spend (USD)` are right-skewed. 
2. Among the product categories, `Electronics` leads with the highest units sold and sales revenue, followed by `Clothing`, `Furniture`, and `Groceries`. 
3. In terms of marketing spend, `Electronics` also tops the list, followed by `Groceries`, then `Clothing`, and `Furniture`.
4. The discount percentage has minimal impact on both units sold and sales revenue. 
5. There is a slightly higher number of units sold and increased sales revenue on weekends (Saturday and Sunday) compared to weekdays, though the difference is not significant. 
6. Sales and units sold tend to perform better during holidays, whereas marketing spend appears unaffected by holidays.
7. From the correlation analysis, only `Sales Revenue (USD)` and `Units Sold` show a notable linear relationship. `Marketing Spend (USD)` does not show a strong correlation with either `Sales Revenue (USD)` or `Units Sold`, suggesting that marketing spend has a limited impact on revenue. This is further supported by the heatmap, where `Marketing Spend (USD)` shows a near-zero correlation with both sales revenue and units sold.
8. The time series analysis reveals that `Sales Revenue (USD)` reaches its lowest point in February, followed by a consistent rise, peaking in December, likely due to year-end seasonal events. Meanwhile, `Marketing Spend (USD)` also dips in February but remains relatively stable, fluctuating around $62,000 throughout the year.

### Data Modeling
#### Data Preprocessing
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
    plt.scatter(y_test, y_pred, alpha=0.5, label=f'{model_name}', color='orange')
    plt.xlabel('Actual Sales Revenue (USD)')
    plt.ylabel('Predicted Sales Revenue (USD)')
    plt.title(f'{model_name}: Predicted vs. Actual Sales Revenue')
    plt.plot([min(y_test), max(y_test)], [min(y_test), max(y_test)], 'r--', lw=2)
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
<img src="https://github.com/user-attachments/assets/f34a14ae-4e02-4368-a54f-ff54723cf8ba">
</kbd>

    Linear Regression Model:
    R²: 0.542
    RMSE: 1753.735
    MAE: 1144.072

<kbd>
<img src="https://github.com/user-attachments/assets/2349952e-90a5-404b-a71a-420cf483a557">
</kbd>
 
    Lasso Regression Model:
    R²: 0.542
    RMSE: 1752.215
    MAE: 1141.092

<kbd>
<img src="https://github.com/user-attachments/assets/b8f1e506-8700-4c5d-a798-67add977bb00">
</kbd>
    
    Ridge Regression Model:
    R²: 0.542
    RMSE: 1753.603
    MAE: 1143.667

<kbd>
<img src="https://github.com/user-attachments/assets/d90f7786-bab2-45d3-9d93-127401961d73">
</kbd>

    Random Forest Model:
    R²: 0.469
    RMSE: 1887.285
    MAE: 1204.186

<kbd>
<img src="https://github.com/user-attachments/assets/97137651-f090-4664-9d5a-74ba61417a5e">
</kbd>

    K-Neighbors Regressor Model:
    R²: 0.445
    RMSE: 1930.370
    MAE: 1246.313

<kbd>
<img src="https://github.com/user-attachments/assets/9bbc6a38-02fd-41e9-a9be-267d02a0c2b2">
</kbd>

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

<kbd>
<img src="https://github.com/user-attachments/assets/69f90117-a34c-4cc7-b133-65ae214dd219">
</kbd>

<kbd>
<img src="https://github.com/user-attachments/assets/1cab472b-0dfa-48ce-a6ef-7c1b9827ec30">
</kbd>

##### Data modeling results summary 
The regression models (Linear Regression, Lasso Regression, and Ridge Regression) performed the best among the models tested, each achieving an identical R² score of 0.542.   
However, the Lasso Regression model slightly outperformed the others, with an RMSE of 1752.215 and an MAE of 1141.092.   
Despite these results, the overall model performance is suboptimal, aligning with the findings from the EDA, which revealed weak correlations between the features and the target variable.

## Conclusion

## Future Works
