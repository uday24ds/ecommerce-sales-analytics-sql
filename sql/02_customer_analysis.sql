-- ============================================================
-- E-Commerce Sales Analytics
-- File: 02_customer_analysis.sql
-- Purpose: Analyze customer behavior and value
-- Database: MySQL
-- ============================================================


-- ============================================================
-- 1. CUSTOMER COUNT
-- ============================================================

SELECT
    COUNT(*) AS total_customers
FROM customers;


-- ============================================================
-- 2. CUSTOMER DISTRIBUTION BY COUNTRY
-- ============================================================

SELECT
    country,
    COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;


-- ============================================================
-- 3. CUSTOMER ORDERS
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_orders DESC;


-- ============================================================
-- 4. CUSTOMER REVENUE
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. AVERAGE ORDER VALUE BY CUSTOMER
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue,
    ROUND(AVG(o.total_amount), 2) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC;


-- ============================================================
-- 6. TOP 10 CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 7. CUSTOMER SEGMENTATION
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_revenue,
    CASE
        WHEN SUM(o.total_amount) >= 5000 THEN 'High Value'
        WHEN SUM(o.total_amount) >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC;


-- ============================================================
-- 8. ACTIVE VS INACTIVE CUSTOMERS
-- ============================================================

SELECT
    CASE
        WHEN COUNT(o.order_id) > 0 THEN 'Active'
        ELSE 'Inactive'
    END AS customer_status,
    COUNT(*) AS customer_count
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    CASE
        WHEN COUNT(o.order_id) > 0 THEN 'Active'
        ELSE 'Inactive'
    END;
