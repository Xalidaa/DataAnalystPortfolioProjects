/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * from covid_deaths 
where continent is not null
order by 3,4;


--Select data that we are going to be using

select location, continent,date,total_cases,new_cases,total_deaths,population 
from covid_deaths
where continent is not null
order by 1,2;


--Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percent
from covid_deaths
where location = 'Azerbaijan' and continent is not null
order by 1,2;


--Total cases vs Population
--what percentage of population got infected with covid

select location,date,population,total_cases, (total_cases/population)*100 as infected_percent
from covid_deaths
where location = 'Azerbaijan'
order by 1,2;


--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_infection_count,
max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
group by location, population
order by PercentPopulationInfected desc;


--showing countries with the highest death count per population

select location, max(cast (total_deaths as int)) as highest_death_count
from covid_deaths
where continent is not null
group by location
order by highest_death_count desc;


--showing continents with highest death count per population

select continent, max(cast (total_deaths as int)) as highest_death_count
from covid_deaths
where continent is not null
group by continent
order by highest_death_count desc;


--global numbers

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percent
from covid_deaths
--where location = 'Azerbaijan'
where continent is not null
--group by date
order by 1,2;


select * from covid_vaccinations;

--looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


--using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
--order by 2,3;
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;


--using Temp Table to perform Calculation on Partition By in previous query

drop table if exists PercentPopulationVaccinated;
create temp table PercentPopulationVaccinated
(
Continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
--order by 2,3;
;
select *,(RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null;
--order by 2,3;

select * from PercentPopulationVaccinated;