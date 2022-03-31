--COVID DEATHS
select * 
from portfolio_project..Covid_Deaths
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, population
from portfolio_project..Covid_Deaths
order by 1, 2

--looking at total cases vs total deaths
--Shows likelihood of dying if your contract covid in your country.

Select location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS Deaths_Percentage
From portfolio_project..Covid_Deaths
Where location like '%states%'
order by 1, 2

--Looking at total cases vs population
--Shows what percentage of population got Covid

Select location, date,  population, total_cases, ((total_cases/population) * 100) AS population_Percentage
From portfolio_project..Covid_Deaths
Where location like '%states%'
order by 1, 2

--Looking at countries with highest infection rate compares to population

Select location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population) * 100) AS population_Percentage
From portfolio_project..Covid_Deaths
--Where location like '%states%'
group by location population
order by 4 DESC

--Showing country with the highest death count per population

Select location, MAX(cast(total_deaths as int)) AS totalDeathCount
--, MAX((total_deaths/total_cases) * 100) AS Death_Percentage
From portfolio_project..Covid_Deaths
--Where location like '%states%'
where continent is not null
group by location
order by totalDeathCount DESC


--Showing the continents with highest death counts per population

Select continent, MAX(cast(total_deaths as int)) AS totalDeathCount
From portfolio_project..Covid_Deaths
--Where location like '%states%'
where continent is not null
group by continent
order by totalDeathCount DESC


--global numbers by date (jan-2020 to mar-2022)

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases) * 100) AS deathPercentage
From portfolio_project..Covid_Deaths
--Where location like '%states%'
where continent is not null
group by date
order by 1, 2 


--Total Global numbers of cases and total deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases) * 100) AS deathPercentage
From portfolio_project..Covid_Deaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1, 2


--COVID VACCINATIONS
select * 
from portfolio_project..Covid_Vaccinations
order by 3,4



--Joining tables and looking at the total population vs vaccination
-- USE CTE

with popvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
from portfolio_project..Covid_Deaths dea
join portfolio_project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, ((RollingPeopleVacinated/population) *100) AS percentage
from popvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio_project..Covid_Deaths dea
join portfolio_project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	
Select *, ((RollingPeopleVaccinated/population) *100) AS percentage
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio_project..Covid_Deaths dea
join portfolio_project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * 
from #PercentPopulationVaccinated
