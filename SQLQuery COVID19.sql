
select * from portfolioproject..CovidDeaths
order by 3,4

--select * from portfolioproject..Covidvaccinations
--order by 3,4

select location ,date, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2

select location ,date, new_cases, total_deaths, population, total_cases_per_million
from portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc

select date, SUM(new_cases), SUM(cast(new_deaths as int)) as n_cases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases), SUM(cast(new_deaths as int)) as n_cases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select * from portfolioproject..Covidvaccinations

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 1,2,3
)
select*, (rollingpeoplevaccinated/population)*100
from popvsvac


--TEMP TABLE
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
sum (convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 --where dea.continent is not null
	 --order by 1,2,3

	 select*, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualisation

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 1,2,3

select * from percentpopulationvaccinated