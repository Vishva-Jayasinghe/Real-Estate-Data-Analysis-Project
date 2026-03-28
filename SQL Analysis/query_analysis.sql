SELECT * FROM dframe

/* Problem 1 — Top 3 Expensive Properties per City */
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



/* Problem 2 — Month-over-Month Price Growth */
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

/*Problem 3 — Top 3 Floors with Highest Avg Price per sqm */
WITH floor_avg AS (
    SELECT 
		city,
        property_type,
        floor_number,
        ROUND(AVG(price_per_sqm)::numeric,3)AS avg_price_sqm
    FROM dframe
    WHERE floor_number IS NOT NULL
    GROUP BY city,property_type, floor_number
	ORDER BY city
),
ranked_floors AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY city,property_type
               ORDER BY avg_price_sqm DESC
           ) AS rank
    FROM floor_avg
)
SELECT city,
	   property_type,
       floor_number,
       avg_price_sqm,
       rank
FROM ranked_floors
WHERE rank <= 3;


/* Problem 4 — Expensive Properties Without Amenities */
WITH city_median AS (
    SELECT city,
           PERCENTILE_CONT(0.5) 
           WITHIN GROUP (ORDER BY sale_price_eur) AS median_price
    FROM dframe
    GROUP BY city
)
SELECT d.property_id,
       d.city,
       d.sale_price_eur,
       d.property_type
FROM dframe d
JOIN city_median c
ON d.city = c.city
WHERE 
    d.sale_price_eur > c.median_price
    AND (d.gym IS NULL OR d.gym = 'No')
    AND (d.elevator IS NULL OR d.elevator = 'No')
    AND (d.swimming_pool IS NULL OR d.swimming_pool = 'No');


--- 5 Most advanced and business use problems



/* Problem 1 — Identify Undervalued Properties

Business Goal:
Find properties priced below market value in their city → good investment opportunities.

Task:
Compute average price_per_sqm per city
Find properties where:
price_per_sqm < 0.8 * city_avg

Return:
property_id
city
price_per_sqm
city_avg_price_per_sqm
% difference from city average

*/

WITH data AS (
    SELECT 
        city,
        listing_type,
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



/* Problem 2 — Market Momentum
Business Goal:
Identify which cities are growing or declining in price.

Task:
Compute average sale price per city per month
Calculate month-over-month growth %
Classify cities:
 positive
 negative 
*/


with sales AS (

SELECT city,
	   EXTRACT(YEAR FROM listing_date) AS year,
	   EXTRACT(MONTH FROM listing_date) AS month,
	   ROUND(AVG(sale_price_eur)::numeric ,2) AS avg_sale_price
FROM dframe
WHERE listing_type ='Sale'
GROUP BY 1,2,3
ORDER BY 1,2,3
) , growth AS (
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
	   mom_growth_rate,
	   CASE WHEN mom_growth_rate < 0 THEN 'Positive'
	   		WHEN mom_growth_rate > 0 THEN 'Negative'
			ELSE 'No Growth'
	   END AS growth_type
FROM growth

/*Problem 3 — Price Efficiency vs Property Size

Business Goal:
Understand if larger properties are more cost-efficient per sqm

Task:
Group properties into size buckets:
Small (< 80 sqm)
Medium (80–150 sqm)
Large (>150 sqm)
For each bucket:
Avg price_per_sqm
Avg sale_price_eur
Rank buckets by efficiency
*/ 

WITH prop_size AS (
    SELECT *,
        CASE 
            WHEN square_meters < 80 THEN 'Small'
            WHEN square_meters BETWEEN 80 AND 150 THEN 'Medium'
            ELSE 'Large'
        END AS property_by_size
    FROM dframe
),

bucket_data AS (
    SELECT 
        city,
        property_by_size,
        EXTRACT(YEAR FROM listing_date) AS year,
        ROUND(AVG(price_per_sqm)::numeric, 3) AS avg_price_per_sqm,
        ROUND(AVG(sale_price_eur)::numeric, 3) AS avg_sale_price
    FROM prop_size
    GROUP BY city, property_by_size, year
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY city, year 
            ORDER BY avg_price_per_sqm DESC 
        ) AS rank
    FROM bucket_data
)
SELECT *
FROM ranked
WHERE rank = 1
ORDER BY city, year;


/*Problem 4 — Inventory Pressure (Supply vs Demand)

Business Goal:
Find cities where properties are not selling quickly

Task:
Compute:
Avg days_on_market per city
Total listings per city
Identify cities where:
High listings AND high days_on_market
Rank cities by “inventory pressure score”

*/

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
),

ranked AS (
    SELECT *,
        DENSE_RANK() OVER (
            ORDER BY inventory_pressure_score DESC
        ) AS pressure_rank
    FROM scored
)

SELECT 
    city,
    total_listings,
    avg_days_on_market,
    inventory_pressure_score,
    
    CASE 
        WHEN total_listings > (SELECT AVG(total_listings) FROM city_stats)
         AND avg_days_on_market > (SELECT AVG(avg_days_on_market) FROM city_stats)
        THEN 'High Pressure'
        ELSE 'Normal'
    END AS market_condition,

    pressure_rank

FROM ranked
ORDER BY pressure_rank;





