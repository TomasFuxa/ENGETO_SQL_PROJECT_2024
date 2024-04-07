-- Tomas_Fuxa_project_SQL_answer_to_question_1
/*
Otázka č. 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
*/

-- Pomocný výber dat pro všechna odvětví a roky
SELECT 	payroll_year,
		industry_branch_code,
		industry_branch_name,
		average_salary,
		PrevYear_Average_salary,
		-- Meziroční rozdíl průměrných mezd v odvětví
		CASE
			WHEN PrevYear_Average_salary IS NULL THEN 'NULL'
        	WHEN average_salary - PrevYear_Average_salary > 0 THEN 'Y_to_Y_increase'
        	WHEN average_salary - PrevYear_Average_salary < 0 THEN 'Y_to_Y_decrease'
        	ELSE 'equal'
    	END AS difference
FROM t_Tomas_Fuxa_project_SQL_primary_final AS tf
GROUP BY tf.industry_branch_code, tf.payroll_year -- Seskupeno podle odvětví a roku
ORDER BY tf.industry_branch_code ASC, tf.payroll_year ASC
;

-- Seznam odvětví, které zaznamenali meziročně pokes průměrných mezd
SELECT 	DISTINCT industry_branch_code,
		industry_branch_name
FROM
	(SELECT 	payroll_year,
		industry_branch_code,
		industry_branch_name,
		average_salary,
		PrevYear_Average_salary,
		-- Meziroční rozdíl průměrných mezd v odvětví
		CASE
			WHEN PrevYear_Average_salary IS NULL THEN 'NULL'
        	WHEN average_salary - PrevYear_Average_salary > 0 THEN 'Y_to_Y_increase'
        	WHEN average_salary - PrevYear_Average_salary < 0 THEN 'Y_to_Y_decrease'
        	ELSE 'equal'
    	END AS difference
	FROM t_Tomas_Fuxa_project_SQL_primary_final AS tf
	GROUP BY tf.industry_branch_code, tf.payroll_year -- Seskupeno podle odvětví a roku
	ORDER BY tf.industry_branch_code ASC, tf.payroll_year ASC -- Sežazeno podle roku vzestupně a dále podle průměrné mzdy sestupně
	) a
WHERE a.difference = 'Y_to_Y_decrease'
;