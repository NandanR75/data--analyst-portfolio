-- Retail Sales & Growth Analysis
-- Dataset columns: OrderID, Date, Region, Product, Sales, Profit

-- 1. Total sales and profit
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM sales_data;

-- 2. Sales and profit by region
SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM sales_data
GROUP BY Region
ORDER BY Total_Sales DESC;

-- 3. Sales and profit by product
SELECT
    Product,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM sales_data
GROUP BY Product
ORDER BY Total_Sales DESC;

-- 4. Sales trend by date
SELECT
    Date,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM sales_data
GROUP BY Date
ORDER BY Date;

-- 5. Profit margin by region
SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    CASE
        WHEN SUM(Sales) = 0 THEN 0
        ELSE SUM(Profit) * 100.0 / SUM(Sales)
    END AS Profit_Margin_Percent
FROM sales_data
GROUP BY Region
ORDER BY Profit_Margin_Percent DESC;
