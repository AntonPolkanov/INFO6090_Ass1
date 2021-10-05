/*************************************************
 *				Assignment 1		             *
 *				Team: 7							 *
 *				Date: 20/09/2021				 *
 *************************************************/

USE Assignment1_v2
GO

-- Delete the last empty row added by the Import Data task
DELETE FROM SalesData WHERE "Customer ID" IS NULL;

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
BEGIN
	DROP TABLE #tmp
END
GO

SELECT 
		"Sale Date" AS Sale_Date, 
		"Reciept Id" AS Receipt_ID,
		"Customer ID" AS Customer_ID,
		"Customer First Name" AS Customer_First_Name,
		"Customer Surname" AS Customer_Surname,
		"Staff ID" AS Staff_ID,
		"Staff First Name" AS Staff_First_Name,
		"Staff Surname" AS Staff_Surname,
		"Staff office" AS Staff_Office,
		"Office Location" AS Office_Location,
		"Reciept Transaction Row ID" AS Receipt_Transaction_Row_ID,
		"Item ID" AS Item_ID,
		"Item Description" AS Item_Description,
		"Item Quantity" AS Item_Quantity,
		"Item Price" AS Item_Price,
		"Row Total" AS Row_Total,
    RN = ROW_NUMBER() OVER(PARTITION BY 
				"Sale Date",
				"Reciept Id",
				"Customer ID",
				"Customer First Name",
				"Customer Surname",
				"Staff ID",
				"Staff First Name",
				"Staff Surname",
				"Staff office",
				"Office Location",
				"Reciept Transaction Row ID",
				"Item ID",
				"Item Description",
				"Item Quantity",
				"Item Price",
				"Row Total"
				ORDER BY "Sale Date")
INTO #tmp
FROM SalesData

-- Remove duplicate rows
DELETE FROM #tmp WHERE RN > 1

-- Create Customer Dimension
INSERT INTO DimCustomer
(Customer_ID, Customer_First_Name, Customer_Surname)
SELECT DISTINCT Customer_ID, Customer_First_Name, Customer_Surname FROM #tmp ORDER BY Customer_ID;


-- Create Staff Dimension
INSERT INTO DimStaff
 (Staff_ID, Staff_First_Name, Staff_Surname, Location_ID, Location_Name)
SELECT DISTINCT Staff_ID, Staff_First_Name, Staff_Surname, Staff_office, Office_Location
FROM #tmp ORDER BY Staff_ID


INSERT INTO DimDate 
(Sale_Date, Day, Month, Quarter, Year)
SELECT DISTINCT Sale_Date, DAY(Sale_Date), MONTH(Sale_Date), DATEPART(quarter, Sale_Date), YEAR(Sale_Date) 
FROM #tmp ORDER BY Sale_Date;


INSERT INTO DimItem 
(Item_ID, Item_Description, Item_Unit_Price)
SELECT DISTINCT Item_ID, Item_Description, Item_Price
FROM #tmp WHERE Item_Description IS NOT NULL ORDER BY Item_ID;


--Now Populate the Fact Table
INSERT INTO FactSales
(Dim_Date_ID, Dim_Customer_ID, Dim_Staff_ID, Dim_Item_ID, Receipt_ID, Receipt_Transaction_Row_ID, Item_Quantity, Row_Total)
SELECT  DISTINCT DimDate.[ID] AS Dim_Date_ID, 
DimCustomer.[ID] AS Dim_Customer_ID, 
DimStaff.[ID] AS Dim_Staff_ID, 
DimItem.[ID] AS Dim_Item_ID, 
#tmp.[Receipt_ID],
#tmp.[Receipt_Transaction_Row_ID],
#tmp.[Item_Quantity],
#tmp.[Row_Total]
FROM #tmp 
	JOIN DimCustomer
		ON #tmp.[Customer_ID]=DimCustomer.Customer_ID
	JOIN DimDate
		ON #tmp.[Sale_Date]=DimDate.Sale_Date
	JOIN DimItem
		ON #tmp.[Item_ID]=DimItem.Item_ID
	JOIN DimStaff
		ON #tmp.[Staff_ID]=DimStaff.Staff_ID
ORDER BY Receipt_ID


SELECT * FROM FactSales;


