-- Display all records
SELECT *
FROM car_sales;

-- Total cars sold
SELECT COUNT(*) AS total_cars_sold
FROM car_sales;

-- Total sales revenue
SELECT SUM(Price) AS total_sales_revenue
FROM car_sales;

-- Average selling price
SELECT AVG(Price) AS average_selling_price
FROM car_sales;

-- Revenue by company
SELECT Company,
       SUM(Price) AS revenue
FROM car_sales
GROUP BY Company
ORDER BY revenue DESC;

-- Cars sold by body style
SELECT Body_Style,
       COUNT(*) AS cars_sold
FROM car_sales
GROUP BY Body_Style
ORDER BY cars_sold DESC;

-- Sales by transmission
SELECT Transmission,
       COUNT(*) AS total_sales
FROM car_sales
GROUP BY Transmission;

-- Top dealer regions by revenue
SELECT Dealer_Region,
       SUM(Price) AS revenue
FROM car_sales
GROUP BY Dealer_Region
ORDER BY revenue DESC;

-- Sales by gender
SELECT Gender,
       COUNT(*) AS total_sales
FROM car_sales
GROUP BY Gender;

-- Top 5 companies by revenue
SELECT Company,
       SUM(Price) AS revenue
FROM car_sales
GROUP BY Company
ORDER BY revenue DESC
LIMIT 5;
