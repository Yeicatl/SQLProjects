SELECT *
FROM ProjectExploreData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM ProjectExploreData..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM ProjectExploreData..CovidDeaths
ORDER BY 1,2

--looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM ProjectExploreData..CovidDeaths
WHERE Location like '%Mexico%'
AND continent IS NOT NULL
ORDER BY 1,2


--Looking at the total cases Vs population
--Shows what percentage of population got Covid
SELECT Location, date,population, total_cases,  (total_cases/population)*100 AS Population_infected_percentage
FROM ProjectExploreData..CovidDeaths
WHERE Location like '%Mexico%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at countries with highest Infection Rate compared to Population 
SELECT Location,population, MAX(total_cases) AS Highest_Infection_Count,  MAX((total_cases/population))*100 AS Population_infected_percentage
FROM ProjectExploreData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location,population
ORDER BY 4 DESC

--Showing Countries with Highest Death  Count per Population 
SELECT Location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM ProjectExploreData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC

--Showing Continents with Highest Death  Count per Population 
SELECT continent, MAX(CAST(Total_deaths AS INT)) as Total_Death_Count
FROM ProjectExploreData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC 


--Global Data about COVID
--Death Percentage per Date
SELECT  date, SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Total_Deaths_Percentage
FROM ProjectExploreData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Death Percentage across the world
SELECT   SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Total_Deaths_Percentage
FROM ProjectExploreData..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population Vs Vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations,New_Vaccinations_Count) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS New_Vaccinations_Count
FROM ProjectExploreData..CovidDeaths dea
JOIN ProjectExploreData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (New_Vaccinations_Count/population)*100 AS Population_vaccinated
FROM PopvsVac

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
New_Vaccinations_Count numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS New_Vaccinations_Count
FROM ProjectExploreData..CovidDeaths dea
JOIN ProjectExploreData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * , (New_Vaccinations_Count/population)*100 AS Population_vaccinated
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS New_Vaccinations_Count
FROM ProjectExploreData..CovidDeaths dea
JOIN ProjectExploreData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL