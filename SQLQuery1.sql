Select *
FROM [dbo].['owid-covid-data (1)$']
Order by 3,4
SELECT *
FROM [dbo].[CovidVaccinations]

--Selecting data that i will be working with.
SELECT location,date,population,total_cases,new_cases,total_deaths
FROM [dbo].['owid-covid-data (1)$']
order by 1,2


--Looking at a specific country,in this case KENYA
SELECT location,date,population,total_cases,new_cases,total_deaths
FROM [dbo].['owid-covid-data (1)$']
WHERE location like '%Kenya%'
order by 1,2


--Calculating the death percentage in Kenya based on total cases and total deaths.
--Cast function is use to convert the values in the specified column to a specified data type.
SELECT location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM [dbo].['owid-covid-data (1)$']
WHERE location like '%Kenya%'
order by 1,2


--Calcucating the percentage of the population that has contracted covid based on total cases and population
SELECT location,date,population,total_cases,(cast(total_cases as float)/cast(population as float))*100 as PopulationPercentage
FROM [dbo].['owid-covid-data (1)$']
WHERE location like '%Kenya%'
order by 1,2


--Looking at countries with Highest infection rate compared to population
SELECT location,population,Max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as percentagePopulationInfected
FROM [dbo].['owid-covid-data (1)$']
Group by location,population
order by percentagePopulationInfected desc


--Showing countries with highest death count per population
SELECT location,Max(cast(total_deaths as float)) as HighestDeathCount
FROM [dbo].['owid-covid-data (1)$']
where continent is not null
Group by location
order by HighestDeathCount desc


 --Breaking things down by continent
SELECT continent,Max(cast(total_deaths as float)) as HighestDeathCount
FROM [dbo].['owid-covid-data (1)$']
where continent is not null
Group by continent
order by HighestDeathCount desc

--GLOBAL NUMBERS
--Getting total cases total deaths and total death percentage in the whole continent.
SELECT SUM(new_cases) as totalcases,Sum(new_deaths) as totaldeaths,Sum(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM [dbo].['owid-covid-data (1)$']
Where continent is not null
Order by 1,2


--Joining the Covid deaths Table with the Covid Vaccinations table on basis of Location and Date
Select *
From [dbo].['owid-covid-data (1)$'] dea --Shortens the table name to dea
Join [dbo].[CovidVaccinations] vac --Shortens the table name to Vac
  on dea.location = vac.location 
  and dea.date = vac.date

  --Looking at Total Population VS Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From [dbo].['owid-covid-data (1)$'] dea --Shortens the table name to dea
Join [dbo].[CovidVaccinations] vac --Shortens the table name to Vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3

--Getting the Sum of new vaccinations in each location and rolling down the sum in a specified location at this instance Kenya
--Convert works the same as cast
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(Float,vac.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From [dbo].['owid-covid-data (1)$'] dea --Shortens the table name to dea
Join [dbo].[CovidVaccinations] vac --Shortens the table name to Vac
  on dea.location = vac.location 
  and dea.date = vac.date
  WHERE dea.location like '%Kenya%'
  --Where dea.continent is not null
order by 2,3


--Introducing a new column on the joined tables using a CTE
With PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(Float,vac.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From [dbo].['owid-covid-data (1)$'] dea --Shortens the table name to dea
Join [dbo].[CovidVaccinations] vac --Shortens the table name to Vac
  on dea.location = vac.location 
  and dea.date = vac.date
  --WHERE dea.location like '%Kenya%'
  --Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated --New column called Percentage Population Vaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(Float,vac.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From [dbo].['owid-covid-data (1)$'] dea --Shortens the table name to dea
Join [dbo].[CovidVaccinations] vac --Shortens the table name to Vac
  on dea.location = vac.location 
  and dea.date = vac.date
  WHERE dea.location like '%Kenya%'
  --Where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percentagerollingVacinated
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(Float,vac.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From [dbo].['owid-covid-data (1)$'] dea --Shortens the table name to dea
Join [dbo].[CovidVaccinations] vac --Shortens the table name to Vac
  on dea.location = vac.location 
  and dea.date = vac.date
  WHERE dea.location like '%Kenya%'
  --Where dea.continent is not null
--order by 2,3




