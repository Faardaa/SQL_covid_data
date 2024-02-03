-- Data that we are going to use it

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3

-- Total Cases vs Total Deaths
-- Shows percentage of population died from covid
SELECT location, date, total_deaths, total_cases, ROUND((total_deaths/total_cases)*100, 2) as 'Death/Case percentage'
FROM PortfolioProject..CovidDeaths

-- Total Cases vs Population
-- Shows percentage of population got Covid 
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 4) as 'Total Cases/Population percentage'
FROM PortfolioProject..CovidDeaths
ORDER BY location

-- Hightest Infection Rate in the Countries
SELECT Location, Population, MAX(total_cases) as 'Max inflation', MAX((total_cases/population)*100) as 'Death/Population rate'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 1

-- Hightest Death Rate in the Countries
SELECT Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 3 DESC

-- Hightest Death Rate in the Continents
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Global table
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) total_death
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- This CTE shows new_vaccinations and total_vaccinations (By adding new_vaccinations)
-- according spesific date

WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinatinons) as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY vac.date)
as RollingPeopleVaccination
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, ROUND(((RollingPeopleVaccinatinons/Population)*100), 2) as 'Vaccinated ppl percentage'
FROM PopVsVac


-- This tepmp table shows new_vaccinations and total_vaccinations (By adding new_vaccinations)
-- according spesific date
DROP TABLE IF EXISTS #PercentPopulationVaccined
CREATE TABLE #PercentPopulationVaccined(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations int, 
RollingPeopleVaccinatinons int)

INSERT INTO #PercentPopulationVaccined
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY vac.date)
as RollingPeopleVaccination
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, RTRIM((ROUND(((RollingPeopleVaccinatinons/Population)*100), 2)),0) as 'Vaccinated people percentage'
FROM #PercentPopulationVaccined


-- Create View to store data for later visualisation
CREATE VIEW PercentPopulationVaccined as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY vac.date)
as RollingPeopleVaccination
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccined
