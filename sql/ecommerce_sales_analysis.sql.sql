-- =============================================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS
-- Database: ecommerce_analytics
-- Tool: MySQL
-- =============================================================
-- Notes:
-- 1. This script assumes customers and orders already exist.
-- 2. Revenue metrics use all rows in orders because the source file
--    does not define which order_status values should be excluded.
-- 3. Customer segmentation uses one consistent set of thresholds:
--    High Value >= 20,000; Medium Value >= 10,000; otherwise Low Value.
-- =============================================================

USE ecommerce_analytics;

-- =============================================================
-- 1. DATA VALIDATION
-- =============================================================

-- Row counts
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_orders FROM orders;

-- Duplicate customer IDs
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate order IDs
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Missing customer fields
SELECT
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(customer_name IS NULL) AS missing_customer_name,
    SUM(gender IS NULL) AS missing_gender,
    SUM(city IS NULL) AS missing_city,
    SUM(signup_date IS NULL) AS missing_signup_date
FROM customers;

-- Missing order fields
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(order_amount IS NULL) AS missing_order_amount,
    SUM(order_status IS NULL) AS missing_order_status
FROM orders;

-- Invalid order amounts
SELECT *
FROM orders
WHERE order_amount <= 0;

-- Order date range
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date
FROM orders;

-- Orders without a matching customer
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Customers without orders
SELECT COUNT(*) AS customers_without_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- Order status distribution
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Orders occurring before customer signup
SELECT COUNT(*) AS invalid_signup_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date < c.signup_date;


-- =============================================================
-- 2. CUSTOMER PROFILE
-- =============================================================

-- Customers by city
SELECT
    city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;

-- Customers by gender
SELECT
    gender,
    COUNT(*) AS customer_count
FROM customers
GROUP BY gender
ORDER BY customer_count DESC;


-- =============================================================
-- 3. OVERALL ORDER & REVENUE PERFORMANCE
-- =============================================================

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
    SUM(order_amount) AS total_revenue
FROM orders;

SELECT
    ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders;

SELECT
    MIN(order_amount) AS minimum_order,
    MAX(order_amount) AS maximum_order
FROM orders;


-- =============================================================
-- 4. ORDER STATUS ANALYSIS
-- =============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(order_amount) AS revenue
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- =============================================================
-- 5. MONTHLY REVENUE & ORDER PERFORMANCE
-- =============================================================

WITH monthly_metrics AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        COUNT(order_id) AS total_orders,
        SUM(order_amount) AS total_revenue,
        ROUND(AVG(order_amount), 2) AS average_order_value
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT *
FROM monthly_metrics
ORDER BY order_month;


-- =============================================================
-- 6. TOP CUSTOMERS
-- =============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;


-- =============================================================
-- 7. CUSTOMERS WITH NO ORDERS
-- =============================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.signup_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
ORDER BY c.customer_id;


-- =============================================================
-- 8. CITY PERFORMANCE
-- =============================================================

SELECT
    c.city,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS revenue,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY revenue DESC;


-- =============================================================
-- 9. TOP 3 CUSTOMERS PER CITY
-- =============================================================
-- ROW_NUMBER() returns exactly up to 3 customers per city.
-- DENSE_RANK() could return more than 3 rows when there are ties.

WITH customer_summary AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        SUM(o.order_amount) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.city
),
ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        city,
        total_spent,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_spent DESC, customer_id
        ) AS city_rank
    FROM customer_summary
)
SELECT
    customer_id,
    customer_name,
    city,
    total_spent,
    city_rank
FROM ranked_customers
WHERE city_rank <= 3
ORDER BY city, city_rank;


-- =============================================================
-- 10. RUNNING REVENUE
-- =============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_amount) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM monthly_revenue
ORDER BY order_month;


