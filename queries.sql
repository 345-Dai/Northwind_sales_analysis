--------------------------------------------(( SQL_Project ))--------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--§ Customer Segmentation based on :
--§ 1. RFM ( Recency , Frequency , Monetary ) Analysis:
-- Step 1: Calculate RFM metrics for each customer :
WITH RFM AS (
    SELECT 
        C.CustomerID,
        round(JULIANDAY('now') - JULIANDAY(MAX(O.OrderDate)),0) AS Recency,
        count(DISTINCT(O.OrderID)) AS Frequency,
        SUM(OD.UnitPrice * OD.Quantity*(1-OD.discount)) AS Monetary
    FROM Customers C
    inner JOIN Orders O ON C.CustomerID = O.CustomerID
    inner JOIN 'Order Details' OD ON O.OrderID = OD.OrderID
    GROUP BY C.CustomerID
) ,
--Segment Customers to Champions , Potential Loyalist and At risk based on RFM metrics :
Customers_Segmentation AS (
    SELECT 
        customerid
       ,Recency
       ,Frequency
       ,Monetary
       ,CASE
            WHEN Recency <= 490 AND Frequency >= 190 AND Monetary >= 5500000 then 'Champion'
            WHEN Frequency >= 164  or Monetary >= 4500000 then 'Potential Loyalist'
            ELSE 'At Risk'
        END AS Segment
    FROM 
        RFM )
--Define Customers distribution based on their categories.
SELECT *
From Customers_Segmentation 
GROUP by 1
having segment = 'Champion'

---------------------------------------------------------------------------------------------------------------
--§ 2. Average Order Value :
WITH AvgOrderValue as (
select 
  O.CustomerID 
, avg(OD.UnitPrice * OD.Quantity*(1-OD.discount)) AS AVG_Revenue
from Orders O  left join 'Order Details' OD on O.OrderID = OD.OrderID
group by 1
order by 2 desc ) ,
AvgRevenue_Segmentation as (
  SELECT
    CustomerID
  , Case 
  when AVG_Revenue >= 740 then 'High-Value'
  when AVG_Revenue >= 725 then 'Medium-Value'
  else 'Low-Value'
  end as 'AverageRevenue'
  from AvgOrderValue )
  
  select AverageRevenue , count(customerid) N_Customers 
  from AvgRevenue_Segmentation
  group by 1
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Product Analysis:
§ Identify products with:
§ High Revenue Value: Identify the top 10 revenue generator products.*/
SELECT
    P.ProductName
    , sum(OD.unitprice* OD.quantity*(1-OD.discount)) REVENUE
from Products P left join 'Order Details' OD
on P.ProductID = OD.ProductID
GROUP by 1
order by 2 desc 
LIMIT 10
---------------------------------------------------------------------------------------------------------------
/*§ High Sales Volume: Determine the top 10 most frequently ordered products.*/
SELECT
    P.ProductName
    , COUNT(orderid) Num_Orders
from Products P left join 'Order Details' OD
on P.ProductID = OD.ProductID
GROUP by 1
order by 2 desc
limit 10
---------------------------------------------------------------------------------------------------------------
/*§ Slow Movers: Identify products with low sales volume(5 product)*/
SELECT
    P.ProductName
    , COUNT(OD.orderid) Num_Orders
from Products P left join 'Order Details' OD
on P.ProductID = OD.ProductID
GROUP by 1
order by 2 asc 
limit 5

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--Order Analysis :
/*
§ Seasonality: Identify any seasonal fluctuations in order volume.*/
select 
    case 
        when 0 + strftime('%m', O.OrderDate) between  1 and  3 then 'Q1'
        when 0 + strftime('%m', O.OrderDate) between  4 and  6 then 'Q2'
        when 0 + strftime('%m', O.OrderDate) between  7 and  9 then 'Q3'
        when 0 + strftime('%m', O.OrderDate) between 10 and 12 then 'Q4'
    end as quarter
    , Count (O.OrderID) No_Orders 
from Orders O
group by 1
---------------------------------------------------------------------------------------------------------------
/*§ Day-of-the-Week Analysis: Determine the most popular order days.*/
select 
    strftime('%w',O.OrderDate) Day
    , Count (O.OrderID) No_Orders 
