create database retaildata;
use retaildata;
SELECT*FROM `OnlineRetail_Cleaned_Final 1(in)`;

-- Q1. Find the total number of records, distinct invoices, distinct products, and distinct customers in the dataset.
SELECT 
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT `Invoice No`) AS Distinct_Invoices,
    COUNT(DISTINCT `StockCode`) AS Distinct_Products,
    COUNT(DISTINCT `CustomerID`) AS Distinct_Customers
FROM `OnlineRetail_Cleaned_Final 1(in)`;




-- Q2. Find the number of missing values in each important column, especially CustomerID, Description, Quantity, UnitPrice, and InvoiceDate.
SELECT 
    SUM(CASE WHEN `Invoice No` IS NULL THEN 1 ELSE 0 END) AS Missing_InvoiceNo,
    SUM(CASE WHEN `StockCode` IS NULL THEN 1 ELSE 0 END) AS Missing_StockCode,
    SUM(CASE WHEN `Description` IS NULL THEN 1 ELSE 0 END) AS Missing_Description,
    SUM(CASE WHEN `Quantity` IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity,
    SUM(CASE WHEN `UnitPrice` IS NULL THEN 1 ELSE 0 END) AS Missing_UnitPrice,
    SUM(CASE WHEN `Invoice Date` IS NULL THEN 1 ELSE 0 END) AS Missing_InvoiceDate,
    SUM(CASE WHEN `CustomerID` IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerID
FROM `OnlineRetail_Cleaned_Final 1(in)`;




-- Q3. Find the number of cancelled invoices, records with negative quantities, records with zero or negative unit prices, and duplicate rows.
SELECT 
    SUM(CASE WHEN `Invoice No` LIKE 'C%' THEN 1 ELSE 0 END) AS Cancelled_Invoices_Count,
    SUM(CASE WHEN `Quantity` < 0 THEN 1 ELSE 0 END) AS Negative_Quantity_Records,
    SUM(CASE WHEN `UnitPrice` <= 0 THEN 1 ELSE 0 END) AS Zero_Or_Negative_Price_Records
FROM `OnlineRetail_Cleaned_Final 1(in)`;



-- Q4. Calculate the total revenue, total quantity sold, and total number of unique invoices.
SELECT 
    SUM(Quantity * UnitPrice) AS Total_Revenue,
    SUM(Quantity) AS Total_Quantity_Sold,
    COUNT(DISTINCT `Invoice No`) AS Total_Unique_Invoices
FROM `OnlineRetail_Cleaned_Final 1(in)`;



-- Q5. Find the top 10 products by total revenue.
SELECT 
    StockCode, 
    Description, 
    SUM(Quantity * UnitPrice) AS Total_Revenue
FROM `OnlineRetail_Cleaned_Final 1(in)`
GROUP BY StockCode, Description
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Q6. Find the top 10 products by total quantity sold.
SELECT 
    StockCode, 
    Description, 
    SUM(Quantity) AS Total_Quantity_Sold
FROM `OnlineRetail_Cleaned_Final 1(in)`
WHERE Quantity > 0
GROUP BY StockCode, Description
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;



-- Q7. Calculate monthly revenue and identify the month with the highest revenue.
SELECT 
    DATE_FORMAT(STR_TO_DATE(`Invoice Date`, '%d/%m/%Y %h:%i %p'), '%Y-%m') AS Month_Year,
    SUM(Quantity * UnitPrice) AS Monthly_Revenue
FROM `OnlineRetail_Cleaned_Final 1(in)`
GROUP BY Month_Year
ORDER BY Monthly_Revenue DESC;



-- Q8. Calculate average order value (AOV) and find the top 10 invoices by order value.
WITH InvoiceTotals AS (
    SELECT 
        `Invoice No`,
        SUM(Quantity * UnitPrice) AS Order_Value
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    GROUP BY `Invoice No`
)
SELECT 
    (SELECT AVG(Order_Value) FROM InvoiceTotals) AS Average_Order_Value,
    `Invoice No`,
    Order_Value
FROM InvoiceTotals
ORDER BY Order_Value DESC
LIMIT 10;

-- Q9. Find the top 10 customers by total spending.
SELECT 
    CustomerID, 
    SUM(Quantity * UnitPrice) AS Total_Spending
FROM `OnlineRetail_Cleaned_Final 1(in)`
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY Total_Spending DESC
LIMIT 10;


-- Q10. Calculate the total revenue and number of orders for each customer.
SELECT 
    CustomerID, 
    SUM(Quantity * UnitPrice) AS Total_Revenue,
    COUNT(DISTINCT `Invoice No`) AS Total_Orders
FROM `OnlineRetail_Cleaned_Final 1(in)`
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;



-- Q11. Identify repeat customers — customers who placed more than one order.
SELECT 
    CustomerID,
    COUNT(DISTINCT `Invoice No`) AS Order_Count
FROM `OnlineRetail_Cleaned_Final 1(in)`
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(DISTINCT `Invoice No`) > 1
ORDER BY Order_Count DESC;



-- Q12. Segment customers into High, Medium, and Low spenders using their total spending, and calculate the number of customers in each segment.
WITH CustomerSpend AS (
    SELECT 
        CustomerID,
        SUM(Quantity * UnitPrice) AS Total_Spend
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
CustomerSegments AS (
    SELECT 
        CustomerID,
        Total_Spend,
        CASE 
            WHEN Total_Spend >= 5000 THEN 'High Spender'
            WHEN Total_Spend >= 1000 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS Spend_Segment
    FROM CustomerSpend
)
SELECT 
    Spend_Segment,
    COUNT(CustomerID) AS Customer_Count
FROM CustomerSegments
GROUP BY Spend_Segment
ORDER BY Customer_Count DESC;




-- Q13. Calculate total revenue and number of orders for each country.
SELECT 
    Country,
    SUM(Quantity * UnitPrice) AS Total_Revenue,
    COUNT(DISTINCT `Invoice No`) AS Total_Orders
FROM `OnlineRetail_Cleaned_Final 1(in)`
GROUP BY Country
ORDER BY Total_Revenue DESC;


-- Q14. Find the top 10 countries by revenue, excluding the United Kingdom.
SELECT 
    Country,
    SUM(Quantity * UnitPrice) AS Total_Revenue
FROM `OnlineRetail_Cleaned_Final 1(in)`
WHERE Country != 'United Kingdom'
GROUP BY Country
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Q15. Calculate the average order value for each country and identify the country with the highest average order value.
WITH CountryOrderTotals AS (
    SELECT 
        Country,
        `Invoice No`,
        SUM(Quantity * UnitPrice) AS Order_Value
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    GROUP BY Country, `Invoice No`
)
SELECT 
    Country,
    AVG(Order_Value) AS Avg_Order_Value
FROM CountryOrderTotals
GROUP BY Country
ORDER BY Avg_Order_Value DESC;

-- Q16. Use a CTE to calculate monthly revenue and compare each month’s revenue with the previous month using LAG().
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(`Invoice Date`, '%d/%m/%Y %h:%i %p'), '%Y-%m') AS Month_Year,
        SUM(Quantity * UnitPrice) AS Current_Month_Revenue
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    GROUP BY Month_Year
)
SELECT 
    Month_Year,
    Current_Month_Revenue,
    LAG(Current_Month_Revenue, 1) OVER (ORDER BY Month_Year ASC) AS Previous_Month_Revenue,
    (Current_Month_Revenue - LAG(Current_Month_Revenue, 1) OVER (ORDER BY Month_Year ASC)) AS Revenue_Difference
FROM MonthlyRevenue;



-- Q17. Rank products by revenue within each country using a window function such as RANK().
WITH ProductCountryRevenue AS (
    SELECT 
        Country,
        StockCode,
        Description,
        SUM(Quantity * UnitPrice) AS Product_Revenue
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    GROUP BY Country, StockCode, Description
),
RankedProducts AS (
    SELECT 
        Country,
        StockCode,
        Description,
        Product_Revenue,
        RANK() OVER (PARTITION BY Country ORDER BY Product_Revenue DESC) AS Revenue_Rank
    FROM ProductCountryRevenue
)
SELECT * 
FROM RankedProducts
WHERE Revenue_Rank <= 3;



-- Q18. Calculate cumulative monthly revenue using a window function with SUM() OVER().
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(`Invoice Date`, '%d/%m/%Y %h:%i %p'), '%Y-%m') AS Month_Year,
        SUM(Quantity * UnitPrice) AS Monthly_Revenue
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    GROUP BY Month_Year
)
SELECT 
    Month_Year,
    Monthly_Revenue,
    SUM(Monthly_Revenue) OVER (ORDER BY Month_Year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Revenue
FROM MonthlyRevenue;




-- Q19. Compare total revenue calculated from the original cleaned dataset with the revenue calculated using SQL. Investigate any mismatch.
SELECT 
    SUM(Quantity * UnitPrice) AS SQL_Total_Revenue
FROM `OnlineRetail_Cleaned_Final 1(in)`;


-- Q20. Write a final SQL summary query showing the key business KPIs: total revenue, total orders, unique customers, total quantity sold, and average order value.
WITH InvoiceTotals AS (
    SELECT 
        `Invoice No`,
        SUM(Quantity * UnitPrice) AS Order_Value
    FROM `OnlineRetail_Cleaned_Final 1(in)`
    GROUP BY `Invoice No`
)
SELECT 
    SUM(t.Order_Value) AS Total_Revenue,
    COUNT(DISTINCT t.`Invoice No`) AS Total_Orders,
    (SELECT COUNT(DISTINCT CustomerID) FROM `OnlineRetail_Cleaned_Final 1(in)` WHERE CustomerID IS NOT NULL) AS Unique_Customers,
    (SELECT SUM(Quantity) FROM `OnlineRetail_Cleaned_Final 1(in)`) AS Total_Quantity_Sold,
    AVG(t.Order_Value) AS Average_Order_Value
FROM InvoiceTotals t;


DESCRIBE `OnlineRetail_Cleaned_Final 1(in)`;

-- Alternatively, you can use:
SHOW COLUMNS FROM `OnlineRetail_Cleaned_Final 1(in)`;