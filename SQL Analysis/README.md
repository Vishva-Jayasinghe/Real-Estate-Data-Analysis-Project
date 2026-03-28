[Real_Estate_SQL_Project_README (1).md](https://github.com/user-attachments/files/26323098/Real_Estate_SQL_Project_README.1.md)
# 🏡 Real Estate Data Analysis Project

## 📌 Project Overview
This project focuses on advanced SQL-based analysis of real estate data to generate actionable business insights.  
The dataset (`dframe`) contains property listings with attributes such as price, city, property type, size, and amenities.

The goal is to simulate real-world business problems and solve them using advanced SQL techniques such as:
- Common Table Expressions (CTEs)
- Window Functions
- Ranking Functions
- Aggregations
- Business-driven logic

---

## 🛠️ Tools & Technologies
- **SQL (PostgreSQL)**
- **Power BI (for visualization)**
- **Python (for data cleaning - optional integration)**

---

## 📊 Key Business Problems & Solutions

---

### 🔹 Problem 1: Top 3 Most Expensive Properties per City
```sql
WITH ranked_properties AS (
    SELECT city,
           property_id,
           sale_price_eur,
           DENSE_RANK() OVER (
               PARTITION BY city
               ORDER BY sale_price_eur DESC
           ) AS rank
    FROM dframe
)
SELECT city, property_id, sale_price_eur, rank
FROM ranked_properties
WHERE rank <= 3;
```

---

### 🔹 Problem 2: Month-over-Month Price Growth
```sql
WITH monthly_avg AS (
    SELECT 
        DATE_TRUNC('month', listing_date) AS month,
        ROUND(AVG(sale_price_eur)::numeric,3) AS avg_price
    FROM dframe
    GROUP BY month
),
lagged_data AS (
    SELECT 
        month,
        avg_price,
        LAG(avg_price) OVER (ORDER BY month) AS prev_avg_price
    FROM monthly_avg
)
SELECT 
    month,
    avg_price,
    ROUND(
        COALESCE(
            ((avg_price - prev_avg_price) / NULLIF(prev_avg_price, 0))::numeric * 100,
        0),
    2) AS mom_growth_pct
FROM lagged_data;
```

---

### 🔹 Problem 3: Undervalued Properties (Investment Opportunities)
```sql
WITH data AS (
    SELECT 
        city,
        property_id,
        property_type,
        ROUND(price_per_sqm::numeric, 3) AS price_per_sqm,
        ROUND(AVG(price_per_sqm) OVER (PARTITION BY city)::numeric, 3) AS city_avg
    FROM dframe
    WHERE listing_type = 'Sale'
)
SELECT 
    city,
    property_id,
    property_type,
    price_per_sqm,
    city_avg,
    ROUND(((city_avg - price_per_sqm) / city_avg) * 100, 2) || '%' AS discount_pct
FROM data
WHERE price_per_sqm < 0.8 * city_avg;
```

---

### 🔹 Problem 4: Market Momentum Analysis
```sql
WITH sales AS (
SELECT city,
       EXTRACT(YEAR FROM listing_date) AS year,
       EXTRACT(MONTH FROM listing_date) AS month,
       ROUND(AVG(sale_price_eur)::numeric ,2) AS avg_sale_price
FROM dframe
WHERE listing_type ='Sale'
GROUP BY 1,2,3
),
growth AS (
SELECT city,
       year,
       month,
       avg_sale_price,
COALESCE(
    ROUND(
        (
            (avg_sale_price - LAG(avg_sale_price) OVER (PARTITION BY city ORDER BY year, month)) 
            / NULLIF(LAG(avg_sale_price) OVER (PARTITION BY city ORDER BY year, month), 0)
 ) * 100,2),0) AS mom_growth_rate
FROM sales
)
SELECT city,
       year,
       month,
       avg_sale_price,
       mom_growth_rate
FROM growth;
```

---

### 🔹 Problem 5: Inventory Pressure Analysis
```sql
WITH city_stats AS (
    SELECT 
        city,
        COUNT(property_id) AS total_listings,
        ROUND(AVG(days_on_market)::numeric, 2) AS avg_days_on_market
    FROM dframe
    WHERE listing_type = 'Sale'
    GROUP BY city
),
scored AS (
    SELECT *,
        (total_listings * avg_days_on_market) AS inventory_pressure_score
    FROM city_stats
)
SELECT *
FROM scored
ORDER BY inventory_pressure_score DESC;
```

---

## 📈 Business Insights Generated
- Identified high-value properties per city
- Tracked price growth trends over time
- Detected undervalued properties for investment
- Analyzed market momentum (growth/decline)
- Measured supply-demand imbalance (inventory pressure)

---
## Future Works (Next Task) 
--------------------------------------

## 📊 Power BI Dashboard
Suggested visuals:
- Price trends over time (Line Chart)
- City-wise average prices (Bar Chart)
- Inventory pressure heatmap
- Property size vs price efficiency

---

## 🚀 Conclusion
This project demonstrates strong analytical thinking and the ability to translate business problems into SQL solutions.  
It highlights real-world use cases relevant to **Data Analysts** and **Business Intelligence Developers**.

---

## 👨‍💻 Author
**Vishva Suraj**  
Aspiring Data Analyst | SQL | Power BI | Python
