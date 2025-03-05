select *
from portfolio_project_1..CovidDeaths
where continent is not null
order by 3, 4;


--select *
--from portfolio_project_1..CovidVaccinations
--order by 3, 4;

--select the data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from portfolio_project_1..CovidDeaths
where continent is not null
order by 1,2

-- order by 1,2 will order it by column 'location' and 'date' to keep things orderly and easier

--looking at total_cases vs total_deaths

select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage 
from portfolio_project_1..CovidDeaths
where continent is not null
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage 
from portfolio_project_1..CovidDeaths
where Location like '%states%'
and continent is not null
order by 1,2

--looking at what percent of pop has gotten covid

select Location, date, total_cases, population, (total_deaths / population)*100 as percent_of_pop_infected 
from portfolio_project_1..CovidDeaths
where continent is not null
--where Location like '%states%'
order by 1,2

--looking at countries w/ highest infect rate compared to pop
select Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases / population))*100 as percent_of_pop_infected
from portfolio_project_1..CovidDeaths
where continent is not null
--where Location like '%states%'
group by Location, Population
order by percent_of_pop_infected desc


--heighest death count per pop per country?
select Location, MAX(total_deaths) as total_death_count
from portfolio_project_1..CovidDeaths
where continent is not null
--where Location like '%states%'
group by Location
order by total_death_count desc

--gives error bc of data type. need to cast as int
select Location, MAX(cast(total_deaths as int)) as total_death_count
from portfolio_project_1..CovidDeaths
where continent is not null
group by Location
order by total_death_count desc

--breaking it down by continent
select continent, MAX(cast(total_deaths as int)) as total_death_count
from portfolio_project_1..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc


-- global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from portfolio_project_1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--JOINS 


select * 
from portfolio_project_1..CovidDeaths d
join portfolio_project_1..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date



--looking at total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER (partition by d.location order by d.location, 
d.date) as rolling_people_vaccinated
from portfolio_project_1..CovidDeaths d
join portfolio_project_1..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 1,2,3


--use cte

with PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (partition by d.location order by d.location, 
d.date) as rolling_people_vaccinated
from portfolio_project_1..CovidDeaths d
join portfolio_project_1..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)

select* , (rolling_people_vaccinated/population)*100 as percent_vaccinated
from PopvsVac
order by location


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (partition by d.location order by d.location, 
d.date) as rolling_people_vaccinated
from portfolio_project_1..CovidDeaths d
join portfolio_project_1..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null


select* , (rolling_people_vaccinated/population)*100 as percent_vaccinated
from #PercentPopulationVaccinated
order by location


--view to store data for later
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (partition by d.location order by d.location, 
d.date) as rolling_people_vaccinated
from portfolio_project_1..CovidDeaths d
join portfolio_project_1..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select*
from PercentPopulationVaccinated



-- for tablaue vis

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolio_project_1..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

select Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases / population))*100 as percent_of_pop_infected
from portfolio_project_1..CovidDeaths
where continent is not null
--where Location like '%states%'
group by Location, Population
order by percent_of_pop_infected desc

select Location, Population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases / population))*100 as percent_of_pop_infected
from portfolio_project_1..CovidDeaths
where continent is not null
--where Location like '%states%'
group by Location, Population, date
order by percent_of_pop_infected desc


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolio_project_1..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc