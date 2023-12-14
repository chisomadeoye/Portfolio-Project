select *
From SQLPortfolio..CovidDeaths
where continent is not null
order by 3,4

select *
From SQLPortfolio..CovidVaccinations
order by 3,4
----------------------------------------------------------------------
--- Select the Data we're going to be using

select Location, date, total_cases, new_cases, total_deaths, population
From SQLPortfolio..CovidDeaths
where continent is not null
order by 1,2

 -------------------------------------------------------------------------
---Looking at Total Cases vs Total Deaths
 --Shows liklihood of dying if you contact covid 

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From SQLPortfolio..CovidDeaths
where continent is not null
order by 1,2

-------------------------------------------------------------------------------------
 ----Showing the liklihood of dying if you got COVID in Canada

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From SQLPortfolio..CovidDeaths
where location = 'Canada'
order by 1,2
 
-----------------------------------------------------------------------------------------
----Looking at Total Cases vs Population
----Shows what percentage of population got COVID

select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From SQLPortfolio..CovidDeaths
order by 1,2

-------------------------------------------------------------------------------------
---- Looking at countries with the highest infection rates compared to the Population

select Location, MAX(total_cases) as HighetInfectionCount, Population, MAX((total_cases/population))*100 as InfectionPercentage
From SQLPortfolio..CovidDeaths
where continent is not null
GROUP BY location, population
order by InfectionPercentage desc

 -------------------------------------------------------------------------------------
----Looking at countries with the highest death count per population

select Location, MAX(cast(total_deaths as int)) as TotalDeaths 
From SQLPortfolio..CovidDeaths
where continent is not null
GROUP BY location
order by TotalDeaths desc

-------------------------------------------------------------------------------------
------Looking at the continents with the highest death counts

select continent, MAX(cast(total_deaths as int)) as TotalDeaths 
From SQLPortfolio..CovidDeaths
where continent is not null
GROUP BY continent
order by TotalDeaths desc


-------------------------------------------------------------------------------------
-----Looking at continents with the highest infection rates compared to the population
select Location, MAX(total_cases) as HighetInfectionCount, Population, MAX((total_cases/population))*100 as InfectionPercentage
From SQLPortfolio..CovidDeaths
where continent is null
GROUP BY location, population
order by InfectionPercentage desc



-------------------------------------------------------------------------------------
----Looking at Global Numbers by date

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  Sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From SQLPortfolio..CovidDeaths
where continent is not null 
group by date
order by 1,2

-------------------------------------------------------------------------------------
---------Looking at total Global Numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  Sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From SQLPortfolio..CovidDeaths
where continent is not null 
order by 1,2

-------------------------------------------------------------------------------------
--------------Working with CovidVacciantions Data
 
Select *
From SQLPortfolio..CovidVaccinations

-------------------------------------------------------------------------------------
--------------- Joining CovidDeaths and Covidvaccinations Data

Select *
From SQLPortfolio..CovidDeaths dea
Join SQLPortfolio..CovidVaccinations vac
on dea.location =  vac.location
and dea.date = vac.date


-------------------------------------------------------------------------------------
------Looking at how many people on the world have been vaccinated


Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, sum (cast(vac.new_vaccinations AS INT)) over (partition by dea.location order by dea.location, dea.date) as NumberOfVaccinations
From SQLPortfolio..CovidDeaths dea
Join SQLPortfolio..CovidVaccinations vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,3


 -------------------------------------------------------------------------------------
------------Total Population vs Vaccinations
---------Shows Percentage of Population that recieved at least one dose of vaccine

With PopvsVac (Continent, Location, Date, population, new_vaccinations, NumberOfVaccinations)
as
(
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
sum (cast(vac.new_vaccinations AS INT)) over (partition by dea.location order by dea.location, dea.date) as NumberOfVaccinations
From SQLPortfolio..CovidDeaths dea
Join SQLPortfolio..CovidVaccinations vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (NumberOfVaccinations/population)
from PopvsVac

-------------------------------------------------------------------------------------

----Creating View to Store data for later visualization
 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPortfolio..CovidDeaths dea
Join SQLPortfolio..CovidVaccinations vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
