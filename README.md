# ENGETO_SQL_PROJECT_2024
## ZADANI
Úvod do projektu
Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

Datové sady, které je možné použít pro získání vhodného datového podkladu
Primární tabulky:

czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
Číselníky sdílených informací o ČR:

czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
czechia_district – Číselník okresů České republiky dle normy LAU.
Dodatečné tabulky:

countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.
Výzkumné otázky
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
Výstup projektu
Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky. Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.

Na svém GitHub účtu vytvořte repozitář (může být soukromý), kam uložíte všechny informace k projektu – hlavně SQL skript generující výslednou tabulku, popis mezivýsledků (průvodní listinu) a informace o výstupních datech (například kde chybí hodnoty apod.).

## ANALYZA A POSTUP
Na začátku projektu jsem provedl obecné selecty a průzkum obsahu sloupců ve všech primárních i dodatečných tabulkách, abych si udělat představu, jaká data jednotlivé tabulky obsahují a jakými klíči jsou propojené.
Jedním z cílů projektu bylo vytvořit pomocné datové tabulky, které by měly obsahovat data potřebná k odpovědím na výzkumné otázky. Začal jsem tedy postupně analyzovat jednotlivé výzkumné otázky a sepisovat si seznamy tabulek a sloupců, které jsou pro jednotlivé otázky potřeba.

Otázka č.1 – Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Pro zodpovědění této otázky není potřeba využívat data z tabulky cen potravin, základní data jsou obsažena v tabulce mezd. Provedl jsem tedy základní výstup z tabulky "czechia_payroll", kde jsem pracoval primárně se sloupci payroll_year, industry_branch_code a value. Analýzou dat jsem prověřil hodnoty NULL a vybral variantu pro výsledný calculation_code = 200 (kód výpočtu: Přepočtený) a value_type_code = '5958' (typ kódu: Průměrná hrubá mzda na zaměstnance)
Vytvořil jsem si pomocné sloupce, kde je vyplněna: 
-	průměrná hodnota mezd v daném roce - zahrnuty všechny kvartály, pro dané odvětví (funkce AVG)
-	hodnota průměrné mzdy za předchozí rok (funkce LAG)
-	meziroční rozdíl průměrných mezd v odvětví (porovnání a vypsání hodnot přes výraz CASE)
 Data jsem dále seskupil podle odvětví a roku a ve výsledku i seřadil podle odvětví a roku vzestupně.

Otázka č.2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Pro zodpovězení této otázky je potřeba udělat join dvou tabulek a to tabulky „czechia_price", kde jsou ceny potravin uvedeny za časové období (date_from a date_to) a tabulky „czechia_payroll“ kde jsou uvedeny mzdy za jednotlivá období (payroll_year). Průnik dostupných roků z obou tabulek je za roky 2006 až 2018. Spojovacím klíčem obou tabulek je hodnota rok, konkrétně YEAR(cp.date_from) = cpa.payroll_year.

Pro výpočet jsou si vytvořil tyto pomocné sloupce:
-	průměrná cena potraviny v daném roce (funkce AVG)
-	průměrná mzda v daném roce za všechna odvětví (funkce AVG)
-	Podíl průměrné mzdy a průměrné ceny potravin

Výstup jsem omezil na kódy potravin pro Chléb a Mléko a na roky 2006 a 2018. Jednotka u obou zkoumaných potravin je 1 (1l mléka a 1kg chleba). Z výsledku jsem následně zjistil kolik litrů mléka a kg chleba se za průměrnou mzdu v daném roce dalo koupit.

Otázka č.3 - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Pro zodpovězení této otázky jsem pracoval s tabulkou „czechia_price", kde jsem si spočetl průměrné cenuy jednotlivých potravin v daných letech (2006 – 2018). Přes funkci LAG jsem si poté stanovil hodnotu průměrné ceny za předchozí rok. Poté jsem již mohl vypočítat meziroční nárůst/pokles ceny dané potraviny a ve výsledku pak udělat průměrné procentuální meziroční nárůsty ceny v letech 2006 až 2018 a po seřazení zjistit, jaký produkt za celé sledované období zdražoval průměrně nejpomaleji, v tomto případě se jednalo dokonce o zlevňování, jelikož číslo bylo záporné a hledaný produkt jak v průměrném meziročním srovnání, tak ve srovnáním za první a poslední sledovaný rok zaznamenal pokles ceny.

