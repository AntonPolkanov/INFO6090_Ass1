/*************************************************
 *				Assignment 1		             *
 *				Team: 7							 *
 *				Date: 20/09/2021				 *
 *************************************************/

USE Assignment1_v2
GO

-- Delete null data 
DELETE FROM SalesData WHERE "Customer ID" IS NULL;


--Remove duplicate rows
WITH CTE AS(
   SELECT "Sale Date", "Reciept Id", "Customer ID", "Customer First Name", "Customer Surname", "Staff ID", "Staff First Name", "Staff Surname", "Staff office", "Office Location", "Reciept Transaction Row ID", "Item ID", "Item Description", "Item Quantity", "Item Price", "Row Total",
       RN = ROW_NUMBER()OVER(PARTITION BY "Sale Date", "Reciept Id", "Customer ID", "Customer First Name", "Customer Surname", "Staff ID", "Staff First Name", "Staff Surname", "Staff office", "Office Location", "Reciept Transaction Row ID", "Item ID", "Item Description", "Item Quantity", "Item Price", "Row Total" ORDER BY "Sale Date")
   FROM SalesData
)
DELETE FROM CTE WHERE RN > 1


-- Create Customer Dimension
Insert into DimCustomer
(CustomerID, Customer_First_Name, Customer_Surname)
SELECT DISTINCT "Customer ID", "Customer First Name", "Customer Surname" From SalesData ORDER BY "Customer ID";

Select * From DimCustomer;


-- Create Staff Dimension
Insert into DimStaff
 (Staff_ID, Staff_First_Name, Staff_Surname, Location_ID, Location_Name)
SELECT distinct "Staff ID", "Staff First Name", "Staff Surname", "Staff office", "Office Location"
FROM SalesData ORDER BY "Staff ID"

Select * FROM DimStaff


INSERT INTO DimDate 
(Date_date, Date_day, Date_Month, Date_Quarter, Date_Year)
SELECT distinct SalesData.[Sale Date], Datepart(day, SalesData.[Sale Date]), Datepart(month, SalesData.[Sale Date]), Datepart(quarter, SalesData.[Sale Date]), Datepart(year, SalesData.[Sale Date]) 
FROM SalesData ORDER BY "Sale Date";

Select * From DimDate;


INSERT INTO DimItem 
(Item_ID, Item_Description, Item_Unit_Price)
SELECT distinct SalesData.[Item ID], SalesData.[Item Description], SalesData.[Item Price]
FROM SalesData WHERE "Item Description" is not NULL ORDER BY "Item ID";

SELECT * FROM DimItem;

--Now Populate the Fact Table
Insert into FactSales
(Date_Key, Customer_Key, Staff_Key, Item_Key, Receipt_ID, Receipt_Transaction_Row_ID, Item_Quantity, Row_Total)
SELECT  DISTINCT DimDate.[Date_Key], 
DimCustomer.[Customer_Key], 
DimStaff.[Staff_Key], 
DimItem.[Item_Key], 
SalesData.[Reciept Id],
SalesData.[Reciept Transaction Row ID],
SalesData.[Item Quantity],
SalesData.[Row Total]
FROM SalesData 
	left join DimCustomer
		on SalesData.[Customer ID]=DimCustomer.CustomerID 
	left Join DimDate
		on SalesData.[Sale Date]=DimDate.Date_date
	left join DimItem
		on SalesData.[Item ID]=DimItem.Item_ID
	Left join DimStaff
		on SalesData.[Staff ID]=DimStaff.Staff_ID
ORDER BY "Reciept Id"


SELECT * FROM FactSales;


