[README_with_SQL_Code.md](https://github.com/user-attachments/files/26323078/README_with_SQL_Code.md)# Real Estate Market Analysis \| SQL + Power BI

## Overview

End-to-end data analytics project using advanced SQL and Power BI to
analyze real estate market trends, pricing behavior, and investment
opportunities.

------------------------------------------------------------------------

## Advanced Business Problems & SQL Solutions

### 1. Undervalued Properties

Identify properties priced below 80% of city average.

``` sql
WITH data AS (
    SELECT city, property_id, property_type,
           price_per_sqm,
           AVG(price_per_sqm) OVER (PARTITION BY city) AS city_avg
    FROM dframe
    WHERE listing_type = 'Sale'
)
SELECT *,
       ROUND(((city_avg - price_per_sqm) / city_avg) * 100, 2) AS discount_pct
FROM data
WHERE price_per_sqm < 0.8 * city_avg;
```

------------------------------------------------------------------------

### 2. Market Momentum (MoM Growth)

Track monthly price trends per city.

``` sql
WITH sales AS (
    SELECT city,
           DATE_TRUNC('month', listing_date) AS month,
           AVG(sale_price_eur) AS avg_price
    FROM dframe
    GROUP BY city, month
),
growth AS (
    SELECT *,
           LAG(avg_price) OVER (PARTITION BY city ORDER BY month) AS prev_price
    FROM sales
)
SELECT *,
       ROUND(((avg_price - prev_price) / prev_price) * 100, 2) AS mom_growth_pct
FROM growth;
```

------------------------------------------------------------------------

### 3. Price Efficiency by Property Size

Analyze cost efficiency across size segments.

``` sql
WITH prop_size AS (
    SELECT *,
        CASE 
            WHEN square_meters < 80 THEN 'Small'
            WHEN square_meters BETWEEN 80 AND 150 THEN 'Medium'
            ELSE 'Large'
        END AS size_category
    FROM dframe
)
SELECT size_category,
       AVG(price_per_sqm) AS avg_price_sqm
FROM prop_size
GROUP BY size_category
ORDER BY avg_price_sqm;
```

------------------------------------------------------------------------

### 4. Inventory Pressure (Supply vs Demand)

Measure market saturation.

``` sql
WITH city_stats AS (
    SELECT city,
           COUNT(*) AS total_listings,
           AVG(days_on_market) AS avg_days
    FROM dframe
    WHERE listing_type = 'Sale'
    GROUP BY city
)
SELECT *,
       (total_listings * avg_days) AS pressure_score
FROM city_stats
ORDER BY pressure_score DESC;
```

------------------------------------------------------------------------

## Power BI Dashboard

-   Price trends & growth visualization\
-   City-level insights\
-   Inventory pressure analysis\
-   KPI metrics for decision making

------------------------------------------------------------------------

## Tech Stack

SQL (PostgreSQL) • Power BI • Python

------------------------------------------------------------------------

## Author

Vishva Suraj

