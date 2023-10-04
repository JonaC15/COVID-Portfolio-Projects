--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got COVID
Select Location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where location = 'United States'
order by 1,2

--Looking at Countries with Highest Infection rate compared to Population
Select Location, population, max(total_cases) as HighestInectionCount, 
(CONVERT(float,Max(total_cases))/NULLIF(CONVERT(float,Max(population)),0))*100 as PercentInfected
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by Location,population
order by PercentInfected desc

--Showing  countried with Highest Death count per population
Select Location, max(total_deaths) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by Location
order by TotalDeathcount desc

--Total Deaths by continent
select location, max(total_deaths) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death counts per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select date, sum(cast(new_cases as int)) as totalcases, sum(cast(new_deaths as int)) as totaldeath, 
Sum(cast(New_deaths as int)) / Sum(cast(new_Cases as int))*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--View COVID Vaccinations table
select *
from [Portfolio Project].dbo.CovidVaccinations

--Join COVID Deaths and COVID Vaccinations table
Select *
from [Portfolio Project].dbo.CovidDeaths DEA
join [Portfolio Project].dbo.CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths DEA
join [Portfolio Project].dbo.CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths DEA
join [Portfolio Project].dbo.CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths DEA
join [Portfolio Project].dbo.CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization
create view Percentpopulationvaccinatied as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths DEA
join [Portfolio Project].dbo.CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from Percentpopulationvaccinatied


