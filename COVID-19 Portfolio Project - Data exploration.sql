--select *
--FROM PortfolioProject..CovidDeaths
--Where continent is not NULL
--Order 1,2


--select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--select data that we going to using
--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

--looking at Total Cases vs Total Deaths
--Shows that likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--looking at total Cases vs Population
--shows what percentage of population get Covid

SELECT location,date,Population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest infection Rate compared to Population

SELECT location,Population,MAX(total_cases)AS HighestInfectionCount, MAX((total_cases/population))*100 
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location,Population
ORDER BY PercentPopulationInfected desc

-- let's break things down by continent
Select location,MAX(cast(Total_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by location
Order by TotalDeathcount desc

--showing Countries with Highest Death Count per Population
--- we are using cast because there issue with data type for total_deaths in nvarchar when we use aggregate function

Select Location,MAX(cast(Total_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Location
Order by TotalDeathcount desc

--Global numbers

Select date,SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by date
Order by 1,2

--Total cases in the world
Select SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
--Group by date
Order by 1,2

--join with both data covidDeaths and CovidVaccination (location and date)

select *
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date

--looking at total population vs vaccinations
--NOTE: we can use "CAST(attributes name as int) or "CONVERT(int,attribute name)"  nvarchar when we use aggregate function

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE - to perform Calculation on Partition By in previous query
 with popvsVac (Continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated /population)*100
from popvsVac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null 

select *, (RollingPeopleVaccinated /population)*100
from #PercentPopulationVaccinated


--if planning to do alteration we can add 
--"DROP table if exists #PercentPopulationVaccinated"

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 

select *, (RollingPeopleVaccinated /population)*100
from #PercentPopulationVaccinated

--create view to store data for later visualisation 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

select *
FROM PercentPopulationVaccinated