

       DROP TABLE sales_store;

CREATE TABLE sales_store(
    transaction_id varchar(20),
    customer_id varchar(20),
    customer_name varchar(100), -- increased from 15 to 100
    customer_age INT,
    gender varchar(15),
    product_id varchar(20),
    product_name varchar(100),
    product_category varchar(50),
    quantiy INT,
    prce FLOAT,
    payment_mode varchar(20),
    purchase_date DATE,
    time_of_purchase TIME,
    status varchar(20)
);
 
 select * from sales_store

BULK INSERT sales_store
FROM 'C:\Users\Lenovo\Downloads\Sales Stores\sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

 -- YYY - MM - DD
 -- Data Cleaning 

 SELECT * FROM sales_store

 SELECT * INTO sales FROM sales_store


 SELECT * FROM sales_store
 SELECT * FROM sales

 -- Data Cleaning 

 -- Step 1 :- to check for Duplicate 

 SELECT transaction_id , COUNT(*)
 FROM sales
 GROUP BY transaction_id
 HAVING COUNT (transaction_id) > 1

 WITH CTE AS (
 SELECT *,
 ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id ) AS Row_Num From sales
 )
 SELECT * FROM CTE 
 WHERE Row_Num > 1


 WITH CTE AS (
 SELECT *,
          ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id ) AS Row_Num From sales
 )
 --DELETE FROM CTE 
 --WHERE  Row_Num = 2 

 SELECT * FROM CTE 
 WHERE transaction_id IN ( 'TXN240646', 'TXN342128', 'TXN855235', 'TXN981773')
 

 SELECT * FROM CTE WHERE transaction_id IN ( 'TXN240646', 'TXN342128', 'TXN855235', 'TXN981773')

 -- step 2 :- Correction of Headers 

 EXEC sp_rename 'sales.quantiy','quantity','COLUMN'
 EXEC sp_rename 'sales.prce','','COLUMN'

 -- Step 3 :- To check Datatype 

 SELECT COLUMN_NAME, DATA_TYPE
 FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME = 'sales'

 -- Step 4 :- To Check Null Values 

 -- to check null count

 DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, COUNT(*) AS NullCount 
     FROM ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + 
     ' WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
    ' UNION ALL '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales_store';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;


-- treating null values 

SELECT * FROM sales WHERE transaction_id is null 
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR 
gender IS NULL
 OR
product_id IS NULL
OR
product_name  IS NULL
OR
product_category IS NULL
OR
quantity IS NULL

OR
price IS NULL
OR
payment_mode IS NULL
OR
purchase_date IS NULL
OR
time_of_purchase IS NULL

DELETE FROM sales 
WHERE transaction_id IS NULL

SELECT * FROM sales 
WHERE customer_name ='Ehsaan Ram'

UPDATE sales 
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900'


SELECT * FROM sales 
WHERE customer_name ='Damini Raju'

UPDATE sales 
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'


SELECT * FROM sales 
WHERE customer_id ='CUST1003'

UPDATE sales 
SET customer_name = 'Mahika Saini', customer_age = 35, gender ='Male'
WHERE transaction_id = 'TXN432798'

SELECT * FROM sales

 -- Step 5 :- Data Cleaning   

SELECT DISTINCT gender
FROM sales

UPDATE sales 
SET gender = 'M'
WHERE gender = 'Male'
   
UPDATE sales 
SET gender = 'F'
WHERE gender = 'Female'

SELECT DISTINCT payment_mode
FROM sales
   
UPDATE sales 
SET payment_mode = 'Credit card'
WHERE payment_mode = 'CC'
    
   
-- Data Analysis--
-- 1. What are the top 5 most selling products by quantity ?

SELECT TOP 5  product_name , SUM(quantity ) AS total_quantity_sold 
FROM sales
WHERE status ='delivered'
GROUP BY product_name 
ORDER BY total_quantity_sold DESC

-- Business Problem : we don't know which products are most in demand.
-- Business Impact : Help prioritize stock and boost sales through targeted promotions.
-----------------------------------------------------------------------------------------------
-- 2. Which products are most frequently canceled?

SELECT TOP 5 product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status = 'cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC


-- Business Problem : Frequent cancellations affect revenue and customer trust.
--Business impact : Identify poor - performing products to improve quantity or remove from catalog.


----------------------------------------------------------------------------------------------------------------


-- 3. What time of the day has the highest number of purchases?

SELECT * FROM sales
       SELECT 
       CASE 
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
    END AS time_of_day,
    COUNT(*) AS total_orders
FROM sales
GROUP BY 
   CASE 
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
       WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
END 
ORDER BY total_orders DESC


-- Business Problem Solved : Find peak sales times.
-- Business Impact : Optimize staffing , promotions, and server loads.


------------------------------------------------------------------------------------------

-- 4. Who are the top 5 highest spending customers ?

SELECT * FROM sales