-- =============================================================
-- 11. MONTH-OVER-MONTH REVENUE GROWTH
-- =============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_amount) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
revenue_comparison AS (
    SELECT
        order_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    monthly_revenue,
    previous_month_revenue,
    ROUND(
        (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS mom_growth_percentage
FROM revenue_comparison
ORDER BY order_month;


-- =============================================================
-- 12. REVENUE CONTRIBUTION BY CITY
-- =============================================================

WITH city_revenue AS (
    SELECT
        c.city,
        SUM(o.order_amount) AS city_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.city
)
SELECT
    city,
    city_revenue,
    ROUND(
        city_revenue / NULLIF(SUM(city_revenue) OVER (), 0) * 100,
        2
    ) AS revenue_contribution_percentage
FROM city_revenue
ORDER BY city_revenue DESC;


-- =============================================================
-- 13. CUSTOMER SEGMENTATION
-- =============================================================
-- Consistent thresholds used throughout this project:
-- High Value   >= 20,000
-- Medium Value >= 10,000
-- Low Value    < 10,000

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.order_amount) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spent,
    CASE
        WHEN total_spent >= 20000 THEN 'High Value'
        WHEN total_spent >= 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_spending
ORDER BY total_spent DESC;


-- =============================================================
-- 14. TOP CUSTOMERS & REVENUE CONTRIBUTION
-- =============================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_spent,
        RANK() OVER (
            ORDER BY total_spent DESC
        ) AS customer_rank,
        SUM(total_spent) OVER () AS total_revenue
    FROM customer_revenue
)
SELECT
    customer_id,
    customer_rank,
    total_spent,
    ROUND(
        total_spent / NULLIF(total_revenue, 0) * 100,
        2
    ) AS revenue_contribution_percentage
FROM ranked_customers
WHERE customer_rank <= 10
ORDER BY customer_rank;


-- =============================================================
-- 15. TOP 20% CUSTOMER REVENUE CONTRIBUTION
-- =============================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_spent,
        ROW_NUMBER() OVER (
            ORDER BY total_spent DESC, customer_id
        ) AS customer_rank,
        COUNT(*) OVER () AS total_active_customers,
        SUM(total_spent) OVER () AS total_revenue
    FROM customer_revenue
)
SELECT
    SUM(total_spent) AS top_20_percent_revenue,
    MAX(total_revenue) AS total_revenue,
    ROUND(
        SUM(total_spent) / NULLIF(MAX(total_revenue), 0) * 100,
        2
    ) AS revenue_contribution_percentage
FROM ranked_customers
WHERE customer_rank <= CEIL(total_active_customers * 0.20);


-- =============================================================
-- 16. YEAR-OVER-YEAR REVENUE GROWTH
-- =============================================================
-- This comparison is valid when each monthly period exists in the
-- dataset. If months are missing, a calendar table is preferable.

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        DATE_FORMAT(order_date, '%Y-%m') AS month_label,
        SUM(order_amount) AS revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        DATE_FORMAT(order_date, '%Y-%m')
),
revenue_comparison AS (
    SELECT
        order_year,
        order_month,
        month_label,
        revenue,
        LAG(revenue, 12) OVER (
            ORDER BY order_year, order_month
        ) AS previous_year_revenue
    FROM monthly_revenue
)
SELECT
    month_label,
    revenue,
    previous_year_revenue,
    ROUND(
        (revenue - previous_year_revenue)
        / NULLIF(previous_year_revenue, 0) * 100,
        2
    ) AS yoy_growth_percentage
FROM revenue_comparison
ORDER BY month_label;


-- =============================================================
-- 17. BEST & WORST MONTH
-- =============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
ranked_months AS (
    SELECT
        order_month,
        revenue,
        RANK() OVER (ORDER BY revenue DESC) AS highest_rank,
        RANK() OVER (ORDER BY revenue ASC) AS lowest_rank
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue,
    CASE
        WHEN highest_rank = 1 THEN 'Highest Revenue'
        WHEN lowest_rank = 1 THEN 'Lowest Revenue'
        ELSE 'Normal'
    END AS performance
FROM ranked_months
ORDER BY revenue DESC;


-- =============================================================
-- 18. CUSTOMER PURCHASE FREQUENCY
-- =============================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN '1 Order'
        WHEN order_count BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN order_count BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE '10+ Orders'
    END AS purchase_frequency,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN '1 Order'
        WHEN order_count BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN order_count BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE '10+ Orders'
    END
ORDER BY customer_count DESC;


-- =============================================================
-- 19. REVENUE BY CUSTOMER SEGMENT
-- =============================================================

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
segmented_customers AS (
    SELECT
        customer_id,
        total_spent,
        CASE
            WHEN total_spent >= 20000 THEN 'High Value'
            WHEN total_spent >= 10000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_spending
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS average_spending,
    SUM(total_spent) AS total_segment_revenue
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_segment_revenue DESC;


-- =============================================================
-- 20. CITY YEAR-OVER-YEAR PERFORMANCE
-- =============================================================

WITH city_yearly_revenue AS (
    SELECT
        c.city,
        YEAR(o.order_date) AS order_year,
        SUM(o.order_amount) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.city,
        YEAR(o.order_date)
),
city_comparison AS (
    SELECT
        city,
        order_year,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY city
            ORDER BY order_year
        ) AS previous_year_revenue
    FROM city_yearly_revenue
)
SELECT
    city,
    order_year,
    revenue,
    previous_year_revenue,
    ROUND(
        (revenue - previous_year_revenue)
        / NULLIF(previous_year_revenue, 0) * 100,
        2
    ) AS yoy_growth_percentage
FROM city_comparison
ORDER BY city, order_year;


-- =============================================================
-- END OF E-COMMERCE ANALYTICS PROJECT
-- =============================================================
