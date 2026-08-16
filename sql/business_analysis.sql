-- Customer Segmentation

WITH customer_revenue AS (
    SELECT
        c."CustomerID",
        SUM(f."Revenue") AS total_revenue
    FROM fact_sales f
    JOIN dim_customer c
        ON f."CustomerKey" = c."CustomerKey"
    GROUP BY c."CustomerID"
)

SELECT
    "CustomerID",
    total_revenue,
    CASE
        WHEN total_revenue >= 10000 THEN 'High Value'
        WHEN total_revenue >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS "Segment"
FROM customer_revenue;


-- Average Order Value

WITH customer_orders AS (
    SELECT
        c."CustomerID",
        SUM(f."Revenue") AS total_revenue,
        COUNT(DISTINCT f."Invoice") AS total_orders
    FROM fact_sales f
    JOIN dim_customer c
        ON f."CustomerKey" = c."CustomerKey"
    GROUP BY c."CustomerID"
)

SELECT
    "CustomerID",
    total_revenue,
    total_orders,
    ROUND(total_revenue / total_orders, 2) AS "AOV"
FROM customer_orders;


-- Repeat vs One-Time Customers

WITH customer_orders AS (
    SELECT
        c."CustomerID",
        COUNT(DISTINCT f."Invoice") AS total_orders
    FROM fact_sales f
    JOIN dim_customer c
        ON f."CustomerKey" = c."CustomerKey"
    GROUP BY c."CustomerID"
)

SELECT
    "CustomerID",
    total_orders,
    CASE
        WHEN total_orders > 1 THEN 'Repeat'
        ELSE 'One-Time'
    END AS "CustomerType"
FROM customer_orders;


-- Customer Revenue Contribution

WITH customer_revenue AS (
    SELECT
        c."CustomerID",
        SUM(f."Revenue") AS total_revenue
    FROM fact_sales f
    JOIN dim_customer c
        ON f."CustomerKey" = c."CustomerKey"
    GROUP BY c."CustomerID"
)

SELECT
    "CustomerID",
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS revenue_contribution
FROM customer_revenue;


-- Return Rate

SELECT
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE "InvoiceType" = 'Return'
    ) AS return_transactions,
    COUNT(*) FILTER (
        WHERE "InvoiceType" = 'Return'
    ) * 100.0 / COUNT(*) AS return_rate
FROM fact_sales;