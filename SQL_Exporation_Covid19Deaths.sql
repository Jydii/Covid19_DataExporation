/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in United Kingdom

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like'%kingdom%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population infected with covid

select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
from PortfolioProject..CovidDeaths
where location like'%kingdom%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PopulationInfectedPercentage
from PortfolioProject..CovidDeaths
-- where location like'%kingdom'
where continent is not null
group by location, population
order by 4 desc

-- Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like'%kingdom'
where continent is not null 
-- and location like '%kingdom%'
group by location
order by 2 desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with Highest Death Count per Population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like'%kingdom'
where continent is not null 
-- and location like '%kingdom%'
group by continent
order by 2 desc

-- GLOBAL NUMBERS

select --date, 
sum(new_cases) as TotalCases, sum(cast (new_deaths as int)) as TotalDeaths,  
sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--and dea.location like '%kingdom%'
order by 2,3


-- using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--and dea.location like '%kingdom%'
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100 as PeopleVaccinatedPercent
from PopvsVac

-- using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--and dea.location like '%kingdom%'
--order by 2,3

select *, (RollingPeopleVaccinated/population) * 100 as PeopleVaccinatedPercent
from #percentpopulationvaccinated



-- Creating view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
and dea.location like '%kingdom%'
--order by 2,3

select *
from percentpopulationvaccinated