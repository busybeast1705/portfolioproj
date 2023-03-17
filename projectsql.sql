select *
from coviddeath
order by 3,4

select *
from covidvacc
order by 3,4

--selecting data which we will use

select location, date, total_cases,new_cases,total_deaths, population
from coviddeath
order by 1,2
--altering the column datatype
alter table coviddeath
alter column total_deaths float
alter table coviddeath
alter column total_cases float

--total cases vs total deaths
--shows the likelihood of dying if you have covid in your country
select location,date,(total_cases ),(total_deaths ), total_deaths/total_cases*100 as totaldeathperc
from coviddeath
where continent is not null
and location like '%india%'
order by 1,2

--looking at total cases vs population
--percentage of population getting covid in india
select location,date,population,(total_cases ), total_cases/population*100 
from coviddeath
where continent is not null
and location like '%india%'
order by 1,2



--countries with highest infection rate in comparision to its population
select location,population,max(total_cases )as highsestinfcount,max(total_cases/population*100) as percentpopinf
from coviddeath
where continent is not null
--and location like '%india%'
group by population, location
order by percentpopinf desc

--mortality rate of all the countries

select location,population,max(total_deaths )as highsestdeathcnt
from coviddeath
where continent is not null
--and location like '%india%'
group by population, location
order by highsestdeathcnt desc

--data according to the continents

select location,max(total_deaths )as highsestdeathcnt
from coviddeath
where continent is  null
--and location like '%india%'
group by location
order by highsestdeathcnt desc

select continent,max(total_deaths )as highsestdeathcnt
from coviddeath
where continent is not null
--and location like '%india%'
group by continent
order by highsestdeathcnt desc


--continents and income groups with highest death count per population

select continent,max(total_deaths )as highsestdeathcnt
from coviddeath
where continent is not null
--and location like '%india%'
group by continent
order by highsestdeathcnt desc


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From coviddeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--global number as total cases and deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Coviddeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--total deaths per date using nullif function
select date, sum(new_deaths) as ndeath, sum(new_cases) as ncases, nullif(sum(new_deaths),0)/sum(new_cases) as deathperc
from coviddeath
where continent is not null
group by date
order by 1,2


--total death per date using case statements
select date, sum(new_deaths) as ndeath, sum(new_cases) as ncases, 
case
when sum(new_cases)= '0'
then null
else
sum(new_deaths)/sum(new_cases) *100
end
as deathperc
from coviddeath
where continent is not null
group by date
order by 1,2


--looking at population and total vaccinations
select dea.location,dea.date,dea.continent,dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacc
from covidvacc as vacc
join coviddeath as dea
on dea.location= vacc.location
and dea.date= vacc.date
where dea.continent is not null
and dea.location like '%canada%'
order by 2,3

--using CTEs

with CTE_popvsvacc as 
(select dea.location,dea.date,dea.continent,dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacc
from covidvacc as vacc
join coviddeath as dea
on dea.location= vacc.location
and dea.date= vacc.date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3
)
select *, (rollingpeoplevacc/population)*100
from CTE_popvsvacc


--with temp tables
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeath dea
Join covidvacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view for later visualisations

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeath dea
Join covidvacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

