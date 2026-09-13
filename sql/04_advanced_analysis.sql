-- ============================================================
-- E-Commerce Sales Analytics
-- File: 04_advanced_analysis.sql
-- Purpose: Advanced SQL analysis using CTEs and window functions
-- Database: MySQL
-- ============================================================


-- ============================================================
-- 1. RANK CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    customer_id,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(total_amount) DESC
    ) AS revenue_rank
FROM orders
GROUP BY customer_id;


-- ============================================================
-- 2. RUNNING REVENUE
-- ============================================================

WITH daily_sales AS (
    SELECT
        order_date,
        SUM(total_amount) AS daily_revenue
    FROM orders
    GROUP BY order_date
)

SELECT
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_date
        ),
        2
    ) AS cumulative_revenue
FROM daily_sales
ORDER BY order_date;


-- ============================================================
-- 3. MONTHLY REVENUE WITH MONTH-OVER-MONTH CHANGE
-- ============================================================

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

previous_month AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS month_over_month_growth
FROM previous_month
ORDER BY sales_month;


-- ============================================================
-- 4. TOP 3 CUSTOMERS
-- ============================================================

WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS customer_rank
    FROM customer_sales
)

SELECT
    customer_id,
    ROUND(total_revenue, 2) AS total_revenue,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY customer_rank;


-- ============================================================
-- 5. CUSTOMER ORDER FREQUENCY
-- ============================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    order_count,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN order_count >= 10 THEN 'Frequent'
        WHEN order_count >= 5 THEN 'Regular'
        ELSE 'Occasional'
    END AS purchase_frequency
FROM customer_orders
ORDER BY order_count DESC;


-- ============================================================
-- 6. REVENUE BY YEAR
-- ============================================================

SELECT
    YEAR(order_date) AS sales_year,
    ROUND(SUM(total_amount), 2) AS annual_revenue,
    RANK() OVER (
        ORDER BY SUM(total_amount) DESC
    ) AS revenue_rank
FROM orders
GROUP BY YEAR(order_date)
ORDER BY sales_year;
