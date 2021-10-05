;WITH 
	Orders AS (
		SELECT [Sale_Date]
			,[Receipt_Id]
			,[Customer_ID]
			,[Staff_ID]
			,[Item_ID]
			,[Receipt_Transaction_Row_ID]
			,[Item_Quantity]
			,[Row_Total]
			,SUM(Row_Total) OVER (PARTITION BY Sale_Date, Receipt_Id, Customer_ID ORDER BY Receipt_Transaction_Row_ID) AS Receipt_Running_Total
			,COUNT(Receipt_Id) OVER (PARTITION BY Sale_Date, Receipt_Id, Customer_ID) AS Number_Of_Order_Items
			,SUM(Item_Quantity) OVER (PARTITION BY Sale_Date, Receipt_Id, Customer_ID) AS Order_Item_Quantity
		FROM [Sales].[dbo].[FactSale]
	)
	,AggregatedOrders AS (
		SELECT Sale_Date
			,Receipt_Id
			,Customer_ID
			,Staff_ID
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
		GROUP BY Sale_Date, Receipt_Id, Customer_ID, Staff_ID
	)
	,OrdersWithDiscounts AS (
		SELECT Sale_Date, Staff_ID, Order_Total, Order_Item_Quantity, Order_Total * (1-Discount) AS Discounted_Order_Total
		FROM AggregatedOrders
	)


SELECT owd.Staff_ID
	,ds.Staff_First_Name
	,ds.Staff_Surname
	,SUM(owd.Discounted_Order_Total) AS Total_Staff_Sales
	--,COUNT(owd.Staff_ID) AS Orders_Handled
	--,SUM(owd.Order_Item_Quantity) AS Total_Items_Sold
FROM OrdersWithDiscounts owd
	JOIN DimStaff ds ON owd.Staff_ID = ds.Staff_ID
GROUP BY owd.Staff_ID, ds.Staff_First_Name, ds.Staff_Surname
ORDER BY Total_Staff_Sales DESC
