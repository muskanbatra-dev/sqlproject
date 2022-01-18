
Select *
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where continent is not null
Order by 3,4


--Select *
--From [Portfolio Project]..['COVID VACCINATION HGE$'_xlnm#_FilterDatabase]
--Order by 3,4

Select location, date, total_cases , new_cases ,population
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where continent is not null
Order by 1,2

Select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where location like '%states%'
and continent is not null
Order by 1,2

Select location, date, total_cases , population, (total_cases/population)*100 as PercentPolpulationInfected
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where continent is not null
--Where location like '%states%'
Order by 1,2

Select location, MAX(total_cases) as HeighestInfectionCount , population, MAX((total_cases/population))*100 as HeighestInfectionCountPercentage
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where continent is not null
--Where location like '%states%'
Group by location, population
Order by 1,2

Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where continent is null
--Where location like '%states%'
Group by location
Order by TotalDeathCount desc

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['COVID DEATHS FINAL$']
Where continent is not null
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..['COVID DEATHS FINAL$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['COVID DEATHS FINAL$'] dea
Join [Portfolio Project]..['COVID VACCINATION HGE$'_xlnm#_FilterDatabase] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
SET ANSI_WARNINGS OFF

;With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['COVID DEATHS FINAL$'] dea
Join [Portfolio Project]..['COVID VACCINATION HGE$'_xlnm#_FilterDatabase] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


IF OBJECT_ID('tempdb...PercentPopulationVaccinated') is null
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['COVID DEATHS FINAL$'] dea
Join [Portfolio Project]..['COVID VACCINATION HGE$'_xlnm#_FilterDatabase] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




GO
Create View dbo.PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['COVID DEATHS FINAL$']dea
Join [Portfolio Project]..['COVID VACCINATION HGE$'_xlnm#_FilterDatabase] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 


	
