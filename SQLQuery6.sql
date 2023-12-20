SELECT * 
From covideaths
order by 3,4

--SELECT * 
--From vaccine
--order by 3,4

SELECT location, date, total_cases, new_cases, total_covideaths, population
From covideaths
order by 1,2

--looking at total cases vs total covideaths

SELECT location, date, total_cases, total_covideaths
From covideaths
where location like '%Africa%'
order by 1,2

--total cases vs percentage

SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 as popper
From covideaths
where location like '%China%'
order by 1,4 DESC

-- highest infection rates compared to population

SELECT location, population, max(total_cases) as highestinfection, max((total_cases/population))*100 as popper
From covideaths
--where location like '%China%'
Group by population,location
order by 3 DESC

--highest deathcount per population

SELECT location, max(cast(new_deaths as int)) as newdeaths
From covideaths
where continent='Africa'
Group by location
order by 2 DESC

--continent with higest newdeath count

SELECT continent, max(new_deaths)as higestdeaths
From covideaths
Group by continent
order by 2 DESC

--country with the highest new deaths

SELECT location, max(new_deaths)as higestdeaths
From covideaths
Group by location
order by 2 DESC


--sum of new_deats per day
SELECT date,location, sum(new_deaths)as dailydeaths
From covideaths
where continent is not null
Group by date, location
order by 3 DESC

--total vaccine vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
from covideaths dea
join vaccine vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations_smoothed is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
sum(vac.new_vaccinations_smoothed) over (partition by dea.location order by dea.location, dea.date) as rollingnewvax
from covideaths dea
join vaccine vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations_smoothed is not null
order by 1,2,3

--CTE


with popvsvax (continent, location, date, population, new_vaccinations_smoothed, rollingnewvax)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
sum(vac.new_vaccinations_smoothed) over (partition by dea.location order by dea.location, dea.date) as rollingnewvax
from covideaths dea
join vaccine vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations_smoothed is not null

)
Select *, (rollingnewvax/population)*100 as pers
from popvsvax


--TEMP Table

Drop table if exists #percpopulationvax
create table #percpopulationvax
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations_smoothed numeric,
rollingnewvax numeric
)
insert into #percpopulationvax
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
sum(vac.new_vaccinations_smoothed) over (partition by dea.location order by dea.location, dea.date) as rollingnewvax
from covideaths dea
join vaccine vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations_smoothed is not null

Select *, (rollingnewvax/population)*100 as pers
from #percpopulationvax


--create a view for visualization

create view percpopulationvax as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
sum(vac.new_vaccinations_smoothed) over (partition by dea.location order by dea.location, dea.date) as rollingnewvax
from covideaths dea
join vaccine vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations_smoothed is not null

