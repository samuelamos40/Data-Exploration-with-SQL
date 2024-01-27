select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Datas we will be using 

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total death

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentagePerDeath
from CovidDeaths
where location = 'Nigeria' and continent is not null
order by 1,2

--TOTAL CASES VS POPULATION

select location, date, total_cases, population, (total_cases/population)*100 as percentagePerpopulation
from CovidDeaths
where location = 'Nigeria' and continent is not null
order by 1,2

--countries with highest infection rate per population
select location, population, max(total_cases) as HighestPopulation, max((total_cases/population))*100 as percentagePerpopulation
from CovidDeaths
--where location = 'Nigeria'
where continent is not null
group by location, population
order by percentagePerpopulation desc

--countries with highest death count per population

select location, max(cast (total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location = 'Nigeria'
where continent is not null
group by location
order by totaldeathcount desc

--BREAKDOWN BY CONTINENT

select continent, max(cast (total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location = 'Nigeria'
where continent is not null
group by continent
order by totaldeathcount desc

--GLOBAL NUMBER

select date, sum(new_cases) as SumNewCases, sum(cast(new_deaths as int)) as SumNewDeath, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from covidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as SumNewCases, sum(cast(new_deaths as int)) as SumNewDeath, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from covidDeaths
where continent is not null
--group by date
order by 1,2

--TOTAL VACCINATION VS TOTAL POPULATION

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location  = 'Albania'
order by 2,3

--USING CTE

with PopVsVac (continent, location, date, population, new_vaccination, RollingPopulation)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPopulation/population) * 100
from PopVsVac


--USING TEMP TABLE

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population) * 100
from #PercentagePopulationVaccinated


--CREATE VIEW

create view PercentagePopulationVaccinated as


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated