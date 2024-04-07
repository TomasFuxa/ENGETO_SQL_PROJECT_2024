-- Tomas_Fuxa_project_SQL_answer_to_question_5
/*
Otázka č. 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
ve stejném nebo následujícím roce výraznějším růstem?
*/

-- Souhrnný výstup všech změn za jednotlivé roky
WITH cte_y_t_y_change_price AS (
	SELECT
	price_year,
	ROUND(AVG(price_average), 2) AS price_average, -- průměrná cena potraviny v daném roce
	ROUND(AVG(PrevYearValue_price_average), 2) AS PrevYearValue_price_average -- průměrná cena potraviny v minutém roce
	FROM t_Tomas_Fuxa_project_SQL_primary_final tf
	GROUP BY price_year
	ORDER BY price_year
),
cte_y_t_y_change_salary AS (
   	SELECT 
   	payroll_year,
   	ROUND(AVG(average_salary), 2) AS salary_average, -- průměrná mzda v daném roce za všechna odvětví
   	ROUND(AVG(PrevYear_Average_salary), 2) AS PrevYear_Average_salary -- průměrná mzda v předchozím roce za všechna odvětví PrevYearValue_salary
    FROM t_Tomas_Fuxa_project_SQL_primary_final tf
	GROUP BY payroll_year
),
cte_y_t_y_change_gdp AS (
   	SELECT 
   		tf2.year AS gdp_year,
   		ROUND(tf2.GDP, 2) AS gdp_actual, -- hodnota HDP v daném roce
   		LAG (ROUND(tf2.GDP, 2), 1) OVER (ORDER BY tf2.year) AS gdp_previous -- hodnota HDP v předchozím roce
    FROM t_Tomas_Fuxa_project_SQL_secondary_final AS tf2
    WHERE tf2.country_economies = 'Czech Republic'
    AND tf2.YEAR BETWEEN '2006' AND '2018'
)
SELECT 	cte_y_t_y_change_price.*,
  		salary_average,
  		PrevYear_Average_salary,
  		gdp_actual,
  		gdp_previous,
  		ROUND(((price_average - PrevYearValue_price_average)/PrevYearValue_price_average * 100 ),2) AS YearChange_Price_pct, -- meziroční změna cen v %
  		ROUND(((salary_average - PrevYear_Average_salary)/PrevYear_Average_salary * 100 ),2) AS YearChange_Salary_pct, -- meziroční změna mezd v %
  		ROUND(((gdp_actual - gdp_previous)/gdp_previous * 100 ),2) AS YearChange_GDP_pct -- meziroční změna HDP v %		
  FROM cte_y_t_y_change_price
  LEFT JOIN cte_y_t_y_change_salary on cte_y_t_y_change_price.price_year = cte_y_t_y_change_salary.payroll_year -- spojeno přes roky
  LEFT JOIN cte_y_t_y_change_gdp on cte_y_t_y_change_price.price_year = cte_y_t_y_change_gdp.gdp_year -- spojeno přes roky
 ;

-- Doplňkový výpočet korelačních koeficientů mezi změnani cen a HDP a mezi změnami mezd a HDP v České republice mezi lety 2006-2018
WITH cte_corr AS (
	WITH cte_y_t_y_change_price AS (
	SELECT
		price_year,
		ROUND(AVG(price_average), 2) AS price_average, -- průměrná cena potraviny v daném roce
		ROUND(AVG(PrevYearValue_price_average), 2) AS PrevYearValue_price_average -- průměrná cena potraviny v minutém roce
	FROM t_Tomas_Fuxa_project_SQL_primary_final tf
	GROUP BY price_year
	ORDER BY price_year
	),
	cte_y_t_y_change_salary AS (
   	SELECT 
   		payroll_year,
   		ROUND(AVG(average_salary), 2) AS salary_average, -- průměrná mzda v daném roce za všechna odvětví
   		ROUND(AVG(PrevYear_Average_salary), 2) AS PrevYear_Average_salary -- průměrná mzda v předchozím roce za všechna odvětví PrevYearValue_salary
   	 FROM t_Tomas_Fuxa_project_SQL_primary_final tf
		GROUP BY payroll_year
	),
	cte_y_t_y_change_gdp AS (
   	SELECT 
   		tf2.year AS gdp_year,
   		ROUND(tf2.GDP, 2) AS gdp_actual, -- hodnota HDP v daném roce
   		LAG (ROUND(tf2.GDP, 2), 1) OVER (ORDER BY tf2.year) AS gdp_previous -- hodnota HDP v předchozím roce
    FROM t_Tomas_Fuxa_project_SQL_secondary_final AS tf2
    WHERE tf2.country_economies = 'Czech Republic'
    AND tf2.YEAR BETWEEN '2006' AND '2018'
	)
	SELECT 	cte_y_t_y_change_price.*,
  		salary_average,
  		PrevYear_Average_salary,
  		gdp_actual,
  		gdp_previous,
  		ROUND(((price_average - PrevYearValue_price_average)/PrevYearValue_price_average * 100 ),2) AS YearChange_Price_pct, -- meziroční změna cen v %
  		ROUND(((salary_average - PrevYear_Average_salary)/PrevYear_Average_salary * 100 ),2) AS YearChange_Salary_pct, -- meziroční změna mezd v %
  		ROUND(((gdp_actual - gdp_previous)/gdp_previous * 100 ),2) AS YearChange_GDP_pct -- meziroční změna HDP v %		
  FROM cte_y_t_y_change_price
  LEFT JOIN cte_y_t_y_change_salary on cte_y_t_y_change_price.price_year = cte_y_t_y_change_salary.payroll_year -- spojeno přes roky
  LEFT JOIN cte_y_t_y_change_gdp on cte_y_t_y_change_price.price_year = cte_y_t_y_change_gdp.gdp_year -- spojeno přes roky
 )
SELECT 
    (covariance_price_gdp / (SQRT(variance_price) * SQRT(variance_gdp))) AS correlation_coefficient_price_gdp,
    (covariance_salary_gdp / (SQRT(variance_salary) * SQRT(variance_gdp))) AS correlation_coefficient_salary_gdp
FROM 
    (SELECT 
         SUM(POWER(YearChange_Price_pct - mean_price, 2)) / COUNT(YearChange_Price_pct) AS variance_price,
         SUM(POWER(YearChange_GDP_pct - mean_gdp, 2)) / COUNT(YearChange_GDP_pct) AS variance_gdp,
         AVG((YearChange_Price_pct - mean_price) * (YearChange_GDP_pct - mean_gdp)) AS covariance_price_gdp,
         SUM(POWER(YearChange_Salary_pct - mean_salary, 2)) / COUNT(YearChange_Salary_pct) AS variance_salary,
         AVG((YearChange_Salary_pct - mean_salary) * (YearChange_GDP_pct - mean_gdp)) AS covariance_salary_gdp
     FROM 
         cte_corr,
         (SELECT 
              AVG(YearChange_Price_pct) AS mean_price,
              AVG(YearChange_GDP_pct) AS mean_gdp,
              AVG(YearChange_Salary_pct) AS mean_salary
          FROM 
              cte_corr) AS means) AS var_cov
;