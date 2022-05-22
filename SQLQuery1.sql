-- Calculate average amount of Views per Type
WITH t1 as 
(Select SUM(Views) as Type_Views,
	Boat#Type,
	Count(Boat#Type) as Count_boat
	FROM boats
GROUP BY Boat#Type)

SELECT *,  Type_views/Count_boat as average
FROM t1
ORDER BY average DESC


-- Calculate average amount of Views per MedoOf
WITH t2 as 
(Select SUM(Views) as MedoOf_Views,
	Material,
	Count(MedoOf) as MedoOf_sum
	FROM boats
GROUP BY MedoOf)

SELECT *,  MedoOf_Views/MedoOf_sum as averageM
FROM t2
ORDER BY averageM DESC


-- Calculate average amount of Views per Year
WITH t3 as 
(Select SUM(Views) as Year_Views,
	Year,
	Count(Year) as Year_sum
	FROM boats
GROUP BY Yea)

SELECT *,  Year_Views/Year_sum as averageY
FROM t3
ORDER BY averageY DESC


-- Calculate amount of Views per Used_New
SELECT 
SUM(Views) as Used_View, Used_New
FROM boats
GROUP BY Used_New


-- Calculate amount of Views per Fuel
WITH t4 as 
(Select SUM(Views) as Fuel_Views,
	Fuel,
	Count(Fuel) as Fuel_sum
	FROM boats
GROUP BY Fuel)

SELECT *,  Fuel_Views/Fuel_sum as averageF
FROM t4
ORDER BY averagef DESC


-- Calculate average amount of Views per Fuel
WITH t5 as 
(Select SUM(Views) as Display_Views,
	Display_model,
	Count(Display_model) as Displey_sum
	FROM boats
GROUP BY Display_model)

SELECT *,  Fuel_Views/Fuel_sum as averageF
FROM t4
ORDER BY averagef DESC


-- Calculate average amount of Views per Price split into categories

DROP tABLE IF EXISTS #temp_Price

SELECT Price_Eur,
	Views,
	CASE WHEN Price_Eur > 0  and Price_Eur <= 2500 THEN 'A 0-2500'
		WHEN Price_Eur > 2501  and Price_Eur <= 10000 THEN 'B 2501-10000'
		 WHEN Price_Eur > 10001 and Price_Eur <= 25000 THEN 'C 10001-25000'	
		 WHEN Price_Eur > 25001 and Price_Eur <= 50000 THEN 'D 25001-50000'
		WHEN Price_Eur > 50001 and Price_Eur <= 75000 THEN 'E 50001-75000'	
		WHEN Price_Eur > 75001 and Price_Eur <= 100000 THEN 'F 75001-100000'
		WHEN Price_Eur > 100001 and Price_Eur <= 150000 THEN 'G 100001-150000'	
		WHEN Price_Eur > 150001 and Price_Eur <= 250000 THEN 'H 100001-150000'
		WHEN Price_Eur > 250001 and Price_Eur <= 350000 THEN 'I 250001- 350000'
		WHEN Price_Eur > 350001 and Price_Eur <= 500000 THEN 'J 350001-500000'
		WHEN Price_Eur > 500001 and Price_Eur <= 1000000 THEN 'K 500001-1000000'
		WHEN Price_Eur > 1000001 and Price_Eur <= 10000000 THEN 'L 1000001-10000000'
		WHEN Price_Eur > 10000001 and Price_Eur <= 20000000 THEN 'M 10000001-20000000'
		WHEN Price_Eur > 20000000 THEN 'N >20000001'
		 END as Price_category
INTO #temp_Price
FROM boats
Order by Price_Eur

WITH t6 as 
(Select SUM(Views) as price_Views,
	Price_category,
	Count(Price_category) as Price_cat_sum
	FROM #temp_Price
GROUP BY Price_category)

SELECT *,  price_Views/Price_cat_sum as averageP
FROM t6
ORDER BY Price_category 