SELECT *
FROM CovidDeaths
ORDER BY 3, 4

SELECT *
FROM CovidVaccinations
ORDER BY  3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2


--Total Cases vs. Total Deaths (US/Israel, 2022)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
	--AND date BETWEEN '2022-01-01 00:00:00:000' AND '2022-12-31 00:00:00:000'
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Israel'
	--AND date BETWEEN '2022-01-01 00:00:00:000' AND '2022-12-31 00:00:00:000'
ORDER BY 1, 2


--Population vs. Total Cases (US/Israel, 2022)

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE location = 'United States'
	AND date BETWEEN '2022-01-01 00:00:00:000' AND '2022-12-31 00:00:00:000'
ORDER BY 1, 2

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE location = 'Israel'
	AND date BETWEEN '2022-01-01 00:00:00:000' AND '2022-12-31 00:00:00:000'
ORDER BY 1, 2


--Population vs. Total Deaths (US/Israel, 2022)

SELECT location, date, population, total_deaths, (total_deaths/population)*100 AS TotalDeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
	--AND date BETWEEN '2022-01-01 00:00:00:000' AND '2022-12-31 00:00:00:000'
ORDER BY 1, 2

SELECT location, date, population, total_deaths, (total_deaths/population)*100 AS TotalDeathPercentage
FROM CovidDeaths
WHERE location = 'Israel'
	--AND date BETWEEN '2022-01-01 00:00:00:000' AND '2022-12-31 00:00:00:000'
ORDER BY 1, 2


--Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CovidPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


--Countries with Highest Death Rate Compared to Infection Rate

SELECT location, total_cases, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/total_cases))*100 AS DeathPercentage
FROM CovidDeaths
GROUP BY location, total_cases
ORDER BY 4 DESC


--Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths,  SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS CovidDeathPercentage, SUM(CAST(new_deaths AS int))/MAX(population)*100 AS PopulationDeathPercentage
FROM CovidDeaths


--Total Population vs. Vaccinations

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 1, 2, 3


--Vaccination Rate vs. Infection Rate

SELECT CD.location, SUM(CONVERT(numeric, CV.new_vaccinations))/MAX(CD.population)*100 AS VaccinationRate, SUM(CD.new_cases)/MAX(CD.population)*100 AS InfectionRate
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CV.new_vaccinations IS NOT NULL
GROUP BY CD.location
ORDER BY 2 DESC


--Total Population vs. Vaccinations

--SELECT CD.continent, CD.location, CD.date, CD.population, CV. new_vaccinations, 
--	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
--FROM CovidDeaths AS CD
--JOIN CovidVaccinations AS CV
--	ON CD.location = CV.location
--	AND CD.date = CV.date
--WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3


--CTE

WITH PopVsVax (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS (
SELECT CD.continent, CD.location, CD.date, CD.population, CV. new_vaccinations, 
	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentageVaccinated
FROM PopVsVax


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
NewVaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV. new_vaccinations, 
	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentageVaccinated
FROM #PercentPopulationVaccinated


--CREATE VIEW

CREATE VIEW PercentPopulationVaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV. new_vaccinations, 
	SUM(CONVERT(numeric, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated