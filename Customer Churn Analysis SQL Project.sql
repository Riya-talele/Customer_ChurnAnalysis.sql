create database Customer_Churn_Anakysis;

select * from ecommerce_churn;
-- 1.We Rename the Column 
ALTER TABLE ecommerce_churn
RENAME COLUMN `ï»¿CustomerID` TO CustomerID;

-- 2. Find the total number of customers
select  count(CustomerID) AS TotalNumberOfCustomers
from ecommerce_churn;
-- Answer = There are 4,293 customers in this dataset

-- 3. Check for duplicate rows
select CustomerID,count(CustomerID) as Count
from ecommerce_churn
group by CustomerID
having count(CustomerID) > 1;
-- Answer = There are no duplicate rows

-- 4. Check for null values count for columns with null values
SELECT COUNT(*) AS empty_count
FROM ecommerce_churn
WHERE Tenure = '';

-- TO FIND ALL
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE Tenure IS NULL or Tenure ='' 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE warehousetohome IS NULL or WarehouseToHome =''
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE hourspendonapp IS NULL or HourSpendOnApp =''
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE orderamounthikefromlastyear IS NULL or OrderAmountHikeFromlastYear =''
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE couponused IS NULL or CouponUsed =''
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE ordercount IS NULL or OrderCount =''
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce_churn
WHERE daysincelastorder IS NULL or DaySinceLastOrder ='';

-- in this queary we Find all count of Null and Black records from each column
-- Tenure	264, arehouseToHome	0,HourSpendonApp	255 , OrderAmountHikeFromLastYear	0
-- CouponUsed	850  , OrderCount	0 , DaySinceLastOrder	376

-- 4.1 Handle null values
-- We will fill null values with their mean. 
UPDATE ecommerce_churn
SET Hourspendonapp = (
    SELECT avg_val FROM (SELECT AVG(Hourspendonapp) AS avg_val FROM ecommerce_churn) t
)
WHERE Hourspendonapp IS NULL;

UPDATE ecommerce_churn
SET tenure = (
    SELECT avg_val FROM (SELECT (avg(tenure) AS avg_val FROM ecommerce_churn) t
)
WHERE tenure IS NULL or tenure='';

UPDATE ecommerce_churn
SET orderamounthikefromlastyear = (
    SELECT avg_val FROM (SELECT AVG(orderamounthikefromlastyear) AS avg_val FROM ecommerce_churn) t
)
WHERE orderamounthikefromlastyear IS NULL;

UPDATE ecommerce_churn
SET WarehouseToHome = (
    SELECT avg_val FROM (SELECT AVG(WarehouseToHome) AS avg_val FROM ecommerce_churn) t
)
WHERE WarehouseToHome IS NULL;

UPDATE ecommerce_churn
SET couponused = (
    SELECT avg_val FROM (SELECT AVG(couponused) AS avg_val FROM ecommerce_churn) t
)
WHERE couponused IS NULL;

UPDATE ecommerce_churn
SET ordercount = (
    SELECT avg_val FROM (SELECT AVG(ordercount) AS avg_val FROM ecommerce_churn) t
)
WHERE ordercount IS NULL;

select * from ecommerce_churn;

UPDATE ecommerce_churn
SET daysincelastorder = (
    SELECT avg_val FROM (SELECT AVG(daysincelastorder) AS avg_val FROM ecommerce_churn) t
)
WHERE daysincelastorder IS NULL;



-- 5. Create a new column based on the values of churn column.
-- The values in churn column are 0 and 1 values were O means stayed and 1 means churned.
 -- create a new column called customerstatus that shows 'Stayed' and 'Churned' instead of 0 and 1

alter table ecommerce_churn
add customerstatus nvarchar(50);

update ecommerce_churn
set customerstatus =
case  
when churn = 1 then 'Churned'
when churn = 0 then 'Stayed'
end ;
-- so to change column info we first change the datatype of column then we add nvarchar(50)
-- then we write queary which change 1 to churned and 0 to stayed then end of case


-- 6. Create a new column based on the values of complain column.
-- The values in complain column are 0 and 1 values were O means No and 1 means Yes. 
-- create a new column called complain_recieved that shows 'Yes' and 'No' instead of 0 and 1  
 Alter table ecommerce_churn
 add  complain_recieved nvarchar(10);

 Update ecommerce_churn
 set complain_recieved =
 case 
 when complain = 1 then 'Yes'
 when complain = 0 then 'No'
 end;
 
-- 7. Check values in each column for correctness and accuracy
 select * from ecommerce_churn;
 
 
-- 7.1 a) Check distinct values for preferredlogindevice column
select distinct preferredlogindevice 
from ecommerce_churn;

