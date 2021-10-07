--select * 
--from PortfolioProject..[covid-deaths]
--order by 3,4 

--select * 
--from PortfolioProject..[covid-Vaccinations]
--order by 3,4 

-- Select Data that we are going to be using

--select	location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..[covid-deaths]
--order by 1,2

-- Looking at total cases vs total death
-- shoiws likelihood of dying if you contract covid in your country
select	location, date, total_cases, total_deaths, (total_deaths / total_cases) *100 as DeatPercantege
from PortfolioProject..['CovidDeaths']
Where location Like '%states%'
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid
select	location, date, total_cases, population, (total_cases /population) *100 as Percentofpopulationinfected
from PortfolioProject..['CovidDeaths']
Where location Like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared population
Select	location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases /population)) *100 as Percentofpopulationinfected
from PortfolioProject..['CovidDeaths']
--Where location Like '%states%'
GROUP BY location, population
order by Percentofpopulationinfected desc

-- shwing countries with the highest death count per population
Select	location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..['CovidDeaths']
Where continent is not null
GROUP BY location
order by TotalDeathCount desc

-- lets break things donwn by continent
Select	continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..['CovidDeaths']
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- showing the continets with highest deaths count needs to be finish!!
Select	continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..['CovidDeaths']
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--global numbers 
Select	date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, (SUM(cast(new_deaths AS int)) / SUM(new_cases)) * 100 AS Deathpercentage
from PortfolioProject..['CovidDeaths']
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- looking at total population vs caccionation
WITH PopulationvsVaccination (continent, location, date, population, new_vaccinations, RolingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT * ,(RolingPeopleVaccinated/population) *100
FROM PopulationvsVaccination


-- temp table
DROP TABLE IF exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated

-- creating view to store data for later visualisation

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated