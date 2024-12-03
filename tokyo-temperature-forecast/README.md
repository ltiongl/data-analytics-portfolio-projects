# Tokyo Temperature Forecast Model

## Project Overview

This project aims to develop and evaluate Long Short-Term Memory (LSTM) models for forecasting Tokyo's temperature using historical weather data. The primary objective is to determine the most effective combination of input features for accurate temperature predictions.  

## Data Details

The dataset, `tokyo_weather_19900101_to_20241130.csv`, was sourced from [Visual Crossing](https://www.visualcrossing.com/weather/weather-data-services#) via purchase. It contains 12,753 records covering Tokyo's weather from `1990-01-01` to `2024-11-30`.

### Features:
The dataset includes the following features:

* General Weather Metrics:
  * `datetime`, `tempmax`, `tempmin`, `temp`, `feelslikemax`, `feelslikemin`, `feelslike`, `dew`, `humidity`, `precip`, `precipprob`, `precipcover`, `preciptype`, `snow`, `snowdepth`, `windgust`, `windspeed`, `winddir`, `sealevelpressure`, `cloudcover`, `visibility`

* Solar Metrics (available from `2010-01-01` to `2024-11-30`, 5,448 records):
   * `solarradiation`, `solarenergy`, `uvindex`
     
* Other Information:
  * `sunrise`, `sunset`, `moonphase`, `conditions`, `description`, `icon`, `stations`

### Notes on Data:
* Missing Data:
  * `snow`: Contains 3,708 null values, which can be filled with 0 as no snow is expected.
* Solar Data Availability:
  * Features like `solarradiation`, `solarenergy`, and `uvindex` are only available from `2010-01-01` to `2024-11-30`.
    
### Feature Descriptions:
* `datetime`: Date (`YYYY-MM-DD`)
* `temp`: Average temperature (°C)
* `tempmax`, `tempmin`: Maximum and minimum temperature (°C)
* `feelslike`, `feelslikemax`, `feelslikemin`: Apparent temperatures (°C)
* `dew`: Dew point (°C)
* `humidity`: Relative humidity (%)
* `precip`: Precipitation (mm)
* `preciptype`: Type of precipitation
* `snow`, `snowdepth`: Snowfall (mm) and snow depth (mm)
* `windspeed`, `windgust`: Wind speed and gust speed (km/h)
* `winddir`: Wind direction (0–360°)
* `sealevelpressure`: Sea level pressure (hPa)
* `cloudcover`: Cloud cover (%)
* `solarradiation`: Solar radiation (W/m²)
* `solarenergy`: Solar energy (kWh)
* `uvindex`: UV index (0–11+)

## Executive Summary
### Objective

This project develops and compares three PyTorch LSTM models with varying input features to identify the best-performing model for temperature forecasting.

### LSTM Models 

* Baseline Model (`tokyo_temperature_forecast_lstm`):
  * Input Features: `temperature`, `dew`, `humidity`, `precipitation`, `snow`, `windspeed`, `sealevelpressure`, `cloudcover`
  * Target Feature: `temperature`
  * Dataset: Full dataset (12,753 records, 1990–2024)

* Solar-Enhanced Model (`tokyo_temperature_forecast_with_solar_inputs_lstm`):
  * Input Features: All baseline features plus `solarradiation`, `solarenergy`, and `uvindex`
  * Target Feature: `temperature`
  * Dataset: Limited to 5,448 records (2010–2024) due to solar feature availability

* Correlated Features Model (`tokyo_temperature_forecast_with_correlated_inputs_lstm`):
  * Input Features: Only correlated features: `temperature`, `dew`, `humidity`, `snow`
  * Target Feature: `temperature`
  * Dataset: Full dataset (12,753 records, 1990–2024)

### Findings

All three models achieved a comparable Mean Squared Error (MSE) of 0.003 for the test data, indicating that:
* Complex models with additional features do not significantly improve prediction accuracy.
* Simpler models with fewer input features are sufficient for forecasting temperature effectively.
  
### Future Work

* Exploration of Additional Models:
  * Experiment with other machine learning architectures (e.g., GRU, Transformer-based models) for potential performance improvements.

* Incorporate External Data:
  * Introduce external datasets (e.g., ENSO indices, global weather patterns) to assess their impact on prediction accuracy.

* Feature Engineering:
  * Investigate derived features, such as heat indices or lagged variables, for better temporal modeling.

* Seasonal and Long-Term Trends:
  * Develop models specifically tailored for seasonal trends or long-term temperature forecasts.

* Model Optimization:
  * Optimize hyperparameters using grid or Bayesian search to improve model performance.
