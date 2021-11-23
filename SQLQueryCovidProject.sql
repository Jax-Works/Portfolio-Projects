Select *
From CovidProject..CovidDeath
order by 3,4

--Select *
--From CovidProject..CovidVac
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeath
order by 1,2

--Total Cases (1)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeath
--Where location like 'Singapore'
where continent is not null 
--Group By date
order by 1,2

--Total Cases VS Total Death - Shows likelihood of dying if contracted covid in SG
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeath
--Where location like 'Singapore'
Where continent is not null
order by 1,2

--Total Cases VS Population - Shows percentage of population that got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From CovidProject..CovidDeath
Where location like 'Singapore'
order by 1,2

--Looking at countries with highest infection rate compared to population (3)
Select Location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopInfected
From CovidProject..CovidDeath
--Where location like 'Singapore'
Group by Location, population
order by PercentagePopInfected desc

--Looking at countries with highest infection rate compared to population over time (4)
Select Location, population, date, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopInfected
From CovidProject..CovidDeath
--Where location like 'Singapore'
Group by Location, population, date
order by PercentagePopInfected desc

--Looking at countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeath
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Splitting by continent with highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeath
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Total Death Counts by Continent (2)
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeath
--Where location like '%Singapore%'
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeath
--Where location like 'Singapore'
Where continent is not null
Group by date
order by 1,2

--Using CTE
With PopvsVax (Continent, Location, Date, Population, New_Vax, RunningVax)
as
(
--Looking at Total population VS Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVax
From CovidProject..CovidDeath dea
Join CovidProject..CovidVac vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
Select *, (RunningVax/Population)*100 as VaxPercentage
From PopvsVax
order by 1,2,3

--Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vax numeric,
RunningVax numeric
)

Insert into #PercentPopulationVaccinated
--Looking at Total population VS Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVax
From CovidProject..CovidDeath dea
Join CovidProject..CovidVac vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select *, (RunningVax/Population)*100 as VaxPercentage
From #PercentPopulationVaccinated
order by 1,2,3

--Creating View to store data for later visualizations
Create View [dbo].[PercentPopulationVaccinated] as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVax
From CovidProject..CovidDeath dea
Join CovidProject..CovidVac vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated