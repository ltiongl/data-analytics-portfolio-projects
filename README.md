# Data Analytics Portfolio Projects

## Index
* [Project 1: Retail Sales Data Analysis](#project-1-retail-sales-data-analysis)
* [Project 2: E-Commerce Electronic Store Sales Data Analysis](#project-2-e-commerce-electronic-store-sales-data-analysis)
* [Project 3: Tokyo Temperature Forecast Model](#project-3-tokyo-temperature-forecast-model)

---

## Project 1: [Retail Sales Data Analysis](https://github.com/ltiongl/data-analytics-portfolio-projects/tree/main/retail-sales)

This project analyses the retail sales data from `2022-01-01` to `2024-01-01`, focusing on three key areas:
* `Marketing Analysis`: Evaluation of the impact of marketing spend and discount strategy on sales performance.
* `Seasonal Trend Analysis`: Examination of how holiday and days of the week influence sales pattern.
* `Predictive Modeling`: An assessment of forecasting models to predict future sales based on historical data.

The analysis is conducted using both MySQL and Python for data exploration, with a visualization dashboard created to summarize the results.

---

## Project 2: [E-Commerce Electronic Store Sales Data Analysis](https://github.com/ltiongl/data-analytics-portfolio-projects/tree/main/ecommerce-electronics-store-sales)

This project analyzes the sales data of an e-commerce electronics store from October 1, 2020, to February 28, 2021, with a focus on four key areas:
* `Sales Trends Analysis`: Evaluation of historical sales patterns, emphasizing Revenue and Average Order Value (AOV).
* `User Behavior Analysis`: Examination of user actions and engagement throughout the shopping journey, with a focus on Conversion Rate (CR) and Cart Abandonment Rate (CAR).
* `Product Level Analysis`: Assessment of the impact of each product category on overall sales and revenue.
* `Time Analysis`: Investigation of how sales performance and user behaviors vary across different hours of the day, identifying peak shopping times and trends in user engagement.
  
The analysis is conducted using MySQL for data cleaning and exploration, complemented by a visualization dashboard to effectively summarize and present the results.

---

## Project 3: [Tokyo Temperature Forecast Model](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/tokyo-temperature-forecast)

This project focuses on developing and evaluating three `Long Short-Term Memory` (LSTM) models to forecast Tokyo's daily temperature using historical weather data. The dataset, sourced from `Visual Crossing`, spans from 1990 to 2024 and includes a wide range of meteorological features such as temperature, humidity, precipitation, wind speed, solar radiation, and UV index.

The models differ in their feature sets:
* Baseline Model: Uses fundamental weather features from the entire dataset (12,753 records).
* Solar-Enhanced Model: Incorporates solar-related features, limited to data from 2010 to 2024 (5,448 records).
* Correlated Features Model: Focuses on a reduced set of key correlated features for simplicity, using the full dataset.
  
All models achieved comparable forecasting accuracy, with a `Mean Squared Error` (MSE) of 0.003. This finding demonstrates that simpler models with fewer input features are as effective as more complex ones for temperature prediction.

This project provides a foundation for robust weather forecasting and highlights the potential for efficient and accurate temperature prediction with minimal inputs.
