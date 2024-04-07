-- Tomas_Fuxa_project_SQL_answer_to_question_2
/*
Otázka č. 2. Kolik je možné si koupit litrů mléka a kilogramů chleba 
za první a poslední srovnatelné období v dostupných datech cen a mezd?
*/

WITH
cte_price AS (
  SELECT price_year,
         price_average,
         cat_code,
         cat_name
   FROM t_Tomas_Fuxa_project_SQL_primary_final tf
   WHERE 	tf.cat_code IN (111301,114201) -- kódy potravin pro Chléb a Mléko
   			AND price_year IN ('2006','2018')	
   GROUP BY price_year, cat_code
 ),
cte_salary AS (
  SELECT payroll_year,
         ROUND(AVG(average_salary), 2) AS salary_year_average
   FROM t_Tomas_Fuxa_project_SQL_primary_final tf
   GROUP BY payroll_year
)
SELECT  cte_price.*,
		cte_salary.*,
		ROUND (salary_year_average/price_average) AS amount,
		cpc.price_unit AS unit -- pomocný sloupec s jednotkami daných produktů
FROM cte_price
LEFT JOIN cte_salary ON cte_salary.payroll_year = cte_price.price_year
LEFT JOIN czechia_price_category cpc ON cte_price.cat_code = cpc.code -- pomocný sloupec s jednotkami daných produktů
;