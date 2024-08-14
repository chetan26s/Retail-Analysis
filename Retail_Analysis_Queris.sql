-- 1. Write a query to identify the number of duplicates in "sales_transaction" table. 
-- Also, create a separate table containing the unique values and remove the the original table from the databases and replace the name of the new table with the original name.

select transactionID , count(*) from Sales_transaction
group by transactionID
having count(*)>1;

create table sales_transaction1 as
select distinct * from sales_transaction;

drop table Sales_transaction;

alter table sales_transaction1 rename to sales_transaction;

select * from sales_transaction;

-- 2. Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
-- Also, update those discrepancies to match the price in both the tables.

select s.transactionId,s.price as transaction_price,p.price as inventory_price
from sales_transaction s
left join product_inventory p 
on s.productid=p.productid
where s.price != p.price;

update sales_transaction s
set price = (select p.price from product_inventory p where s.productid = p.productid)
where s.productid in (select p.productid from product_inventory p where s.price!=p.price);

 select * from sales_transaction;
 
 -- 3.Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.
 
select count(*) from customer_profiles
where  location is null;

update customer_profiles
set location = 'Unknown'
where location is null;

select * from customer_profiles;

-- 4.Write a SQL query to summarize the total sales and quantities sold per product by the company.

select productID, sum(QuantityPurchased) as TotalUnitsSold,sum(Price*QuantityPurchased) as TotalSales
from sales_transaction
group by productID
order by TotalSales desc;

-- 5.Write a SQL query to count the number of transactions per customer to understand purchase frequency.

select CustomerID, count(TransactionID) as NumberofTransactions from sales_transaction
group by 1
order by 2 desc;

-- 6.Write a SQL query to evaluate the performance of the product categories based on the total sales 
-- which help us understand the product categories which needs to be promoted in the marketing campaigns.

select p.category, sum(QuantityPurchased) as TotalUnitsSold,sum(s.price*QuantityPurchased) as TotalSales from sales_transaction s 
join product_inventory p
on s.productID = p.productID
group by p.category
order by TotalSales desc;

-- 7. Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
-- This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

select ProductID, sum(Price * QuantityPurchased) as TotalRevenue from Sales_transaction
group by productID
order by TotalRevenue desc limit 10;

-- 8.Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, provided that at least one unit was sold for those products.

select ProductID, sum(QuantityPurchased) as TotalUnitsSold from sales_transaction
group by ProductID
having TotalUnitsSold>=1
order by TotalUnitsSold asc limit 10;

-- 9.Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.

with cte as (select month(transactionDate) as month,sum(price*QuantityPurchased)  as Total_sales ,  lag(sum(price*QuantityPurchased)) 
over (order by month(transactionDate)) as previous_month_sales from sales_transaction
group by month)
select *, ((Total_sales - previous_month_sales)/previous_month_sales) * 100 as mom_growth_percentage from cte;

-- 10. Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
-- which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.

select customerID, count(TransactionID) as NumberofTransactions, sum(Price*QuantityPurchased) as TotalSpent 
from sales_transaction
group by customerID
having count(TransactionID)>10 and TotalSpent > 1000
order by TotalSpent desc ;

-- 11. Write a SQL query that describes the number of transaction along with the total amount spent by each customer,
-- which will help us understand the customers who are occasional customers or have low purchase frequency in the company.

select CustomerID,count(transactionID) as NumberofTransactions , sum(price*QuantityPurchased) as TotalSpent from sales_transaction
group by CustomerID
having NumberofTransactions <= 2 
order by NumberofTransactions , TotalSpent desc;

-- 12. Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.

select CustomerID, ProductID, count(TransactionID) as TimesPurchased from sales_transaction
group by CustomerID,productID
having TimesPurchased>1
order by 3 desc;

-- 13. Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.

select CustomerID, min(TransactionDate) as FirstPurchase , max(TransactionDate) as LastPurchase,
Datediff(max(TransactionDate),min(TransactionDate)) as DaysBetweenPurchases from sales_transaction
group by CustomerID
having DaysBetweenPurchases > 0
order by DaysBetweenPurchases desc;

-- 14. Write a SQL query that segments customers based on the total quantity of products they have purchased. Also, 
-- count the number of customers in each segment which will help us target a particular segment for marketing.

with cte as (select st.customerID, sum(st.QuantityPurchased) as QP from sales_transaction st join customer_profiles cp
on st.customerID = cp.customerID
group by customerID
),

cte1 as(
select customerID,
case when QP > 30 then 'High'
         when QP between 10 and 30 then 'Med'
        when QP < 10 then 'Low'
        else 'Other'
        end as CustomerSegment
from cte )

select CustomerSegment, count(*) from cte1
group by CustomerSegment;
