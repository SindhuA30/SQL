select*
from portfolioproject..coviddeaths
where continent is not null
order by 3,4

select*
from portfolioproject..covidvaccinations
order by 3,4

--Select Data that we are going to be using

select location,date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location,date, total_cases, total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2

--Looking at total case vs population
--shows what percentage of population got covid

select location,date, Population,total_cases,  (total_cases/Population)*100 as DeathPercentage
from portfolioproject..coviddeaths
--where location like '%states%'
order by 1,2


--Looking at Countries with highest infection rate compared to population

select location, Population,MAX(total_cases) as HighestInfectionCount,  Max(total_cases/Population)*100 as PercentPopulationInfected
from portfolioproject..coviddeaths
--where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


--let's break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

--USE CTE
with PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 from popvsvac


--TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)




Insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated

--creating view to store data for later visualization


create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null


select * from percentpopulationvaccinated