Otázka č.4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Pro tuto otázku jsem využil jako základ data z otázky č.3, kde jsem pracoval s meziročním nárůstem cen jednotlivých produktů. Do výstupu jsem analogicky připojil pro daný rok sloupec s hodnotou průměrných mezd a výpočtu meziroční změny mezd. Ve výsledku jsem poté pro jednotlivé roky určil meziroční růst mezd a meziroční nárůst cen všech potravin. Poté jsem porovnával tyto dva meziroční ukazatele, zdali je mezi nimi hledaný rozdíl více než 10 %, což jsem interpretoval tak, že rozdíl mezi procentní meziroční změnu cen a procentní meziroční změnu mezd je pro daný rok více než 10 procentních bodů. 

Otázka č.5 - Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Pro zjištění vlivu výšky HDP na změny ve mzdách a cenách potravin jsem vytvořil tabulku, kde je pro jednotlivé roky vidět procentuální meziroční změna cen, mezd i HDP.
Při porovnání třech největších nárůstů HDP (rok 2007 – meziroční nárůst 5,57 %; rok 2015 – meziroční nárůst 5,39 %; rok 2017 – meziroční nárůst 5,17 %) nelze jednoznačně říci, že tyto nárůsty vždy výrazně ovlivnily mzdy nebo ceny v daném nebo následujících roce. V letech 2007 a 2017 je sice viditelné, že s nárůstem HDP výrazně vzrostli ceny a mzdy v daném roce, ale v roce následujícím došlo v obou letech k výraznému zvýšení pouze u mezd, výrazné zvýšení cen se projevilo jen v roce 2008 nikoliv však v roce 2018. Dále pak druhý největší nárůst HDP (v roce 2015) doprovází naopak snížení cen v daném i následujícím roce a pouze mírný nárůst mezd v daném i následujícím roce.
Pro ověření předběžných závěrů, že HDP výrazně neovlivňuje ceny a mzdy jsem se rozhodl použít korelační analýzu, resp. vypočíst korelační koeficient, který by vyjádřil sílu a směr vztahu mezi dvěma proměnnými.
V tomto případě jsem spočítal korelaci mezi HDP a změnami ve mzdách, a také korelaci mezi HDP a změnami v cenách potravin. Korelační koeficient mezd a HPD vyšel 0,44 a korelační koeficient cen a HPD vyšel 0,47.
Hodnota korelačního koeficientu 0,4 naznačuje spíše střední míru lineárního vztahu mezi dvěma proměnnými. To znamená, že existuje určitý vztah mezi proměnnými, ale není to extrémně silný vztah.

V další fázi projektu jsem vytvořil požadované tabulky:

t_Tomas_Fuxa_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky)

-	Tabulku jsem vytvořil pomocí Common Table Expression (CTE) spojením všech základních dat vycházejících z analýzy pěti výzkumných otázek.
  
t_ Tomas_Fuxa_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech)

-	Tabulku jsem vytvořil pomocí spojením (JOIN) dvou dodatečných tabulek:
  
countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok

Zadní explicitně neříká, jaký má být rozsah sloupců či filtrů této tabulky, rozsah jsem tedy stanovil maximální dle výchozích tabulek „countries“ a „economies“ a obsah jsem omezil pouze na všechny státy, kde je hodnota sloupce continent = 'Europe', jelikož zadání říká, že tabulka má sloužit „pro dodatečná data o dalších evropských státech“.
Následně jsem pokračoval vytvořením pěti sad SQL nad tabulkou t_Tomas_Fuxa_project_SQL_primary_final a t_Tomas_Fuxa_project_SQL_secondary_final, jejichž výsledky ukazují odpovědi na jednotlivé výzkumné otázky.

