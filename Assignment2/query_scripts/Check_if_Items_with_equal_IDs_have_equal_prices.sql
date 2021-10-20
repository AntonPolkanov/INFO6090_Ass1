-- If the query prints TRUE opposite an Item_ID,
-- then all items with this Item_ID have equal prices.

;WITH ItemPrice AS (
	SELECT di.Item_ID, di.Item_Unit_Price
	FROM FactSales fs
		JOIN DimItem di ON fs.Dim_Item_ID = di.ID
	GROUP BY di.Item_ID, di.Item_Unit_Price
)

SELECT 
	Item_ID, 
	CASE 
		WHEN COUNT(Item_Unit_Price) > 1 
			THEN 'FALSE' 
			ELSE 'TRUE' 
		END 
	AS IsPriceUniqueForID
FROM ItemPrice
GROUP BY Item_ID