-- the result shows phone and mobile phone which indicates the same thing, so replace mobile phone with phone

-- 7.1 b) Replace mobile phone with phone
UPDATE ecommerce_churn
SET preferredlogindevice = 'Phone'
WHERE preferredlogindevice = 'mobile phone';

-- 7.2 a) Check distinct values for preferredpaymentmode column
select distinct PreferredPaymentMode 
from ecommerce_churn;
-- the result shows Cash on Delivery and COD which mean the same thing, 
-- so I replace COD with Cash on Delivery

-- 7.2 b) Replace mobile with mobile phone
update ecommerce_churn
SET PreferredPaymentMode  = 'COD'
WHERE PreferredPaymentMode  = 'Cash on Delivery';

-- 6.4 a) check distinct value in warehousetohome column
SELECT DISTINCT warehousetohome
FROM ecommercechurn;
-- I can see two values 126 and 127 that are outliers, it could be a data entry error, 
-- so I will  correct it to 26 & 27 respectively

-- 6.4 b) Replace value 127 with 27
UPDATE ecommerce_churn
SET warehousetohome = '27'
WHERE warehousetohome = '127';

-- 6.4 C) Replace value 126 with 26
UPDATE ecommerce_churn
SET warehousetohome = '26'
WHERE warehousetohome = '126';

            /**************************************************
           Data Exploration and Answering business questions
		   ***************************************************/
-- 1. What is the overall customer churn rate?
select Totalnumberofcustomers,
totalnumberofchurnedcustomers,
CAST((TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0)*100 AS DECIMAL(10,2)) as Churnrate
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM ecommerce_churn) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM ecommerce_churn
WHERE CustomerStatus = 'churned') AS Churned;
-- Answer = The Churn rate is 17.94%

-- 2. How does the churn rate vary based on the preferred login device?
select * from ecommerce_churn;
SELECT PreferredLoginDevice,
       COUNT(*) AS TotalCustomers,
       SUM(Churn) AS ChurnedCustomers,
       CAST(SUM(Churn) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommerce_churn
GROUP BY PreferredLoginDevice;
-- Answer = The prefered login devices are computer and phone. Computer accounts
--  for the highest churnrate with 20.66% and then phone with 16.79%. 

-- 3. What is the distribution of customers across different city tiers?
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommerce_churn
GROUP BY citytier
ORDER BY churnrate DESC;
-- Answer = citytier3 has the highest churn rate, 
-- followed by citytier2 and then citytier1 has the least churn rate.

-- 4. Is there any correlation between the warehouse-to-home distance and customer churn?
-- Firstly, we will create a new column that provides a distance range based on the values in warehousetohome column
ALTER TABLE ecommerce_churn
ADD warehousetohomerange NVARCHAR(50);

UPDATE ecommerce_churn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END;

-- Finding correlation between warehousetohome and churnrate
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC;
-- Answer = The churn rate increases as the warehousetohome distance increases



-- 5. Which is the most prefered payment mode among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC;
-- Answer = The most prefered payment mode among churned customers is Cash on Delivery



-- 6. What is the typical tenure for churned customers?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE ecommerce_churn
ADD TenureRange NVARCHAR(50);

UPDATE ecommerce_churn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END;

-- Finding typical tenure for churned customers
SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY TenureRange
ORDER BY Churnrate DESC;
-- Answer = Most customers churned within a 6 months tenure period

-- 7. Is there any difference in churn rate between male and female customers?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY gender
ORDER BY Churnrate DESC;
-- Answer = More men churned in comaprison to wowen 

-- 8. How does the average time spent on the app differ for churned and non-churned customers?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ecommerce_churn
GROUP BY customerstatus;
-- Answer = There is no difference between the average time spent on the app for churned and non-churned customers

-- 9. Which order category is most prefered among churned customers?
SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY preferedordercat
ORDER BY Churnrate DESC;
-- Answer = Mobile phone category has the highest churn rate and grocery has the least churn rate

-- 10. Is there any relationship between customer satisfaction scores and churn?
SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY satisfactionscore
ORDER BY Churnrate DESC;
-- Answer = Customer satisfaction score of 5 has the highest churn rate, 
-- satisfaction score of 1 has the least churn rate


-- 11. Does customer complaints influence churned behavior?
SELECT complain_recieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommerce_churn
GROUP BY complain_recieved
ORDER BY Churnrate DESC;
select * from ecommerce_churn;
-- Answer =Yes, Customers with complains had the highest churn rate

-- 12. How many addresses do churned customers have on average?
SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM ecommerce_churn
WHERE customerstatus = 'stayed'
-- Answer = On average, churned customers have 4 addresses




