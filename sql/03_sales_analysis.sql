-- ============================================================
-- E-Commerce Sales Analytics
-- File: 03_sales_analysis.sql
-- Purpose: Analyze sales performance and revenue trends
-- Database: MySQL
-- ============================================================


-- ============================================================
-- 1. TOTAL REVENUE
-- ============================================================

SELECT
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders;


-- ============================================================
-- 2. TOTAL ORDERS
-- ============================================================

SELECT
    COUNT(*) AS total_orders
FROM orders;


-- ============================================================
-- 3. AVERAGE ORDER VALUE
-- ============================================================

SELECT
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders;


-- ============================================================
-- 4. MINIMUM AND MAXIMUM ORDER VALUE
-- ============================================================

SELECT
    MIN(total_amount) AS minimum_order_value,
    MAX(total_amount) AS maximum_order_value
FROM orders;


-- ============================================================
-- 5. REVENUE BY MONTH
-- ============================================================

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    ROUND(SUM(total_amount), 2) AS monthly_revenue
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


-- ============================================================
-- 6. ORDERS BY MONTH
-- ============================================================

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS monthly_orders
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


-- ============================================================
-- 7. DAILY REVENUE
-- ============================================================

SELECT
    order_date,
    ROUND(SUM(total_amount), 2) AS daily_revenue
FROM orders
GROUP BY order_date
ORDER BY order_date;


-- ============================================================
-- 8. TOP 10 ORDERS BY VALUE
-- ============================================================

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 10;


-- ============================================================
-- 9. REVENUE BY CUSTOMER
-- ============================================================

SELECT
    customer_id,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
GROUP BY customer_id
ORDER BY total_revenue DESC;


-- ============================================================
-- 10. REVENUE CONTRIBUTION BY CUSTOMER
-- ============================================================

SELECT
    customer_id,
    ROUND(SUM(total_amount), 2) AS customer_revenue,
    ROUND(
        SUM(total_amount) /
        (SELECT SUM(total_amount) FROM orders) * 100,
        2
    ) AS revenue_percentage
FROM orders
GROUP BY customer_id
ORDER BY customer_revenue DESC;
