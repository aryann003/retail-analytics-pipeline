-- Total sales
SELECT 
    COUNT(*) AS total_rows,
    SUM("Revenue") AS net_revenue
FROM fact_sales;


-- Check invalid date keys
SELECT 
    COUNT(*) AS invalid_date_keys
FROM fact_sales f
LEFT JOIN dim_date d
    ON f."DateKey" = d."DateKey"
WHERE d."DateKey" IS NULL;


-- Check duplicate product keys
SELECT
    "ProductKey",
    COUNT(*) AS count
FROM dim_product
GROUP BY "ProductKey"
HAVING COUNT(*) > 1;


-- Check duplicate customer keys
SELECT
    "CustomerKey",
    COUNT(*) AS count
FROM dim_customer
GROUP BY "CustomerKey"
HAVING COUNT(*) > 1;


-- Check duplicate date keys
SELECT
    "DateKey",
    COUNT(*) AS count
FROM dim_date
GROUP BY "DateKey"
HAVING COUNT(*) > 1;


-- Check NULL values in fact table
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE "ProductKey" IS NULL) AS null_product,
    COUNT(*) FILTER (WHERE "CustomerKey" IS NULL) AS null_customer,
    COUNT(*) FILTER (WHERE "DateKey" IS NULL) AS null_date,
    COUNT(*) FILTER (WHERE "Revenue" IS NULL) AS null_revenue
FROM fact_sales;


-- Check constraints
SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND table_name = 'fact_sales';


-- Revenue by invoice type
SELECT
    "InvoiceType",
    COUNT(*) AS transactions,
    SUM("Revenue") AS revenue
FROM fact_sales
GROUP BY "InvoiceType";


-- Top 10 products
SELECT
    p."StockCode",
    p."Description",
    SUM(f."Revenue") AS total_revenue
FROM fact_sales f
JOIN dim_product p
    ON f."ProductKey" = p."ProductKey"
GROUP BY
    p."StockCode",
    p."Description"
ORDER BY total_revenue DESC
LIMIT 10;


-- Top 10 customers
SELECT
    c."CustomerID",
    SUM(f."Revenue") AS total_revenue
FROM fact_sales f
JOIN dim_customer c
    ON f."CustomerKey" = c."CustomerKey"
WHERE c."CustomerID" <> 0
GROUP BY c."CustomerID"
ORDER BY total_revenue DESC
LIMIT 10;


-- Revenue by country
SELECT
    c."Country",
    SUM(f."Revenue") AS total_revenue
FROM fact_sales f
JOIN dim_customer c
    ON f."CustomerKey" = c."CustomerKey"
GROUP BY c."Country"
ORDER BY total_revenue DESC;


-- Unknown and unspecified countries
SELECT
    c."Country",
    COUNT(*) AS transactions,
    COUNT(DISTINCT f."CustomerKey") AS customers,
    SUM(f."Revenue") AS revenue
FROM fact_sales f
JOIN dim_customer c
    ON f."CustomerKey" = c."CustomerKey"
WHERE c."Country" IN ('Unknown', 'Unspecified')
GROUP BY c."Country"
ORDER BY revenue DESC;


-- Monthly revenue
SELECT
    d."Year",
    d."Month",
    SUM(f."Revenue") AS revenue
FROM fact_sales f
JOIN dim_date d
    ON f."DateKey" = d."DateKey"
GROUP BY
    d."Year",
    d."Month"
ORDER BY
    d."Year",
    d."Month";


-- Top 3 products in each country
WITH revenue_by_country AS (
    SELECT
        SUM(f."Revenue") AS revenue,
        p."Description",
        c."Country"
    FROM fact_sales f
    JOIN dim_product p
        ON f."ProductKey" = p."ProductKey"
    JOIN dim_customer c
        ON f."CustomerKey" = c."CustomerKey"
    GROUP BY
        c."Country",
        p."Description"
),

ranked_product AS (
    SELECT
        "Country",
        "Description",
        revenue,
        RANK() OVER (
            PARTITION BY "Country"
            ORDER BY revenue DESC
        ) AS product_rnk
    FROM revenue_by_country
)

SELECT
    "Country",
    "Description",
    revenue,
    product_rnk
FROM ranked_product
WHERE product_rnk <= 3;