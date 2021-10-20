;WITH 
	Orders AS (
		SELECT [Dim_Date_ID]
			,[Receipt_Id]
			,[Dim_Customer_ID]
			,[Dim_Staff_ID]
			,[Dim_Item_ID]
			,[Receipt_Transaction_Row_ID]
			,[Item_Quantity]
			,[Row_Total]
			,SUM(Row_Total) OVER (PARTITION BY Dim_Date_ID, Receipt_Id, Dim_Customer_ID ORDER BY Receipt_Transaction_Row_ID) AS Receipt_Running_Total
			,COUNT(Receipt_Id) OVER (PARTITION BY Dim_Date_ID, Receipt_Id, Dim_Customer_ID) AS Number_Of_Order_Items
			,SUM(Item_Quantity) OVER (PARTITION BY Dim_Date_ID, Receipt_Id, Dim_Customer_ID) AS Order_Item_Quantity
		FROM [dbo].[FactSales]
	)
	,AggregatedOrders AS (
		SELECT [Dim_Date_ID]
			,[Receipt_Id]
			,[Dim_Customer_ID]
			,[Dim_Staff_ID]
			,MAX(Order_Item_Quantity) AS Order_Item_Quantity
			,MAX(Number_Of_Order_Items) AS Number_Of_Order_Items
			,MAX(Receipt_Running_Total) AS Order_Total
			,CASE
				WHEN MAX(Number_Of_Order_Items) > 5
					THEN 0.18 -- 18% discount
					ELSE 0	  -- no discount
				END
				AS Discount
		FROM Orders
		GROUP BY [Dim_Date_ID], [Receipt_Id], [Dim_Customer_ID], [Dim_Staff_ID]
	)
	,OrdersWithDiscounts AS (
		SELECT [Dim_Date_ID], [Dim_Staff_ID], [Order_Total], [Order_Item_Quantity], Order_Total * (1-Discount) AS Discounted_Order_Total
		FROM AggregatedOrders
	)


SELECT owd.[Dim_Staff_ID]
	,ds.[Staff_First_Name]
	,ds.[Staff_Surname]
	,SUM(owd.Discounted_Order_Total) AS Total_Staff_Sales
	--,COUNT(owd.Dim_Staff_ID) AS Orders_Handled
	--,SUM(owd.Order_Item_Quantity) AS Total_Items_Sold
FROM OrdersWithDiscounts owd
	JOIN DimStaff ds ON owd.[Dim_Staff_ID] = ds.ID
GROUP BY owd.[Dim_Staff_ID], ds.Staff_First_Name, ds.Staff_Surname
ORDER BY Total_Staff_Sales DESC
