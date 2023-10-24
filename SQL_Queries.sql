--The following queries are derived from the following open-source dataset: https://ourworldindata.org/covid-deaths
--My goal with these queries is to demonstrate my ability to compile, sort, and aggregate data effectively


--Question: What is the total death count by country in descending order?
--Skills: SELECT, GROUP BY, Aggregation, IS NOT, ORDER BY, MAX, WHERE

SELECT country, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL AND country IS NOT NULL
GROUP BY country
HAVING MAX(cast(total_deaths as int)) IS NOT NULL
ORDER BY TotalDeathCount DESC;



--Question: What is the infection percentage by total_cases/population?
--Skills: Aggregation, MAX, GROUP BY

SELECT country, population, MAX(total_cases) as highestinfectioncount, 
MAX(total_cases/population*100) as percentpopulationinfected
FROM coviddeaths
GROUP BY country, population
ORDER BY percentpopulationinfected desc;


--What are the total cases and vaccines by continent?
--Skills: JOINs, aggregation, GROUP BY

SELECT cd.continent, COUNT(cd.total_cases) AS total_cases, COUNT(cv.total_vaccinations) AS total_vaccinations,
Count(total_deaths) as total_deaths
FROM coviddeaths cd
JOIN covidvaccine cv ON cd.date = cv.date
GROUP BY cd.continent;



--Question: Which country has new vaccines over 10,000,000?
--Skills: Subqueries, aggregation, WHERE

SELECT country, continent, sum(total_vaccinations)
FROM covidvaccine
WHERE country IN
(SELECT country FROM covidvaccine WHERE new_vaccinations > 10000000)
GROUP BY country, continent;


--Query: take a look at data showing the contrast b/w population and vaccination rates
--Skills: JOINs, aliases, NULL

SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths as dea
JOIN covidvaccine as vac
ON dea.country = vac.country
AND dea.date = vac.date
WHERE dea.continent IS NOT null
AND vac.new_vaccinations IS NOT null
ORDER BY 2,3


--Query: Modify the previous query to keep a running count on new vaccinations, ordered by country
--Skills: PARTITION, OVER, JOINs, NULL values

SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.country, dea.date) AS total_vaccinations
FROM coviddeaths AS dea
JOIN covidvaccine AS vac
ON dea.country = vac.country
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
ORDER BY dea.country, dea.date;



--Query: Use the previous query to create a stored function called "RunningCovidCount"
--SKills: Stored procedures, Window Function

CREATE OR REPLACE FUNCTION RunningCovidCount()
RETURNS TABLE (
    continent text,
    country text,
    date date,
    population numeric,
    new_vaccinations numeric, 
    total_vaccinations numeric
) AS $$
BEGIN
    RETURN QUERY (
        SELECT
            dea.continent,
            dea.country,
            dea.date,
            dea.population,
            vac.new_vaccinations,
            SUM(vac.new_vaccinations) OVER (PARTITION BY dea.country, dea.date) AS total_vaccinations
        FROM coviddeaths AS dea
        JOIN covidvaccine AS vac
        ON dea.country = vac.country
        AND dea.date = vac.date
        WHERE dea.continent IS NOT NULL
        AND vac.new_vaccinations IS NOT NULL
        ORDER BY dea.country, dea.date
    );
END;
$$ LANGUAGE sql;


SELECT * FROM RunningCovidCount()
ORDER BY country, date;

--DROP FUNCTION RunningCovidCount()