from Orders O
group by 1
--from 0 : sunday to 6 : saturday
---------------------------------------------------------------------------------------------------------------
/*§ Order Size Analysis: Analyze the distribution of order quantities.
*/
select  
    case 
         when quantity between 1 and 5 then '1-5'
         when quantity between 6 and 10 then '5-10'
         WHEN quantity between 11 and 15 then '10-15'
         when quantity between 16 and 20 then '15-20'
         when quantity between 21 and 25 then '20-25'
         when quantity between 26 and 30 then '25-30'
         when quantity between 31 and 35 then '30-35'
         when quantity between 36 and 40 then '35-40'
         when quantity between 41 and 45 then '40-45'
         when quantity between 46 and 50 then '45-50'
         when quantity between 51 and 55 then '50-55'
         when quantity between 56 and 60 then '55-60'
         when quantity between 61 and 65 then '60-65'
         when quantity between 66 and 70 then '65-70'
         when quantity > 70 then '>70'
         else 'nulll'
     end as 'QuantityRange'
    , Count (DISTINCT(OrderID)) Orders
from 'Order Details' 
group by 1
order by 1 


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/*Employee Performance:
§ Evaluate employee performance based on:*/
--§ Total sales volume generated:
select 
    CONCAT(E.firstname,' ',E.lastname) Employee
  , sum(OD.unitprice* OD.quantity*(1-OD.discount)) REVENUE
from Employees E inner join Orders O
on E.EmployeeID = O.EmployeeID
INNER join 'Order Details' OD 
ON O.OrderID = OD.OrderID
group by 1 
order by 2 desc
---------------------------------------------------------------------------------------------------------------
--§ Number of orders processed:
select 
    CONCAT(E.firstname,' ',E.lastname) Employee
  , Count (O.OrderID) No_Orders 
from Employees E inner join Orders O
on E.EmployeeID = O.EmployeeID
group by 1 
order by 2 desc
---------------------------------------------------------------------------------------------------------------
--§ Average order value :
select 
    CONCAT(E.firstname,' ',E.lastname) Employee
  , avg(OD.unitprice* OD.quantity*(1-OD.discount)) AvgOrderValue
from Employees E inner join Orders O
on E.EmployeeID = O.EmployeeID
INNER join 'Order Details' OD 
ON O.OrderID = OD.OrderID
group by 1 
order by 2 desc
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--Needed Steps:
--Total Number of customers
select count (customerid) '#Customers' 
from customers


---------------------------------------------------------------------------------------------------------------
--Recency :
SELECT 
   C.CustomerID,
   round(JULIANDAY('now') - JULIANDAY(MAX(O.OrderDate)),0) AS Recency
from Customers C inner join Orders O ON C.CustomerID = O.CustomerID
inner JOIN 'Order Details' OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID
order by 2 
limit 1 --min431
    
 
SELECT 
   C.CustomerID,
   round(JULIANDAY('now') - JULIANDAY(MAX(O.OrderDate)),0) AS Recency
from Customers C inner join Orders O ON C.CustomerID = O.CustomerID
inner JOIN 'Order Details' OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID
order by 2 desc
limit 1  --max:600


---------------------------------------------------------------------------------------------------------------
--Frequency:
select customerid, count(orderid) '#Orders' 
from Orders
group by 1
order by 2 
limit 1 --Min:154


---------------------------------------------------------------------------------------------------------------
--Monetary:
SELECT 
   C.CustomerID,
   SUM(OD.UnitPrice * OD.Quantity*(1-OD.discount)) AS Monetary
from Customers C inner join Orders O ON C.CustomerID = O.CustomerID
inner JOIN 'Order Details' OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID
order by 2 
limit 1 --min:3965464.95


SELECT 
   C.CustomerID,
   SUM(OD.UnitPrice * OD.Quantity*(1-OD.discount)) AS Monetary
from Customers C inner join Orders O ON C.CustomerID = O.CustomerID
inner JOIN 'Order Details' OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID
order by 2 DESC
limit 1 --MAX:6154115.34
---------------------------------------------------------------------------------------------------------------
