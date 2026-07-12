-- ================================================================
-- E-Commerce Sales Intelligence — SQL Analysis
-- Author  : Nandan R
-- Dataset : 500 orders / 1,500 line items — India 2018
-- Engine  : MySQL 8+ / PostgreSQL
--           Zero-setup alternative: run sql_runner.py (uses DuckDB)
-- ================================================================


-- ────────────────────────────────────────────────────────────────
-- SECTION 1: EXECUTIVE KPIs
-- ────────────────────────────────────────────────────────────────

-- Q1. Full business summary
SELECT
    COUNT(DISTINCT o.`Order ID`)                AS total_orders,
    COUNT(*)                                    AS total_line_items,
    SUM(d.Amount)                               AS total_revenue,
    SUM(d.Profit)                               AS total_profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),2)  AS overall_margin_pct,
    COUNT(DISTINCT o.CustomerName)              AS unique_customers,
    SUM(d.Quantity)                             AS total_units_sold,
    ROUND(AVG(d.Amount),0)                      AS avg_line_item_value
FROM Orders o
JOIN Details d ON o.`Order ID` = d.`Order ID`;


-- Q2. Loss-making exposure — the most important risk metric
SELECT
    COUNT(*)                                                         AS total_line_items,
    SUM(CASE WHEN d.Profit < 0 THEN 1 ELSE 0 END)                  AS loss_items,
    ROUND(100.0*SUM(CASE WHEN d.Profit<0 THEN 1 ELSE 0 END)
        /COUNT(*), 1)                                                AS loss_item_pct,
    SUM(CASE WHEN d.Profit < 0 THEN d.Profit ELSE 0 END)            AS total_loss,
    SUM(CASE WHEN d.Profit > 0 THEN d.Profit ELSE 0 END)            AS total_gain,
    SUM(d.Profit)                                                    AS net_profit
FROM Details d;


-- ────────────────────────────────────────────────────────────────
-- SECTION 2: PROFITABILITY ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q3. Sub-category profitability — ranked best to worst
SELECT
    d.`Sub-Category`                                        AS sub_category,
    d.Category,
    COUNT(*)                                                AS line_items,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    SUM(d.Quantity)                                         AS units_sold,
    RANK() OVER (ORDER BY SUM(d.Profit) DESC)               AS profit_rank,
    RANK() OVER (ORDER BY SUM(d.Amount) DESC)               AS revenue_rank
FROM Details d
GROUP BY d.`Sub-Category`, d.Category
ORDER BY profit DESC;


-- Q4. Loss-leader identification — net-negative sub-categories
SELECT
    d.`Sub-Category`                                        AS sub_category,
    d.Category,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS net_profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    COUNT(*)                                                AS transactions
FROM Details d
GROUP BY d.`Sub-Category`, d.Category
HAVING SUM(d.Profit) < 0
ORDER BY net_profit ASC;


-- Q5. Category margin and revenue share
SELECT
    d.Category,
    COUNT(*)                                                AS line_items,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    ROUND(100.0*SUM(d.Amount)/SUM(SUM(d.Amount)) OVER(),1)  AS rev_share_pct
FROM Details d
GROUP BY d.Category
ORDER BY revenue DESC;


-- ────────────────────────────────────────────────────────────────
-- SECTION 3: TIME SERIES & SEASONALITY
-- ────────────────────────────────────────────────────────────────

-- Q6. Monthly revenue, profit and margin
SELECT
    MONTH(o.`Order Date`)                                   AS month_num,
    MONTHNAME(o.`Order Date`)                               AS month_name,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    ROUND(100.0*SUM(d.Amount)/SUM(SUM(d.Amount)) OVER(),1)  AS rev_share_pct
FROM Orders o
JOIN Details d ON o.`Order ID`=d.`Order ID`
GROUP BY MONTH(o.`Order Date`), MONTHNAME(o.`Order Date`)
ORDER BY month_num;


-- Q7. Quarterly revenue with running cumulative
SELECT
    QUARTER(o.`Order Date`)                                 AS quarter,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    ROUND(100.0*SUM(d.Amount)/SUM(SUM(d.Amount)) OVER(),1)  AS rev_share_pct,
    SUM(SUM(d.Amount)) OVER (ORDER BY QUARTER(o.`Order Date`)) AS cumulative_revenue
