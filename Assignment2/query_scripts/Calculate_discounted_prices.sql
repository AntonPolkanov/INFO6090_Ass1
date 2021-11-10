;WITH 
	Orders AS (
		SELECT [Dim_Date_ID]
			,[Receipt_Id]
			,[Dim_Customer_ID]
			,[Dim_Staff_ID]
			,[Dim_Item_ID]
			,[Location_ID]
			,[Receipt_Transaction_Row_ID]
			,[Item_Quantity]
			,[Row_Total]
			,COUNT(Receipt_Id) OVER (PARTITION BY Dim_Date_ID, Receipt_Id, Dim_Customer_ID) AS Number_Of_Order_Items
		FROM [dbo].[FactSales]
	)
	,AggregatedOrders AS (
		SELECT [Dim_Date_ID]
			,[Receipt_Id]
			,[Dim_Customer_ID]
			,[Dim_Staff_ID]
			,[Dim_Item_ID]
			,[Receipt_Transaction_Row_ID]
			,[Location_ID]
			,[Item_Quantity]
			,[Row_Total]
			,MAX(Number_Of_Order_Items) AS Number_Of_Order_Items
			,CASE
				WHEN MAX(Number_Of_Order_Items) >= 5
					THEN 0.05 -- 5% discount
					ELSE 0	  -- no discount
				END
				AS Discount
		FROM Orders
		GROUP BY [Dim_Date_ID]
			,[Receipt_Id]
			,[Dim_Customer_ID]
			,[Dim_Staff_ID]
			,[Dim_Item_ID]
			,[Receipt_Transaction_Row_ID]
			,[Location_ID]
			,[Item_Quantity]
			,[Row_Total]
	)
	,OrdersWithDiscounts AS (
		SELECT *, Row_Total * (1-Discount) AS Discounted_Row_Total
		FROM AggregatedOrders
	)
	
	,[FactSalesWithDiscountedPrices] AS (
	SELECT DATEFROMPARTS(dd.Year, dd.Month, dd.Day) as [Date]
		,dc.Customer_First_Name + ' ' + dc.Customer_Surname as [Customer_Name]
		,ds.Staff_First_Name + ' ' + ds.Staff_Surname as [Staff_Name]
		,di.Item_Description as [Item_Description]
		,[Receipt_Id]
		,[Receipt_Transaction_Row_ID]
		,ds.[Location_Name] as [Location_Name]
		,[Item_Quantity]
		,[Row_Total]
		,[Discounted_Row_Total]
	FROM OrdersWithDiscounts owd 
		JOIN DimDate dd ON owd.Dim_Date_ID = dd.ID
		JOIN DimCustomer dc ON owd.Dim_Customer_ID = dc.ID
		JOIN DimStaff ds ON owd.Dim_Staff_ID = ds.ID
		JOIN DimItem di ON owd.Dim_Item_ID = di.ID
	)

-- 1. Transactions with the maximum and minimum number of items sold 
SELECT 
	Location_Name
	,MAX(Items_In_Order) as Max_Items_In_Order
	,MIN(Items_In_Order) as Min_Items_In_Order
FROM (
	SELECT SUM(Item_Quantity) as Items_In_Order, Location_Name
	FROM [FactSalesWithDiscountedPrices]
	GROUP BY Receipt_ID, Location_Name
) as tmp
GROUP BY Location_Name
ORDER BY Max_Items_In_Order DESC

-- 2. Average bucket size
--SELECT 
--	Location_Name
--	,AVG(Items_In_Order) as Avg_Items_In_Order
--FROM (
--	SELECT SUM(Item_Quantity) as Items_In_Order, Location_Name
--	FROM [FactSalesWithDiscountedPrices]
--	GROUP BY Receipt_ID, Location_Name
--) as tmp
--GROUP BY Location_Name
--ORDER BY Avg_Items_In_Order DESC

-- 3. Average ticket size
--SELECT 
--	Location_Name
--	,AVG(Sum_Of_Order) as Avg_Sum_Of_Order
--FROM (
--	SELECT SUM(Discounted_Row_Total) as Sum_Of_Order, Location_Name
--	FROM [FactSalesWithDiscountedPrices]
--	GROUP BY Receipt_ID, Location_Name
--) as tmp
--GROUP BY Location_Name
--ORDER BY Avg_Sum_Of_Order DESC

-- 4. Finds 3 best/worst performing items in each store by
-- printing sum of sold items for each store and item
--SELECT Location_Name, Item_Description, SUM(Item_Quantity) as Sum_Of_Items
--FROM [FactSalesWithDiscountedPrices]
--GROUP BY Location_Name, Item_Description
--ORDER BY Location_Name ASC, Sum_Of_Items DESC

-- 5. Number of unuque customers
--SELECT Location_Name, COUNT(*) AS Number_Of_Unique_Customers
--FROM (
--	SELECT Location_Name
--	FROM [FactSalesWithDiscountedPrices]
--	GROUP BY [Location_Name], Customer_Name
--	) as tmp
--GROUP BY Location_Name
--ORDER BY Number_Of_Unique_Customers DESC

-- 6. Number of orders
 --SELECT Location_Name, COUNT(*) as Number_Of_Orders
 --FROM (
 --	SELECT Location_Name
 --	FROM [FactSalesWithDiscountedPrices]
 --	GROUP BY [Location_Name], Receipt_ID
 --	) as tmp
 --GROUP BY [Location_Name]
 --ORDER BY Number_Of_Orders DESC

-- 7. Total revenue
 --SELECT Location_Name, SUM(Discounted_Row_Total) AS Total_Revenue
 --FROM [FactSalesWithDiscountedPrices]
 --GROUP BY Location_Name
 --ORDER BY Total_Revenue DESC

--8. Total items sold
--SELECT Location_Name, SUM(Item_Quantity) AS Total_Items_Sold
--FROM [FactSalesWithDiscountedPrices]
--GROUP BY Location_Name
--ORDER BY Total_Items_Sold DESC



