/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- 1. Select data that we going to using

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

	
-- 2. Select Data that we are going to be starting with
	
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- 3. Looking at Total Cases vs Total Deaths
--Shows that likelihood of dying if you contract Covid in Malaysia

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Malaysia%'
ORDER BY 1,2

-- 4. Looking at Total Cases vs Population
--Shows what percentage of population get Covid

SELECT location,date,Population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- 5. Looking at Countries with Highest Infection Rate compared to Population

SELECT location,Population,MAX(total_cases)AS HighestInfectionCount, MAX((total_cases/population))*100 
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,Population
ORDER BY PercentPopulationInfected desc

-- 6. Showing Countries with Highest Death Count per Population
--- we are using 'cast' because there issue with data type for total_deaths in nvarchar when we use aggregate function

SELECT Location,MAX(cast(Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathcount desc
	
-- 7. Let's break things down by Continent

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- 8. Global numbers of Total Cases, Total Deaths and Deaths Percentage

SELECT date,SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

-- 9. Total cases in the world
	
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/
	SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- 10. Join with both data CovidDeaths and CovidVaccinations (location and date)

SELECT *
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- 11. Looking at Total Population vs Vaccinations
--NOTE: we can use "CAST(attributes name as int) or "CONVERT(int,attribute name)"  nvarchar when we use aggregate function

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- 12. USE CTE - to perform Calculation on "Partition By" in previous query
	
 WITH popvsVac (Continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated /population)*100
FROM popvsVac

-- 13. Creating Temporary table for PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated /population)*100
FROM #PercentPopulationVaccinated


-- 14. If we planning to do alteration we can add 
--NOTE: "DROP table if exists #PercentPopulationVaccinated"

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 

SELECT *, (RollingPeopleVaccinated /population)*100
FROM #PercentPopulationVaccinated

-- 15. create view to store data for later visualisation 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