FROM Orders o
JOIN Details d ON o.`Order ID`=d.`Order ID`
GROUP BY QUARTER(o.`Order Date`)
ORDER BY quarter;


-- Q8. Month-over-month revenue change using LAG
WITH monthly AS (
    SELECT
        MONTH(o.`Order Date`)       AS month_num,
        MONTHNAME(o.`Order Date`)   AS month_name,
        SUM(d.Amount)               AS revenue,
        SUM(d.Profit)               AS profit
    FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
    GROUP BY MONTH(o.`Order Date`), MONTHNAME(o.`Order Date`)
)
SELECT
    month_name, revenue, profit,
    LAG(revenue) OVER (ORDER BY month_num)          AS prev_revenue,
    ROUND(100.0*(revenue-LAG(revenue) OVER (ORDER BY month_num))
        /LAG(revenue) OVER (ORDER BY month_num),1)  AS mom_growth_pct
FROM monthly ORDER BY month_num;


-- Q9. Seasonality index per month
WITH monthly_totals AS (
    SELECT
        MONTH(o.`Order Date`)       AS month_num,
        MONTHNAME(o.`Order Date`)   AS month_name,
        SUM(d.Amount)               AS monthly_rev
    FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
    GROUP BY MONTH(o.`Order Date`), MONTHNAME(o.`Order Date`)
),
avg_month AS (SELECT AVG(monthly_rev) AS avg_rev FROM monthly_totals)
SELECT
    m.month_name,
    m.monthly_rev,
    ROUND(m.monthly_rev/a.avg_rev,2)        AS seasonality_index,
    CASE
        WHEN m.monthly_rev/a.avg_rev > 1.25 THEN 'Peak'
        WHEN m.monthly_rev/a.avg_rev < 0.75 THEN 'Weak'
        ELSE 'Normal'
    END                                     AS season_label
FROM monthly_totals m, avg_month a
ORDER BY m.month_num;


-- ────────────────────────────────────────────────────────────────
-- SECTION 4: REGIONAL PERFORMANCE
-- ────────────────────────────────────────────────────────────────

-- Q10. State revenue, profit and market share
SELECT
    o.State,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    ROUND(100.0*SUM(d.Amount)/SUM(SUM(d.Amount)) OVER(),1)  AS rev_share_pct,
    RANK() OVER (ORDER BY SUM(d.Amount) DESC)               AS revenue_rank
FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
GROUP BY o.State ORDER BY revenue DESC;


-- Q11. City performance with average order value
SELECT
    o.City, o.State,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    COUNT(DISTINCT o.CustomerName)                          AS unique_customers,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Amount)/COUNT(DISTINCT o.`Order ID`))       AS avg_order_value,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct
FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
GROUP BY o.City, o.State
HAVING SUM(d.Amount) > 10000
ORDER BY revenue DESC;


-- Q12. Top-selling sub-category per state (RANK window)
WITH state_sub AS (
    SELECT
        o.State,
        d.`Sub-Category`                                    AS sub_category,
        SUM(d.Amount)                                       AS revenue,
        RANK() OVER (PARTITION BY o.State
                     ORDER BY SUM(d.Amount) DESC)           AS rk
    FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
    GROUP BY o.State, d.`Sub-Category`
)
SELECT State, sub_category, revenue
FROM state_sub WHERE rk = 1
ORDER BY revenue DESC;


-- ────────────────────────────────────────────────────────────────
-- SECTION 5: PAYMENT MODE ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q13. Payment mode profitability matrix
SELECT
    d.PaymentMode,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    ROUND(SUM(d.Amount)/COUNT(DISTINCT o.`Order ID`))       AS avg_order_value,
    ROUND(100.0*COUNT(DISTINCT o.`Order ID`)
        /SUM(COUNT(DISTINCT o.`Order ID`)) OVER(),1)        AS order_share_pct
FROM Details d JOIN Orders o ON d.`Order ID`=o.`Order ID`
GROUP BY d.PaymentMode ORDER BY revenue DESC;


-- Q14. Payment preference by product category
SELECT
    d.Category, d.PaymentMode,
    COUNT(*)                                                AS line_items,
    ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY d.Category),1) AS pct_within_cat
FROM Details d
GROUP BY d.Category, d.PaymentMode
ORDER BY d.Category, line_items DESC;