## VYSLEDKY

Vytvořeno 7 sad SQL:
- CREATE_TABLE_t_Tomas_Fuxa_project_SQL_primary_final
- CREATE_TABLE_t_Tomas_Fuxa_project_SQL_secondary_final
- Tomas_Fuxa_project_SQL_answer_to_question_1
- Tomas_Fuxa_project_SQL_answer_to_question_2
- Tomas_Fuxa_project_SQL_answer_to_question_3
- Tomas_Fuxa_project_SQL_answer_to_question_4
- Tomas_Fuxa_project_SQL_answer_to_question_5

Odpovědi na výzkumné otázky:

1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
   
Odpověď: V prvním selectu se přehled aktuálních a předchozích průměrných mezd za jednotlivá odvětví mezi roky 2006 a 2018. Podle posledního sloupce difference lze určit, zdali meziročně docházelo k nárůstu nebo poklesu průměrné mzdy. 
V druhém selectu je poté výstup těch odvětví, u kterých alespoň v jednom roce mzdy meziročně klesaly (celkem 16 odvětví). Ve zbývajících třech odvětvích (C, Q, S) mzdy tedy nezaznamenaly žádný pokles a meziročně vždy stoupaly.

2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
   
Odpověď: Srovnatelné období je za roky 2006 až 2018, tedy první srovnatelný rok je 2006 a poslední srovnatelný rok je 2018. V roce 2006 bylo možné za průměrnou mzdu koupit 1466 litrů mléka a 1313 kilogramů chleba. V roce 2018 pak bylo možné za průměrnou mzdu koupit 1670 litrů mléka a 1365 kilogramů chleba. 

3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší procentuální meziroční nárůst)?
   
Odpověď: Nejnižší průměrné procentuální meziroční nárůsty ceny byly v letech 2006 až 2018 u produktu Cukr krystalový, který průměrně za celé období zlevňoval o 1,92 %. Mezi prvním měřeným rokem a posledním měřeným rokem je celkový pokles ceny o 27,5 %.

4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
   
Odpověď: Ne, jelikož největší meziroční rozdíl mezi nárůstem cen potravin a nárůstem mezd byl v roce 2013 a činil 6,66 %.

5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Odpověď: Pro zjištění vlivu výšky HDP na změny ve mzdách a cenách potravin jsem vytvořil tabulku, kde je pro jednotlivé roky vidět procentuální meziroční změna cen, mezd i HDP.
Při porovnání třech největších nárůstů HDP (rok 2007 – meziroční nárůst 5,57 %; rok 2015 – meziroční nárůst 5,39 %; rok 2017 – meziroční nárůst 5,17 %) nelze jednoznačně říci, že tyto nárůsty vždy výrazně ovlivnily mzdy nebo ceny v daném nebo následujících roce. V letech 2007 a 2017 je sice viditelné, že s nárůstem HDP výrazně vzrostli ceny a mzdy v daném roce, ale v roce následujícím došlo v obou letech k výraznému zvýšení pouze u mezd a výrazné zvýšení cen se projevilo jen v roce 2008 nikoliv však v roce 2018. Dále pak druhý největší nárůst HDP (v roce 2015) doprovází naopak snížení cen v daném i následujícím roce a pouze mírný nárůst mezd v daném i následujícím roce.
Pro ověření předběžných závěrů, že HDP výrazně neovlivňuje ceny a mzdy jsem se rozhodl použít korelační analýzu, resp. vypočíst korelační koeficient, který by vyjádřil sílu a směr vztahu mezi dvěma proměnnými.
V tomto případě jsem spočítal korelaci mezi HDP a změnami ve mzdách, a také korelaci mezi HDP a změnami v cenách potravin. Korelační koeficient mezd a HDP vyšel 0,44 a korelační koeficient cen a HDP vyšel 0,48.
Hodnota korelačního koeficientu 0,4 - 0,5 naznačuje spíše střední míru lineárního vztahu mezi dvěma proměnnými. To znamená, že existuje určitý vztah mezi proměnnými, ale není to extrémně silný vztah
