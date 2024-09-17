# Retail Sales Data Analysis

## Project Background

The Spearsland Store operates 243 branches worldwide and offers 43 products across four categories: electronics, clothing, furniture, and groceries.   

The dataset includes 30,000 retail sales records spanning from `2022-01-01` to `2024-01-01`. It encompasses data on sales revenue, discount percentages, and marketing spend, while also factoring in holiday effects, days of the week, product categories, and store locations.   

This project aims to analyze and synthesize this data to uncover critical insights that will drive the commercial success of Spearsland Store.   

Insights and recommendations are provided on the following key areas:  
* `Marketing Analysis`: Evaluation of the impact of marketing spend and discount strategy on sales performance.
* `Seasonal Trend Analysis`: Examination of how holiday and days of the week influence sales pattern.
* `Predictive Modeling`: An assessment of forecasting models to predict future sales based on historical data.

An interactive Tableau dashboard can be found [here](https://public.tableau.com/app/profile/lily.tiong/viz/retail_sales_17264041202470/SalesDashboard?publish=yes).  

The SQL queries utilized to clean, organise, and prepare data for dashboard can be found [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/retail-sales/retail_sales.sql).  

The Python notebook utilised to perform data cleaning, data exploration, and data modeling can be found [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/retail-sales/retail_sales.ipynb).  

A detailed explanation of the data analysis workflow is available [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/retail-sales/analysis_workflow.md).


## Data Structure & Initial Checks
Spearsland Store's database structure consists of `retail_sales_staging` table with a total row count of 30,000 records.  
`retail_sales_staging` table is the updated version from the original table `retail_sales`, with the data type of `Date` updated to `DATE` format.

<img width="200" alt="image" src="https://github.com/user-attachments/assets/857914e7-1f2a-4eda-99f8-56e4f082a6e2">   
   
Prior to beginning the analysis, a variety of checks were conducted for quality control and familiarization with the dataset.  
The SQL queries utilized to inspect and perform quality check are available [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/retail-sales/analysis_workflow.md#data-cleaning), while the python code for data cleaning can be found [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/retail-sales/analysis_workflow.md#data-cleaning-and-initial-data-exploration).

## Executive Summary
### Overview of Findings

Key performance indicators (KPIs) reveal consistent total sales revenue across 2022 and 2023, with a slight 0.4% decline in total marketing spend in 2023. The Return on Marketing Investment (ROMI) metric shows negative performance, at -1.17 in 2022 and -1.11 in 2023. Notably, sales demonstrated stronger performance during holidays and weekends, highlighting the importance of these periods for driving revenue.

Below is the overview page from the Tableau dashboard. The entire interactive dashboard can be found [here](https://public.tableau.com/app/profile/lily.tiong/viz/retail_sales_17264041202470/SalesDashboard?publish=yes).  

<kbd>
<img src="https://github.com/user-attachments/assets/5b5f9313-9980-4504-8b9a-63a03073989b">
</kbd> 

### Impact of Marketing Spend 
Impact of marketing spend is evaluated using ROMI metric.
* ROMI was -1.17 USD in 2022 and -1.11 USD in 2023, indicating negative returns from marketing investment.
* In 2022, the electronics category was the only one with positive ROMI at 1.25 USD, while in 2023, clothing was the only category with a positive ROMI of 0.61 USD. Electronics, however, became the worst-performing category in 2023, with a ROMI of -2.13 USD.
* By holiday effect, holidays in 2022 recorded a strong ROMI of +17.34 USD, but ROMI turned negative for both holiday and non-holiday periods in 2023.
* ROMI also varied by day of the week, with Sunday and Tuesday showing positive ROMI in 2022 (+1.79 USD and +0.23 USD, respectively). However, in 2023, these days turned negative, while Thursday, Friday, and Saturday showed positive ROMI.
* The heatmap below further highlights the lack of correlation between marketing spend and sales revenue, demonstrating zero correlation between these variables.d and sales revenue is further proved by the heatmap below, where there is 0 correlation between marketing spend and sales revenue.

<kbd>
<img width="500" src="https://github.com/user-attachments/assets/20df6623-7619-45df-aa41-2a3d485f3f52">
</kbd>

### Effectiveness of Discount Strategy 
* Discounts had a positive impact only during holidays in 2023, where average sales reached 6,217 USD, compared to 5,591 USD for non-discounted days.
* The discount strategy did not show positive effects across all product categories, days of the week, or holiday versus non-holiday periods, except for holidays in 2023.

### Seasonal Sales Trend
* Holidays and weekends (Saturday and Sunday) consistently showed higher sales compared to non-holidays and weekdays.
* Time series analysis shows the highest sales spikes occurred in December 2022 and 2023, coinciding with the holiday season.

<kbd>
<img width="500" src="https://github.com/user-attachments/assets/570b3880-5c1e-49a1-8926-2a93fedf3c92">
</kbd>

### Sales Forecasting
* Several models were tested for sales prediction, with the Lasso Regression model performing best.
* However, the model's R² score was 0.542, indicating there is room for improvement in predictive accuracy.
  
<kbd>
<img width="500" src="https://github.com/user-attachments/assets/5e74e54c-0b97-4472-a861-790e68ce4bb3">
</kbd>

## Recommendations
Based on the insights and findings, the following recommendations are proposed:
* The analysis suggests that neither marketing spend nor discount strategies are effectively driving sales revenue. Potential causes may include inefficiencies in marketing allocation or promotional execution. **Further investigation is required to identify root causes and optimize future sales strategies.**
* Sales revenue consistently increases during holidays and weekends. **This trend presents an opportunity to focus efforts on these periods to maximize revenue growth.**
* Although the `Lasso Regression` model offers a baseline for predicting future sales revenue, its performance is currently limited. **Further research and model refinement are recommended to develop a more accurate and reliable forecasting solution.**
* The analysis is based on a limited dataset spanning only two years. **Expanding the dataset will lead to more robust and reliable conclusions, allowing for better-informed decision-making.**

## Assumptions and Caveats
Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:
* Data for the year `2024` is excluded from the analysis because it only comprises information from a single day, `2024-01-01`. This limited dataset does not provide a representative sample of the year's trends and patterns, making it insufficient for meaningful analysis.
* ROMI was calculated using the following formula: ROMI = ((average_sales_with_marketing_spend - average_revenue_without_marketing_spend) - (average_marketing_spend)) / average_marketing_spend.
  - The term (average_sales_with_marketing_spend - average_revenue_without_marketing_spend) represents the additional sales revenue generated through marketing efforts.
