-- ============================================================
-- E-Commerce Sales Analytics
-- File: 05_business_insights.sql
-- Purpose: Answer practical business questions
-- Database: MySQL
-- ============================================================


-- ============================================================
-- BUSINESS QUESTION 1
-- Who are the highest-value customers?
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- BUSINESS QUESTION 2
-- Which countries generate the most revenue?
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;


-- ============================================================
-- BUSINESS QUESTION 3
-- What is the average revenue per customer?
-- ============================================================

SELECT
    ROUND(
        SUM(total_amount) /
        COUNT(DISTINCT customer_id),
        2
    ) AS revenue_per_customer
FROM orders;


-- ============================================================
-- BUSINESS QUESTION 4
-- What percentage of customers have placed an order?
-- ============================================================

SELECT
    ROUND(
        COUNT(DISTINCT o.customer_id) /
        COUNT(DISTINCT c.customer_id) * 100,
        2
    ) AS customer_conversion_percentage
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;


-- ============================================================
-- BUSINESS QUESTION 5
-- What are the largest orders?
-- ============================================================

SELECT
    o.order_id,
    o.customer_id,
    c.customer_name,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.total_amount DESC
LIMIT 10;


-- ============================================================
-- BUSINESS QUESTION 6
-- Which customers have placed multiple orders?
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;


-- ============================================================
-- BUSINESS QUESTION 7
-- What is the monthly revenue trend?
-- ============================================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;
