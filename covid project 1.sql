/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT * FROM Project..Covid_Vaccination
Where continent is not null
Order by 3,4


-- Select Data that we are going to be starting with --



SELECT Location,date, total_cases, new_cases, total_deaths, population
from Project..Covid_Deaths
Order by 1,2




-- Total Cases vs Total Deaths --
-- Shows likelihood of dying if you contract covid in your country --


SELECT Location, date, total_cases, total_deaths, 
       (CONVERT(FLOAT, total_deaths) / CONVERT(FLOAT, total_cases)) * 100 AS death_rate
FROM Project..Covid_Deaths
where location like '%states%'
and continent is not null 
ORDER BY Location, date;




-- Total Cases vs Population --
-- Shows what percentage of population infected with Covid --


SELECT Location, date, population, total_cases, 
       (CONVERT(FLOAT, total_cases) / CONVERT(FLOAT, population)) * 100 AS PercentPopulationInfected
FROM Project..Covid_Deaths
--where location like '%states%'
ORDER BY Location, date;




-- Looking at the country with highest infection rate compared to population --



SELECT 
    Location, 
    population, 
    MAX(total_cases) AS highest_infection_count, 
    (MAX(CONVERT(FLOAT, total_cases)) / MAX(CONVERT(FLOAT, population))) * 100 AS PercentPopulationInfected
FROM Project..Covid_Deaths
--Where location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population --


SELECT 
    continent, 
    Max(cast(Total_deaths as int)) as TotalDeathCount
FROM Project..Covid_Deaths
--Where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC





-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT 
    continent,Max(cast(Total_deaths as int)) as TotalDeathCount
FROM Project..Covid_Deaths
--Where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC





---    Global Numbers     ---



SELECT  
    SUM(new_cases) AS TotalNewCases, 
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, 
    CASE 
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INT)) * 100.0) / SUM(CAST(new_cases AS INT))
    END AS DeathRate
FROM Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;



-- Looking at Total Population vs Vaccinations --



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Covid_Deaths dea
Join Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Covid_Deaths dea
Join Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project..Covid_Deaths dea
Join Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




















