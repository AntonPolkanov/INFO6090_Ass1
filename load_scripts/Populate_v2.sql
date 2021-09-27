/*************************************************
 *				Assignment 1		             *
 *				Team: 7							 *
 *				Date: 20/09/2021				 *
 *************************************************/

USE Assignment1_v2
GO

-- Delete null data 
DELETE FROM SalesData WHERE "Customer_ID" IS NULL;


--Remove duplicate rows
WITH CTE AS(
   SELECT "Sale_Date", "Reciept_Id", "Customer_ID", "Customer_First_Name", "Customer_Surname", "Staff_ID", "Staff_First_Name", "Staff_Surname", "Staff_office", "Office_Location", "Reciept_Transaction_Row_ID", "Item_ID", "Item_Description", "Item_Quantity", "Item_Price", "Row_Total",
       RN = ROW_NUMBER() OVER(PARTITION BY "Sale_Date", "Reciept_Id", "Customer_ID", "Customer_First_Name", "Customer_Surname", "Staff_ID", "Staff_First_Name", "Staff_Surname", "Staff_office", "Office_Location", "Reciept_Transaction_Row_ID", "Item_ID", "Item_Description", "Item_Quantity", "Item_Price", "Row_Total" ORDER BY "Sale_Date")
   FROM SalesData
)
DELETE FROM CTE WHERE RN > 1


-- Create Customer Dimension
Insert into DimCustomer
(Customer_ID, Customer_First_Name, Customer_Surname)
SELECT DISTINCT "Customer_ID", "Customer_First_Name", "Customer_Surname" From SalesData ORDER BY "Customer_ID";


-- Create Staff Dimension
Insert into DimStaff
 (Staff_ID, Staff_First_Name, Staff_Surname, Location_ID, Location_Name)
SELECT distinct "Staff_ID", "Staff_First_Name", "Staff_Surname", "Staff_office", "Office_Location"
FROM SalesData ORDER BY "Staff_ID"


INSERT INTO DimDate 
(Sale_Date, Day, Month, Quarter, Year)
SELECT distinct SalesData.[Sale_Date], DAY(SalesData.[Sale_Date]), MONTH(SalesData.[Sale_Date]), DATEPART(quarter, SalesData.[Sale_Date]), YEAR(SalesData.[Sale_Date]) 
FROM SalesData ORDER BY "Sale_Date";


INSERT INTO DimItem 
(Item_ID, Item_Description, Item_Unit_Price)
SELECT distinct SalesData.[Item_ID], SalesData.[Item_Description], SalesData.[Item_Price]
FROM SalesData WHERE "Item_Description" is not NULL ORDER BY "Item_ID";


--Now Populate the Fact Table
Insert into FactSales
(Sale_Date, Customer_ID, Staff_ID, Item_ID, Receipt_ID, Receipt_Transaction_Row_ID, Item_Quantity, Row_Total)
SELECT  DISTINCT DimDate.[Sale_Date], 
DimCustomer.[Customer_ID], 
DimStaff.[Staff_ID], 
DimItem.[Item_ID], 
SalesData.[Reciept_Id],
SalesData.[Reciept_Transaction_Row_ID],
SalesData.[Item_Quantity],
SalesData.[Row_Total]
FROM SalesData 
	left join DimCustomer
		on SalesData.[Customer_ID]=DimCustomer.Customer_ID 
	left Join DimDate
		on SalesData.[Sale_Date]=DimDate.Sale_Date
	left join DimItem
		on SalesData.[Item_ID]=DimItem.Item_ID
	Left join DimStaff
		on SalesData.[Staff_ID]=DimStaff.Staff_ID
ORDER BY "Reciept_Id"


SELECT * FROM FactSales;


