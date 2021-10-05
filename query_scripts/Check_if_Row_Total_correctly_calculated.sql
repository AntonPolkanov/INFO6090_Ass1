-- This script checks if the Row_Total column stores correct data by
-- multiplying Item_Quantity by Item_Price. The isError column demonstrates
-- a comparison result of the given and calculated Row_Total with pricision stored at the @PRECISION variable.
-- '1' - the values are not equal 
-- '0' - the values are equal

-- If all data are correct, the script returns NOTHING,
-- otherwise the records where Row_Total do not match.

DECLARE @PRECISION decimal(3,2) = 0.01 

;WITH CTE
AS (
SELECT
	   fs.[Sale_Date]
      ,fs.[Receipt_Id]
      ,fs.[Customer_ID]
      ,fs.[Staff_ID]
      ,fs.[Item_ID]
      ,fs.[Receipt_Transaction_Row_ID]
      ,fs.[Item_Quantity]
      ,fs.[Row_Total]
	  ,fs.[Item_Quantity] * di.[Item_Unit_Price] as Row_Total_Calculated
	  , CASE 
			WHEN ABS(Row_Total - fs.[Item_Quantity] * di.[Item_Unit_Price]) < @PRECISION
				THEN '0'
				ELSE '1'
			END
			AS isError
  FROM [Sales].[dbo].[FactSale] fs
	JOIN DimItem di ON fs.Item_ID=di.Item_ID
  )

SELECT *
FROM CTE
WHERE isError = '1'