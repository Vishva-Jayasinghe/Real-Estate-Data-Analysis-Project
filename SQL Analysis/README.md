
[Real_Estate_SQL_Project_README.md](https://github.com/user-attachments/files/26323069/Real_Estate_SQL_Project_README.md)
# Real Estate Market Analysis (Advanced SQL Project)

## Overview

This project showcases advanced SQL-based data analysis on a real estate
dataset (`dframe`). It focuses on extracting actionable business
insights using PostgreSQL features such as CTEs, window functions,
ranking, and statistical analysis.

The analysis is designed to simulate real-world business scenarios
relevant to real estate investors, analysts, and decision-makers.

------------------------------------------------------------------------

## Objectives

-   Identify high-value and investment-worthy properties
-   Analyze pricing trends and market growth
-   Evaluate supply vs demand dynamics
-   Understand pricing efficiency based on property characteristics

------------------------------------------------------------------------

## Tools & Technologies

-   PostgreSQL (SQL)
-   Window Functions (DENSE_RANK, LAG)
-   Common Table Expressions (CTEs)
-   Aggregations & Statistical Functions
-   Business Analytics Logic

------------------------------------------------------------------------

## Key Analytical Problems Solved

### 1. Top Expensive Properties per City

-   Ranked properties within each city using `DENSE_RANK`
-   Identified top 3 most expensive properties per city

### 2. Month-over-Month Price Growth

-   Calculated monthly average prices
-   Used `LAG()` to compute MoM growth %
-   Handled nulls and division safety using `COALESCE` and `NULLIF`

### 3. Premium Floors Analysis

-   Evaluated average price per sqm by floor level
-   Ranked top-performing floors per city & property type

### 4. Luxury Gap Detection (Amenities Analysis)

-   Identified expensive properties lacking key amenities (gym,
    elevator, pool)
-   Compared prices against city median using `PERCENTILE_CONT`

------------------------------------------------------------------------

## Advanced Business Use Cases

### 5. Undervalued Property Detection

-   Compared property price per sqm against city average
-   Flagged properties priced below 80% of market value
-   Calculated discount percentage → investment opportunities

### 6. Market Momentum Analysis

-   Measured price growth trends per city over time
-   Classified cities as growing, declining, or stable

### 7. Price Efficiency by Property Size

-   Grouped properties into size buckets (Small, Medium, Large)
-   Compared cost efficiency using price per sqm
-   Ranked most efficient property sizes

### 8. Inventory Pressure (Supply vs Demand)

-   Combined total listings and days on market
-   Created a custom "inventory pressure score"
-   Identified high-pressure (slow-moving) markets

------------------------------------------------------------------------

## Key Insights Generated

-   High-priced properties are not always well-equipped (amenity gaps
    exist)
-   Some cities show strong upward momentum while others stagnate
-   Larger properties may offer better cost efficiency per sqm
-   High inventory pressure highlights oversupply risk areas
-   Undervalued properties provide strong investment signals

------------------------------------------------------------------------

## Skills Demonstrated

-   Advanced SQL querying
-   Analytical thinking & business problem solving
-   Data transformation and feature engineering
-   Performance metrics design
-   Real-world data analysis scenarios

------------------------------------------------------------------------

## Author

Vishva Suraj\
Aspiring Data Analyst \| SQL \| Python \| Power BI \| Machine Learning

------------------------------------------------------------------------

## Notes

This project is portfolio-ready and demonstrates the ability to
translate raw data into meaningful business insights using SQL alone.
