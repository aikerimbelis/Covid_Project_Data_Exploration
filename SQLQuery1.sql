Select *
from [Portfolio Project]..COVIDDeaths
where continent is not null
order by 3, 4 

--Select *
--from [Portfolio Project]..COVIDVaccinations
--order by 3, 4 

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..COVIDDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
ALTER TABLE [dbo].[COVIDDeaths] ALTER COLUMN total_deaths decimal(18,2);
ALTER TABLE [dbo].[COVIDDeaths] ALTER COLUMN total_cases decimal(18,2);

--GLOBAL NUMBERS

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from [Portfolio Project]..COVIDDeaths
--where location like '%states%' 
where continent is not null
order by 1, 2

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from [Portfolio Project]..COVIDDeaths
--where location like '%states%' 
where continent is not null
order by 1, 2


--Looking at Total Cases vs population
--Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 AS cases_Percentage
from [Portfolio Project]..COVIDDeaths
where location like '%Kazakhstan%'
and continent is not null
order by
1, 2

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from [Portfolio Project]..COVIDDeaths
--where location like '%Kazakhstan%'
Group By location, population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per Population



--Let's BREAK THING DOWN BY CONTINENT 

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio Project]..COVIDDeaths
--where location like '%Kazakhstan%
where continent is null
Group By location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio Project]..COVIDDeaths
--where location like '%Kazakhstan%
where continent is not null
Group By continent
order by TotalDeathCount desc

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio Project]..COVIDDeaths
--where location like '%Kazakhstan%
where continent is not null
Group By location
order by TotalDeathCount desc

--Showing continents with the highest death count per population

--GLOBAL Numbers 
Select date, SUM(new_cases) as total_Cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(cast(new_cases as bigint))* 100 AS DeathPercentage
from [Portfolio Project]..COVIDDeaths
--where location like '%states%' 
where continent is not null
group by date
order by 1, 2


--Looking at Total Population vs Vaccination

--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated