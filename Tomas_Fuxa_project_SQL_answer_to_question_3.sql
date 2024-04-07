-- Tomas_Fuxa_project_SQL_answer_to_question_3
/*
Otázka č. 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
*/

WITH cte_y_t_y_change_all AS (
SELECT 	price_year,
        cat_code,
        cat_name,
        ROUND(AVG(price_average), 2) AS price_average, -- průměrná cena potraviny v daném roce
		ROUND(AVG(PrevYearValue_price_average), 2) PrevYearValue_price_average, -- průměrná cena potraviny v předchozím roce
		ROUND(((price_average - PrevYearValue_price_average)/PrevYearValue_price_average * 100 ),2) AS YearChange_pct -- meziroční změna v %
   FROM t_Tomas_Fuxa_project_SQL_primary_final tf
   GROUP BY price_year, cat_code
   ORDER BY cat_code, price_year
)
SELECT cat_code, cat_name,
  		ROUND(AVG(YearChange_pct),2) AS avg_all_year_change_pct
FROM cte_y_t_y_change_all 
GROUP BY cat_code
ORDER BY avg_all_year_change_pct ASC
;