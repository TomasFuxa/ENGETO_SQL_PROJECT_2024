-- Pohled do tabulky
SELECT * 
FROM t_Tomas_Fuxa_project_SQL_secondary_final
;

-- Vytvoření tabulky t_Tomas_Fuxa_project_SQL_secondary_final
CREATE OR REPLACE TABLE t_Tomas_Fuxa_project_SQL_secondary_final
SELECT 	e.country AS country_economies,
		e.YEAR,
		e.GDP,
		e.population AS population_economies,
		e.gini,
		e.taxes,
		e.fertility,
		e.mortaliy_under5,
		c.*
FROM economies e
LEFT JOIN countries c ON c.country=e.country 
WHERE c.continent = 'Europe'
;