SELECT  TOP 5 customer_name ,
FORMAT(SUM(price * quantity),'C0','en-IN') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY total_spend DESC

SELECT  TOP 5 customer_name ,
FORMAT(SUM(price * quantity),'C0','en-IN') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(price * quantity) DESC

-- Business problem Solved: Identify VIP customers.
-- Business Impact : Personalized offers, loyalty rewards, and retention.


-----------------------------------------------------------------------------------------

-- 5. Which product categories generate the highest revenue?

SELECT * FROM sales

SELECT product_category,
FORMAT(SUM (price * quantity), 'C0','en-IN' )As Revenue 
FROM sales
GROUP BY product_category
ORDER BY SUM (price * quantity) DESC

-- Business Problem: Identify top - performing product categories.
--allowing the business to ivest more in high-margin or high-demand categories.

--------------------------------------------------------------------------------------------

-- 6. What is the return / cancellation rate per product category ?

SELECT * FROM sales 

-- cancellation

SELECT product_category,
    FORMAT (COUNT (CASE WHEN status = 'cancelled' THEN 1 END )*100.0/COUNT(*),'N3')+' %' AS cancelled_percent
    FROM sales
    GROUP BY product_category
    ORDER BY cancelled_percent DESC

 SELECT product_category,
    FORMAT (COUNT (CASE WHEN status = 'returned' THEN 1 END )*100.0/COUNT(*),'N3')+' %' AS returned_percent
    FROM sales
    GROUP BY product_category
    ORDER BY returned_percent DESC

-- Business Problem : Monitor dissatifaction trends per category.

--Business Impact : Reduce returns , improve product description / expectations.
--Helps identify and fix product or logistics issues.

--------------------------------------------------------------------------------------------------------------
-- 7. What is the most  preferred payment mode ?

SELECT * FROM sales

SELECT payment_mode,COUNT(payment_mode) AS total_count
FROM sales
GROUP BY payment_mode
ORDER BY total_count desc

-- Business Problem : Know which payment options customers prefer.
-- Business impact : Streamline payment processing , prioritize popular modes.

--------------------------------------------------------------------------------

-- 8. How does age group affect purchasing behavior ?

--- SELECT MIN(customer_age),MAX(customer_age) FROM sales

SELECT
     CASE 
         WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
         WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
         WHEN customer_age BETWEEN 18 AND 50 THEN '36-50'
         ELSE '51+'
    END AS customer_age,
   FORMAT( SUM(price*quantity),'C0','en-IN') AS total_purchase
FROM sales
GROUP BY  CASE 
         WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
         WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
         WHEN customer_age BETWEEN 18 AND 50 THEN '36-50'
         ELSE '51+'
    END
ORDER BY total_purchase DESC

-- Business Problem Solved : Understand customer demographics.
-- Business Impact : Targeted marketing and product recommendations by age group.

-------------------------------------------------------------------------------------------
-- 9 . What's the monthly sales trend ?

SELECT * FROM sales
--Method 1

SELECT 
  FORMAT(purchase_date,'yyyy-MM') AS Month_year,
  FORMAT (SUM(price * quantity ),'C0','en-IN')AS total_sales,
  SUM(quantity) AS total_quantity
FROM sales
GROUP BY FORMAT (purchase_date,'yyyy-MM')

-- Method 2 
SELECT * FROM sales
       
       SELECT 
         YEAR(purchase_date) AS Years,
         MONTH(purchase_date) AS Months,
          FORMAT (SUM(price * quantity ),'C0','en-IN')AS total_sales,
  SUM(quantity) AS total_quantity
  FROM sales
  GROUP BY  YEAR(purchase_date),MONTH(purchase_date) 
  ORDER BY Months
-----------------------------------------------------------
         SELECT 
         --YEAR(purchase_date) AS Years,
         MONTH(purchase_date) AS Months,
          FORMAT (SUM(price * quantity ),'C0','en-IN')AS total_sales,
  SUM(quantity) AS total_quantity
  FROM sales
  GROUP BY MONTH(purchase_date) 
  ORDER BY Months

  -- Business problem : Sales fluctuations go unnoticed.
  -- Buiness Impact : Plan inventory and marketing according to seasonal trends.

  ----------------------------------------------------------------------------------------

  -- 10 Are certain genders buying more specific product categories ?

--Method 1

  SELECT gender, product_category, COUNT(product_category) AS total_purchase
  FROM sales
  GROUP BY gender,product_category
  ORDER BY gender DESC

  -- Method 2

  SELECT *
  FROM(
     SELECT gender,product_category
     FROM sales
     ) AS source_table
PIVOT (
    COUNT(gender)
    FOR gender IN ( [M],[F])
    ) AS pivot_table
ORDER BY product_category

-- Business Problem : Gender - based product preferences.

-- Buiness impact : Personalized ads, gender-focused campaigns.













