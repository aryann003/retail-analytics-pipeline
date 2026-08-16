CREATE VIEW monthly_revenue AS
SELECT
    SUM(f."Revenue") AS monthly_revenue,
    d."Year",
    d."Month"
FROM fact_sales f
JOIN dim_date d
    ON f."DateKey" = d."DateKey"
GROUP BY
    d."Year",
    d."Month";


CREATE VIEW customer_analysis AS
WITH customer_data AS (
    SELECT
        c."CustomerID",
        SUM(f."Revenue") AS total_revenue,
        COUNT(DISTINCT f."Invoice") AS total_orders
    FROM fact_sales f
    JOIN dim_customer c
        ON f."CustomerKey" = c."CustomerKey"
    GROUP BY
        c."CustomerID"
)

SELECT
    "CustomerID",
    total_revenue,
    total_orders,
    ROUND(total_revenue / total_orders, 2) AS AOV,

    CASE
        WHEN total_orders > 1 THEN 'Repeat'
        ELSE 'One-Time'
    END AS customer_type,

    CASE
        WHEN total_revenue >= 10000 THEN 'High Value'
        WHEN total_revenue >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS segment,

    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS revenue_contribution

FROM customer_data;