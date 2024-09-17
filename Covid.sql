--Iran: Total Cases vs Total Deaths (Mortality Rate) by Date
SELECT location, date, total_cases, total_deaths, 
	   CONVERT(DECIMAL(10,2),(total_deaths/total_cases)*100) AS mortality_rate
  FROM PortfolioSQLProjects.dbo.covid_deaths
 WHERE total_cases <> 0 
   AND continent IS NOT NULL 
   AND location = 'Iran'
 ORDER BY 1,2


--Countries Sorted by Infection Rate
--Not a good Index as total identified cases are heavily based on functionality of the national health systems.
SELECT location, population, MAX(total_cases) AS cases_total, 
	   CONVERT(DECIMAL(10,2),(MAX(total_cases)/population)*100) AS infection_rate
  FROM PortfolioSQLProjects.dbo.covid_deaths
 WHERE total_cases <> 0 
   AND continent IS NOT NULL
 GROUP BY location, population
 ORDER BY infection_rate DESC
 

--Vaccination by Country
  DROP TABLE IF EXISTS #vaccination_by_country
CREATE TABLE #vaccination_by_country
(
 continent NVARCHAR(255),
 location NVARCHAR(255),
 date DATETIME,
 population NUMERIC,
 new_vaccinations NUMERIC,
 total_vaccinations NUMERIC
)
 
INSERT INTO #vaccination_by_country 
SELECT deceased.continent, deceased.location, deceased.date, deceased.population, vaccination.new_vaccinations,
	   SUM(CONVERT(NUMERIC, vaccination.new_vaccinations)) OVER 
	   (PARTITION BY deceased.location ORDER BY deceased.date) AS total_vaccinations
  FROM PortfolioSQLProjects.dbo.covid_deaths deceased
  JOIN PortfolioSQLProjects.dbo.covid_vaccinations vaccination
	ON deceased.location = vaccination.location
	   AND deceased.date = vaccination.date
 WHERE deceased.continent IS NOT NULL

SELECT *, CONVERT(DECIMAL(10,2),(total_vaccinations/population)*100) AS vaccination_percentage
  FROM #vaccination_by_country
 WHERE new_vaccinations IS NOT NULL
 ORDER BY 2,3

--Vaccination by Country View
CREATE VIEW vaccination_by_country_view AS
SELECT deceased.continent, deceased.location, deceased.date, deceased.population, vaccination.new_vaccinations,
	   SUM(CONVERT(NUMERIC, vaccination.new_vaccinations)) OVER 
	   (PARTITION BY deceased.location ORDER BY deceased.date) AS total_vaccinations
  FROM PortfolioSQLProjects.dbo.covid_deaths deceased
  JOIN PortfolioSQLProjects.dbo.covid_vaccinations vaccination
	ON deceased.location = vaccination.location
	   AND deceased.date = vaccination.date
 WHERE deceased.continent IS NOT NULL

SELECT *
FROM vaccination_by_country_view
WHERE new_vaccinations IS NOT NULL