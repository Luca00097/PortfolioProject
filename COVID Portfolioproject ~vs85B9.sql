select *
from CovidDeaths$
order by 3,4

select *
from CovidVaccinations$
WHERE location = 'Canada'

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$

--Total cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from CovidDeaths$
where location like '%nigeria%'

--total cases vs population
Select location, MAX(total_cases) AS HighestInfection, population, MAX((total_cases/population))*100 AS PercentageInfected
from CovidDeaths$
--where location like '%nigeria%'
group by location, population
Order By PercentageInfected desc

--Death Count
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by location
Order By TotalDeathCount desc

--By Continent
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by continent
Order By TotalDeathCount Desc


-- Global numbers
Select date, SUM(new_cases), SUM(cast(new_deaths as int))
from CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--------------------------------
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2

--total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order By 2,3



--USE CTE
With popVsVac(continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3
)

Select*,(RollingPeopleVaccinated/population)*100
From popVsVac

--Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order By 2,3

Select*,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3






