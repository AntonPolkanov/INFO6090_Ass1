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