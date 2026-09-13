-- ============================================================
-- E-Commerce Sales Analytics
-- File: 01_data_quality_checks.sql
-- Purpose: Validate source data before analysis
-- Database: MySQL
-- ============================================================


-- ============================================================
-- 1. CUSTOMER DATA QUALITY
-- ============================================================

-- Total number of customers
SELECT
    COUNT(*) AS total_customers
FROM customers;


-- Check for duplicate customer IDs
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Check for missing customer IDs
SELECT
    COUNT(*) AS missing_customer_ids
FROM customers
WHERE customer_id IS NULL;


-- ============================================================
-- 2. ORDER DATA QUALITY
-- ============================================================

-- Total number of orders
SELECT
    COUNT(*) AS total_orders
FROM orders;


-- Check for duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Check for missing order IDs
SELECT
    COUNT(*) AS missing_order_ids
FROM orders
WHERE order_id IS NULL;


-- Check for missing customer references
SELECT
    COUNT(*) AS orders_without_customer
FROM orders
WHERE customer_id IS NULL;


-- ============================================================
-- 3. REFERENTIAL INTEGRITY
-- ============================================================

-- Find orders that reference customers that do not exist
SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 4. BASIC ORDER DATE VALIDATION
-- ============================================================

-- Check for missing order dates
SELECT
    COUNT(*) AS missing_order_dates
FROM orders
WHERE order_date IS NULL;


-- Find the earliest and latest order dates
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date
FROM orders;


-- ============================================================
-- 5. DATASET SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders;
