# E-Commerce Electronics Store Sales Data Analysis

## Project Background

This project conducts an in-depth analysis of user behavior over a 5-month period, from `2019-10-01` to `2021-02-28`, using a dataset containing 885,129 rows from a large online electronics store. The dataset captures various critical aspects of user interactions, including event time, event type, product ID, category ID, category code, brand, price, user ID, and user session. Event types categorize user behavior into three key actions: viewing products (`view`), adding items to the cart (`cart`), and completing a purchase (`purchase`). A session resulting in one or more purchases is considered a single order.

The primary goal of this analysis is to extract actionable insights that will contribute to the store's commercial success. By examining user behavior, marketing performance, and sales trends, the project aims to provide valuable recommendations for optimizing business strategies and driving growth.

Key areas of analysis include:
* `Sales Trends Analysis`: Evaluation of historical sales patterns, emphasizing Revenue and Average Order Value (AOV).
* `User Behavior Analysis`: Examination of user actions and engagement throughout the shopping journey, with a focus on Conversion Rate (CR) and Cart Abandonment Rate (CAR).
* `Product Level Analysis`: Assessment of the impact of each product category on overall sales and revenue.
* `Time Analysis`: Investigation of how sales performance and user behaviors vary across different hours of the day, identifying peak shopping times and trends in user engagement.