-- ────────────────────────────────────────────────────────────────
-- SECTION 6: CUSTOMER ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q15. Top 20 customers: revenue rank vs profit rank
SELECT
    o.CustomerName,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct,
    RANK() OVER (ORDER BY SUM(d.Amount) DESC)               AS revenue_rank,
    RANK() OVER (ORDER BY SUM(d.Profit) DESC)               AS profit_rank
FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
GROUP BY o.CustomerName
ORDER BY revenue DESC LIMIT 20;


-- Q16. Repeat vs one-time buyer split
WITH customer_orders AS (
    SELECT CustomerName, COUNT(DISTINCT `Order ID`) AS order_count
    FROM Orders GROUP BY CustomerName
)
SELECT
    CASE WHEN order_count=1 THEN 'One-time buyer'
         ELSE 'Repeat buyer' END                            AS customer_type,
    COUNT(*)                                                AS customers,
    ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),1)            AS customer_pct
FROM customer_orders
GROUP BY CASE WHEN order_count=1 THEN 'One-time buyer' ELSE 'Repeat buyer' END;


-- Q17. High-revenue but loss-making customers — margin risk flag
SELECT
    o.CustomerName,
    COUNT(DISTINCT o.`Order ID`)                            AS orders,
    SUM(d.Amount)                                           AS revenue,
    SUM(d.Profit)                                           AS profit,
    ROUND(SUM(d.Profit)*100.0/SUM(d.Amount),1)              AS margin_pct
FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
GROUP BY o.CustomerName
HAVING SUM(d.Profit) < 0
ORDER BY revenue DESC LIMIT 15;


-- ────────────────────────────────────────────────────────────────
-- SECTION 7: ADVANCED ANALYTICS
-- ────────────────────────────────────────────────────────────────

-- Q18. 3-month rolling average revenue (smoothed trend)
WITH monthly AS (
    SELECT MONTH(o.`Order Date`) AS month_num,
           MONTHNAME(o.`Order Date`) AS month_name,
           SUM(d.Amount) AS revenue
    FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
    GROUP BY MONTH(o.`Order Date`), MONTHNAME(o.`Order Date`)
)
SELECT month_name, revenue,
    ROUND(AVG(revenue) OVER (
        ORDER BY month_num
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ),0) AS revenue_3mo_avg
FROM monthly ORDER BY month_num;


-- Q19. Order value bands — where does revenue concentrate?
WITH order_totals AS (
    SELECT `Order ID`, SUM(Amount) AS order_value
    FROM Details GROUP BY `Order ID`
)
SELECT
    CASE
        WHEN order_value < 200              THEN 'Under ₹200'
        WHEN order_value BETWEEN 200 AND 499   THEN '₹200–₹499'
        WHEN order_value BETWEEN 500 AND 999   THEN '₹500–₹999'
        WHEN order_value BETWEEN 1000 AND 1999 THEN '₹1K–₹2K'
        ELSE '₹2K+'
    END                                     AS order_band,
    COUNT(*)                                AS orders,
    SUM(order_value)                        AS revenue,
    ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),1)              AS order_pct,
    ROUND(100.0*SUM(order_value)/SUM(SUM(order_value)) OVER(),1) AS rev_pct
FROM order_totals
GROUP BY
    CASE
        WHEN order_value < 200              THEN 'Under ₹200'
        WHEN order_value BETWEEN 200 AND 499   THEN '₹200–₹499'
        WHEN order_value BETWEEN 500 AND 999   THEN '₹500–₹999'
        WHEN order_value BETWEEN 1000 AND 1999 THEN '₹1K–₹2K'
        ELSE '₹2K+'
    END
ORDER BY MIN(order_value);


-- Q20. Customer revenue quartiles (NTILE)
WITH customer_stats AS (
    SELECT
        o.CustomerName,
        COUNT(DISTINCT o.`Order ID`)    AS orders,
        SUM(d.Amount)                   AS revenue,
        SUM(d.Profit)                   AS profit
    FROM Orders o JOIN Details d ON o.`Order ID`=d.`Order ID`
    GROUP BY o.CustomerName
)
SELECT *,
    ROUND(profit*100.0/revenue,1)           AS margin_pct,
    NTILE(4) OVER (ORDER BY revenue)        AS revenue_quartile
FROM customer_stats
ORDER BY revenue_quartile DESC, revenue DESC;
