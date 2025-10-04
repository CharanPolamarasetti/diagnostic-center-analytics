-- ===============================================================================
-- Provide the owner with key insights on revenue trends and top-performing tests 
-- to optimize business strategy.
-- ===============================================================================

-- =========================================================================
-- Revenue Trends (daily, monthly & cumulative)
-- =========================================================================

-- Daily Revenue Trend
-- Aggregates the total revenue collected on each billing date.
SELECT billing_date AS revenue_day, SUM(amount) AS daily_revenue
FROM billing
GROUP BY 1
ORDER BY 1;

-- Monthly Revenue Trend
-- Extract the Year-Month string for grouping to show seasonality and growth.
SELECT TO_CHAR(billing_date, 'YYYY-MM') AS revenue_month, SUM(amount) AS monthly_revenue
FROM billing
GROUP BY 1
ORDER BY 1;

-- Monthly Cumulative Revenue
-- Calculate the cumulative sum of revenue over time.
-- This shows the total growth of earnings from the start date.
SELECT
    TO_CHAR(billing_date, 'YYYY-MM') AS revenue_month,
    SUM(SUM(amount)) OVER (ORDER BY TO_CHAR(billing_date, 'YYYY-MM')) AS cumulative_revenue
FROM billing
GROUP BY 1
ORDER BY 1;


-- ==============================
-- Revenue by test and category
-- ==============================

-- Find the most popular tests and rank them inside their categories.
-- For each test, calculate the total revenue it brings in,
-- then order the tests by revenue within each category.

WITH CategoryRevenue AS (
    SELECT
        t.category,
        t.test_name,
        SUM(t.cost) AS test_revenue
    FROM test_results tr
    JOIN tests t ON tr.test_id = t.test_id
    GROUP BY 1, 2
)
SELECT
    category,
    test_name,
    test_revenue,
    RANK() OVER (PARTITION BY category ORDER BY test_revenue DESC) AS category_rank
FROM CategoryRevenue
ORDER BY category, category_rank;


-- Top 10 most requested tests by volume
SELECT t.test_name, COUNT(tr.result_id) AS total_volume
FROM test_results tr
JOIN tests t ON tr.test_id = t.test_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
