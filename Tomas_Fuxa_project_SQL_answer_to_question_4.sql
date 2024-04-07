-- Tomas_Fuxa_project_SQL_answer_to_question_4
/*
Otázka č. 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
*/

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
)
SELECT 	cte_y_t_y_change_price.*,
  			salary_average, PrevYear_Average_salary,
  			ROUND(((price_average - PrevYearValue_price_average)/PrevYearValue_price_average * 100 ),2) AS YearChange_Price_pct, -- meziroční změna cen v %
  			ROUND(((salary_average - PrevYear_Average_salary)/PrevYear_Average_salary * 100 ),2) AS YearChange_Salary_pct, -- meziroční změna mezd v %
  			ROUND(((price_average - PrevYearValue_price_average)/PrevYearValue_price_average * 100 ),2) - ROUND(((salary_average - PrevYear_Average_salary)/PrevYear_Average_salary * 100 ),2) AS difference 	
FROM cte_y_t_y_change_price
LEFT JOIN  cte_y_t_y_change_salary on cte_y_t_y_change_price.price_year = cte_y_t_y_change_salary.payroll_year -- spojeno přes roky
ORDER BY difference DESC
; 