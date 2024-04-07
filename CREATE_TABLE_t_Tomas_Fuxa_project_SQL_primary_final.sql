-- Pohled do tabulky
SELECT * 
FROM t_Tomas_Fuxa_project_SQL_primary_final
;

-- Vytvoření tabulky t_Tomas_Fuxa_project_SQL_primary_final
CREATE OR REPLACE TABLE t_Tomas_Fuxa_project_SQL_primary_final
WITH 
-- tabulka mezd czechia_payroll
czechia_payroll_select AS
	(SELECT cpa.payroll_year,
		cpa.industry_branch_code,
		cpib.name AS industry_branch_name,
		-- průměrná hodnota mezd v daném roce
		ROUND(AVG(cpa.value), 2) AS average_salary,
		-- Hodnota průměrné mzdy za předchozí rok
		LAG (ROUND(AVG(cpa.value), 2), 1) OVER (PARTITION BY cpa.industry_branch_code ORDER BY cpa.payroll_year) AS PrevYear_Average_salary
	FROM czechia_payroll AS cpa
	LEFT JOIN czechia_payroll_industry_branch AS cpib ON cpa.industry_branch_code = cpib.code
	WHERE 	cpa.value_type_code = '5958' -- Typ: 5958 Průměrná hrubá mzda na zaměstnance
		AND cpa.calculation_code = 200 -- Kód výpočtu: 200 Přepočtený
		AND industry_branch_code IS NOT NULL -- Odvětví je vyplněno
		AND cpa.payroll_year BETWEEN '2006' AND '2018'
	GROUP BY cpa.industry_branch_code, cpa.payroll_year -- Seskupeno podle odvětví a roku
	ORDER BY cpa.industry_branch_code ASC, cpa.payroll_year ASC -- Sežazeno podle odvětví a roku roku vzestupně
),
-- tabulka cen potravin
czechia_price_select AS
	(SELECT 
         ROUND(AVG(value), 2) AS price_average, -- průměrná cena potraviny v daném roce
         cp.category_code AS cat_code,
         cpc.name AS cat_name,
         YEAR(cp.date_from) AS price_year,
         -- Hodnota průměrné ceny za předchozí rok
		LAG (ROUND(AVG(cp.value), 2), 1) OVER (PARTITION BY cp.category_code ORDER BY YEAR(cp.date_from)) AS PrevYearValue_price_average
   FROM czechia_price AS cp
   LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
   WHERE cp.region_code IS NOT NULL
   GROUP BY price_year, cat_code
   ORDER BY cat_code, price_year
)
SELECT czechia_payroll_select.*, czechia_price_select.*
FROM czechia_payroll_select
LEFT JOIN czechia_price_select ON czechia_price_select.price_year = czechia_payroll_select.payroll_year
;

