/* 
Using SQL to analyze temperature data by US state over the past 25 years.
SQL functions used include: aggregate functions, joins, window functions, CTE's, subqueries, datetime functions

*/
--------------------------------------------------------------------------------------

--Average monthly temperature by state, compared to avg annual temperature by state

--calculating average temperature range by month, and average for the year, by state
SELECT DISTINCT
	State
	,YEAR(dt) AS Yr
	,MONTH(dt) As Mo
	,AverageTemperature AS AvgTemp
	,AverageTemperatureUncertainty AS "Temp +/-"
	,AverageTemperature + AverageTemperatureUncertainty AS TempHighRange
	,AverageTemperature - AverageTemperatureUncertainty AS TempLowRange
	,ROUND(AVG(AverageTemperature) OVER (PARTITION BY State,YEAR(dt)),2) AS AvgAnnual
FROM LandTempByState
WHERE 
	Country LIKE '%States'
	AND YEAR(dt) > YEAR(GETDATE())-25 --goes back 25 years from current year
	AND AverageTemperature IS NOT NULL
GROUP BY
	State
	,YEAR(dt)
	,MONTH(dt)
	,AverageTemperature 
	,AverageTemperatureUncertainty
	,AverageTemperature + AverageTemperatureUncertainty
	,AverageTemperature - AverageTemperatureUncertainty
ORDER BY State,Yr,Mo;
---------------------------------------------------------------------------------------

--state and year with highest average annual temperature over the past 25 years

--CTE to average annual temperature from monthly temp data, by state, by year
WITH temp_avg AS (
	SELECT DISTINCT 
		State
		,YEAR(dt) AS Yr
		,ROUND(AVG(AverageTemperature) OVER (PARTITION BY State,YEAR(dt)),2) AS AvgAnnual
	FROM LandTempByState
	WHERE 
		Country LIKE '%States'
		AND YEAR(dt) >= YEAR(GETDATE())-25 --goes back 25 years from current year
		AND AverageTemperature IS NOT NULL
	GROUP BY
		State
		,YEAR(dt)
		,AverageTemperature
)
--from the CTE, select the state with the highest average annual temperature and show what year that occurred
SELECT TOP 1 
	State
	,Yr
	,AvgAnnual
FROM temp_avg
GROUP BY 
	State
	,Yr
	,AvgAnnual
ORDER BY AvgAnnual DESC;
----------------------------------------------------------------------------------------

--averaging state temperature change from 1996 to 2013

--CTE creating a table showing avg annual temperature for the two years being compared (1996 and 2013) by state and region.
WITH temp_comp AS (
	SELECT DISTINCT
		State
		,YEAR(dt) AS Yr
		,ROUND(AVG(AverageTemperature) OVER (PARTITION BY State,YEAR(dt)),2) AS AvgAnnual
		,region
	FROM LandTempByState tbs
	LEFT JOIN state_loc sl ON sl.state_nm = tbs.state
	WHERE 
		Country LIKE '%States'
		AND (YEAR(dt) = 1996 OR YEAR(dt) = 2013)
		AND AverageTemperature IS NOT NULL
	GROUP BY
		State
		,region
		,YEAR(dt)
		,AverageTemperature
		,region
)
--subquery creates column that calculates difference in avg annual temperature using LAG function
--main query filters only the 2013 row (the latest year) since that row has the temp change against 1996.
SELECT State,region,AvgAnnual,Prior_Temp,"Temp_Chng_'96 to '13"
FROM (SELECT
	Yr
	,State
	,region
	,AvgAnnual
	,LAG(AvgAnnual) OVER (ORDER BY State) AS Prior_Temp
	,ROUND(AvgAnnual-LAG(AvgAnnual) OVER (ORDER BY State),2) AS "Temp_Chng_'96 to '13"
	FROM temp_comp) AS sub
WHERE Yr = 2013
ORDER BY "Temp_Chng_'96 to '13" DESC;
-----------------------------------------------------------------------------------------

--averaging state temperature change from 1996 to 2013, comparing the total for states east and west of the Mississippi River

--cte creating a table showing avg annual temperature for the two years being compared (1996 and 2013) by east and west regions.
WITH temp_comp AS (
	SELECT DISTINCT
		region
		,YEAR(dt) AS Yr
		,ROUND(AVG(AverageTemperature) OVER (PARTITION BY region,YEAR(dt)),2) AS AvgAnnual
		
	FROM LandTempByState tbs
	INNER JOIN state_loc sl ON sl.state_nm = tbs.state
	WHERE 
		Country LIKE '%States'
		AND (YEAR(dt) = 1996 OR YEAR(dt) = 2013)
		AND AverageTemperature IS NOT NULL
	GROUP BY
		region
		,YEAR(dt)
		,AverageTemperature
)
--subquery creates column that calculates difference in avg annual temperature using LAG function
--main query filters only the 2013 row (the latest year) since that row has the temp change against 1996.
SELECT region,"Temp_Chng_'96 to '13"
FROM (SELECT
	Yr
	,region
	,AvgAnnual
	,LAG(AvgAnnual) OVER (ORDER BY region) AS Prior_Temp
	,ROUND(AvgAnnual-LAG(AvgAnnual) OVER (ORDER BY region),2) AS "Temp_Chng_'96 to '13"
	FROM temp_comp) AS sub
WHERE Yr = 2013
ORDER BY "Temp_Chng_'96 to '13" DESC;
