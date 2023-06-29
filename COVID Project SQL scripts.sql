Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs. Total Deaths: Likelihood of dying if you contract covid in your country

Alter Table [dbo].[CovidDeaths] 
Alter Column total_cases float		-- Was stored as nvarchar - needed float to perform division 

Alter Table [dbo].[CovidDeaths]
Alter Column total_deaths float		-- Was stored as nvarchar - needed float to perform division 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2


-- Total Cases vs. Population: Percentage of population that got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopInfection
From PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfection
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Group by location, population
order by PercentPopInfection desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Broken down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers


Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by date
order by 1,2

-- Total Population vs. Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- View for Visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