An interactive Tableau dashboard used to report and explore sales trends can be found [here](https://public.tableau.com/app/profile/lily.tiong/viz/ecommerce_electronics_store_sales/E-CommerceElectronicsStoreSalesDashboard).

The SQL queries utilized to inspect, clean and organize the data can be found [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/ecommerce-electronics-store-sales/data_cleaning.sql).  

The SQL queries utilized to explore data for various metrics, and prepare the data for dashboard can be found [here](https://github.com/ltiongl/data-analytics-portfolio-projects/blob/main/ecommerce-electronics-store-sales/data_exploration.sql).  

## Data Structure & Initial Checks
The database structure is based on the `events_updated` table, which contains a total of `856,194` records.
This table is a cleaned version of the original `events` table, with several data quality improvements applied, including the removal of the redundant records from `2020-09-24` to `2020-09-30`, duplicate entries, handling of blank values, and correcting the data type for event time.

<img width="200" alt="image" src="https://github.com/user-attachments/assets/3cbc995a-3932-4878-b544-17cce9471dbe">   

## Executive Summary
### Overview of Findings

Store sales revenues exhibited a steady increase from October 2020 to January 2021, followed by a 7.5% decline from January to February 2021. This trend is mirrored in other Key Performance Indicators (KPIs): the Conversion Rate (CR) decreased by 0.4%, and the Cart Abandonment Rate (CAR) fell by 0.6% in February 2021 compared to January 2021. In contrast, the Average Order Value (AOV) maintained a consistent upward trajectory throughout the analysis period.

Below is the overview page from the Tableau dashboard. The entire interactive dashboard can be found [here](https://public.tableau.com/app/profile/lily.tiong/viz/ecommerce_electronics_store_sales/E-CommerceElectronicsStoreSalesDashboard).  

<kbd>
<img src="https://github.com/user-attachments/assets/6aa5f454-88c1-485e-bd21-efe896617891">
</kbd> 

### Sales Trend 
* In the final quarter of 2020, monthly revenue remained under $1 million, but saw a significant surge beyond $1 million starting in January 2021.
* From October 2020, when revenue stood at $560.7k, there was a steady upward trend, peaking at $1.49 million in January 2021 — a remarkable growth trajectory.
* The only setback occurred in February 2021, with a modest 7.5% month-over-month decline, bringing revenue down to $1.38 million.
* The most notable increase came in January 2021, with an impressive 83.1% growth compared to the previous month, marking a standout moment in revenue growth.
* Meanwhile, the Average Order Value (AOV) followed a upward trend from October 2020 to February 2021.
* Starting at $133.85 in October 2020, the AOV steadily rose to $157.68, $182.82, $267.30, and finally $274.08 in February 2021.
* A significant spike occurred in January 2021, with a 46.2% increase compared to the previous month. Despite the decline in overall revenue in February 2021, the AOV still grew by 2.5%, indicating a decrease in the total number of orders placed.

### User Behaviour 
* Conversion Rate (CR) shows minimal variation, ranging from 4.37% in October 2020 to its peak at 5.66% in January 2021.
* A steady increase in the Conversion Rate is observed each month from October 2020 through January 2021, followed by a slight dip to 5.64% in February 2021.
* Cart Abandonment Rate (CAR) mirrors the trend of the Conversion Rate. Starting at 39.44% in October 2020, it rises gradually each month, reaching 42.47% in January 2021, before a small drop to 42.22% in February 2021.
* Throughout this period, Cart Abandonment Rate remains relatively stable, fluctuating around the 40% mark, with only minor changes.
* The similarity in trends between Conversion Rate and Cart Abandonment Rate suggests increasing site traffic but possibly lower purchase intent among visitors, or potential issues during the checkout process causing hesitations.
* Despite the rise in cart abandonment, the overall Average Order Value (AOV) suggests that those who do convert are making larger purchases. This higher spending per purchase may compensate for the increased cart abandonment, driving up total revenue even as some users abandon their carts.

### Product Performance
* The Computers and Electronics categories consistently ranked as the top revenue-generating segments between October 2020 and February 2021.
* Computers significantly outperformed other categories, recording a peak revenue of $1,215.5k in January 2021, which was 15 times higher than the second-ranked Electronics category, which brought in $76.6k during the same period.
* Computers showed rapid revenue growth from $319.2k in October 2020, climbing to $480.9k in November 2020, $535.7k in December 2020, and peaking at $1,215.5k in January 2021, before slightly declining to $1,121.2k in February 2021. Notably, it contributed to 81.7% of total revenue in January 2021 and was the only category to exceed $1 million in sales during the first two months of 2021.
* The surge in computer sales could be attributed to the increased demand for personal computing equipment during the pandemic, as more people shifted to remote work and required upgraded technology for home offices.

### Time Impact
* In 2020, peak revenue occurred between 10:00 AM and 12:00 PM, with the highest figures reached at 10:00 AM in October, 12:00 PM in November, and 11:00 AM in December.
* In 2021, the trend shifted, with peak revenues achieved at 5:00 PM in October and 7:00 PM in November, while morning hours continued to show strong revenue.
* Throughout the months, revenue was concentrated between 6:00 AM and 9:00 PM. Hours outside this range experienced significantly lower revenue, indicating that most purchases were made by users operating within the UTC time zone.

## Recommendations
Based on the insights and findings, the following recommendations are proposed:
* The significant revenue boost in January 2021 indicates that effective campaigns or strategies were implemented during this period. It's essential to analyze the details of these strategies, such as the types of promotions or marketing channels used. **Refining and continuing these successful tactics can help sustain the momentum and capitalize on the initial success.**
* The Cart Abandonment Rate remaining relatively stable alongside an increase in the Conversion Rate suggests potential challenges in the purchase checkout process. This scenario may indicate that while more users are entering the funnel, they may be facing obstacles that prevent them from completing their purchases. **Conducting a detailed analysis of the checkout experience can help identify and address any friction points, improving the overall user journey and reducing abandonment rates.**
* The upward trend in AOV indicates that users are spending more per transaction, which is a positive sign for revenue growth. To further enhance this, there is an opportunity to expand the user base. Targeting marketing efforts to attract new customers, while simultaneously encouraging repeat purchases from existing ones, can significantly boost overall revenue. **Consider implementing loyalty programs or referral incentives to facilitate this growth.**
* Given that many users are operating within the UTC time zone, it would be advantageous to design campaigns and promotions specifically targeting these users. **Scheduling marketing activities to align with peak engagement times can enhance visibility and effectiveness.** Tailored messaging and timely promotions can resonate more with users during their active hours, increasing the likelihood of conversions.

## Assumptions and Caveats
Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:
* Revenue is assumed to be in USD.
* Event timestamps are recorded in the UTC time zone.
* Multiple purchases made within a single session are treated as one order.
