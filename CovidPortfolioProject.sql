select location,date, total_cases, new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--totatl cases vs total deaths
--showing likehood of dying after contracting Covid in Africa

select cast(total_deaths as total_deaths)

select location,date, total_cases,total_deaths,round((CAST(total_deaths as float)/total_cases)*100,4) as DeathPercentage
from CovidDeaths
where location = 'Africa'
order by 1,2

-- Total cases vs population

select location,date, total_cases,population,(total_cases/population)*100 as PercentOfPopulationInfected
from CovidDeaths
where location = 'Africa'
order by 1,2


select location, max(CAST(total_cases as float)) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PercentOfPopulationInfected
from CovidDeaths
group by location,population
order by PercentOfPopulationInfected desc

--Countries with highest death count

select location, max(CAST(total_deaths as float)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Break according to continent
select continent, max(CAST(total_deaths as float)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select sum(cast(new_cases as float)) as Total_New_Cases, sum(cast(new_deaths as float)) as Total_New_Deaths, sum(cast(new_deaths as float))/nullif(sum(cast(new_cases as float)),0)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

--Total Population VS Vaccibation
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) as RollingVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--USING CTE

with PopVsVac (continent,location,date,population,new_vaccinations,RollingVaccination)
as
(
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) as RollingVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingVaccination/population)*100 percentageVaccinated
from PopVsVac

--USING TEMP TABLE

drop table if exists #PercentPopulatiionVaccination
Create table #PercentPopulatiionVaccination
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccination numeric
)

insert into #PercentPopulatiionVaccination
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) as RollingVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingVaccination/population)*100 percentageVaccinated
from #PercentPopulatiionVaccination

--creating view


create view PercentPopulatiionVaccination as
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) as RollingVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
