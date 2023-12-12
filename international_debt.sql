-- This query retrieves the first 10 rows from the 'international_debt' table
SELECT *
FROM international_debt
LIMIT 10;


-- Counts the total number of distinct countries represented in the 'international_debt' table
SELECT 
    COUNT(DISTINCT country_name) AS count_country
FROM international_debt;


-- Selects distinct debt indicators and their names from the table, ordering them by the indicator code
SELECT DISTINCT 
    indicator_code AS distinct_debt_indicators,
    indicator_name
FROM international_debt 
ORDER BY distinct_debt_indicators


-- Calculates the total sum of 'debt' in the table and presents it in millions
SELECT 
    ROUND(SUM(debt) / 1000000, 2) AS total_debt 
FROM international_debt;


-- Determines the country with the highest total debt by summing and grouping debts by country, then sorting in descending order
SELECT 
    country_name,
    SUM(debt) AS total_debt
FROM international_debt
GROUP BY country_name
ORDER BY total_debt DESC 
LIMIT 1;


-- Computes the average debt for each debt indicator and lists the top 10 indicators with the highest average debts
SELECT 
    indicator_code AS debt_indicator,
    indicator_name,
    AVG(debt) AS average_debt
FROM international_debt
GROUP BY debt_indicator, indicator_name
ORDER BY average_debt DESC
LIMIT 10;


-- Finds the country and indicator name with the maximum debt amount for the specified indicator code
SELECT 
    country_name, 
    indicator_name
FROM international_debt
WHERE 
    indicator_code = 'DT.AMT.DLXF.CD'
    AND debt = (
        SELECT MAX(debt)
        FROM international_debt
        WHERE indicator_code = 'DT.AMT.DLXF.CD'
    );


-- Calculates the year-over-year increase in total debt for each country and ranks them
WITH YearlyDebt AS (
    SELECT country_name, EXTRACT(YEAR FROM indicator_code) AS year, SUM(debt) AS total_debt
    FROM international_debt
    GROUP BY country_name, year
)
SELECT 
    year, 
    country_name, 
    total_debt - LAG(total_debt) OVER (PARTITION BY country_name ORDER BY year) AS yearly_increase
FROM YearlyDebt
ORDER BY yearly_increase DESC;


-- Identifies the top 5 creditors based on the total amount of debt lent
SELECT 
    indicator_name AS creditor, 
    SUM(debt) AS total_debt
FROM international_debt
GROUP BY indicator_name
ORDER BY total_debt DESC
LIMIT 5;


-- Analyzes the composition of debt types over different decades
SELECT 
    EXTRACT(DECADE FROM indicator_code) AS decade, 
    indicator_name, SUM(debt) AS total_debt
FROM international_debt
GROUP BY decade, indicator_name
ORDER BY decade, total_debt DESC;


-- Analyzes the distribution of debt across different sectors for a specific country
SELECT 
    indicator_name AS sector, 
    SUM(debt) AS total_debt
FROM international_debt
WHERE country_name = 'SpecificCountry'
GROUP BY sector
ORDER BY total_debt DESC;


-- Finds countries with a decreasing trend in their total debt over the years
WITH YearlyDebt AS (
    SELECT country_name, EXTRACT(YEAR FROM indicator_code) AS year, SUM(debt) AS total_debt
    FROM international_debt
    GROUP BY country_name, year
)
SELECT country_name
FROM YearlyDebt
GROUP BY country_name
HAVING MIN(total_debt) < MAX(total_debt)
  AND COUNT(DISTINCT year) > 3; -- Considering data for more than 3 years


