--review of unemployment rates compared to unemployment for agricultural workers

--------------------------------------------------------------------------------
-- compares years of highest and lowest total unemployment rates and what the
-- agricultural unemployment rate was for those years

USE US_employment;
SELECT year
	,unemployed_percent
	,labor_force AS "labor_force (000s)"
	,unemployed AS "unemployed (000s)"
	,agrictulture_ratio AS Ag_employed
	,CAST(CAST(agrictulture_ratio AS decimal(9,2))/labor_force*100 AS DECIMAL(10,2)) AS percent_agriculture
FROM employment_rates
WHERE
	unemployed_percent = (SELECT MAX(unemployed_percent) FROM employment_rates)
	OR
	unemployed_percent = (SELECT MIN(unemployed_percent) FROM employment_rates);

--------------------------------------------------------------------------------
-- returns years with the highest and lowest agricultural unemployment rates
-- and compares them to the total unemployment rates for those years

USE US_employment;
WITH cte AS (
	SELECT year
		,unemployed_percent
		,labor_force AS "labor_force (000s)"
		,unemployed AS "unemployed (000s)"
		,agrictulture_ratio AS Ag_employed
		,CAST(CAST(agrictulture_ratio AS decimal(9,2))/labor_force*100 AS DECIMAL(10,2)) AS percent_agriculture
	FROM employment_rates
)

SELECT year
	,unemployed_percent
	,percent_agriculture

FROM cte

WHERE percent_agriculture = (SELECT MIN(percent_agriculture) FROM cte)
	OR
	percent_agriculture = (SELECT MAX(percent_agriculture) FROM cte)
