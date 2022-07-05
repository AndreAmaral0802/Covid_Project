Select *
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject_Covid..CovidVaccination
--Order by 3,4

--Select the datat that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
order by 1,2

-- Let's take a look into total cases vc total deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
and location like '%united kingdom%'
order by 1,2
-- The likelihood of dying of Covid19 in the UK as of 04/2021 is 2.89%


-- Total cases x Population 
Select Location, date, population, total_cases, (total_cases/population) * 100 as Total_Cases_by_Population
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
and location like '%united kingdom%'
order by 1,2
-- 6.5% of the UK population contracted Covid19 as of 04/2021

-- Countries with highest infection rate by population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as HighestPercentageInfection
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
Group by Location, population
-- Where location like '%united kingdom%'
order by HighestPercentageInfection desc
-- As of 04/2021 the UK ranked 39 in the Infection rate by population

-- Countries with the highest death count by population
Select Location, population, MAX(cast(Total_Deaths as int)) as TotalDeath_Count
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
Group by Location, population
-- Where location like '%united kingdom%'
order by TotalDeath_Count desc
-- As of 04/2021 the UK ranked 5 in total death only behind US, Brazil, Mexico, and India

-- BREAKING BY CONTINENT
-- Continents with the highest death count per population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeath_Count
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeath_Count desc

--- GLOBAL FIGURES
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
Group by date
order by 1,2
-- as of 04/2021 the % rate of death by new cases is 1.66

-- Total Cases x death rate worldwide
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- Looking at the VAccination Table
Select *
From PortfolioProject_Covid..CovidVaccination

-- Joining the tables 
Select *
From PortfolioProject_Covid..CovidDeaths death
Join PortfolioProject_Covid..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date

-- Looking at the Total Pop vs Vaccination 
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
From PortfolioProject_Covid..CovidDeaths death
Join PortfolioProject_Covid..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3

-- As per total amount of vaccination
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as Total_amount_of_Vacc
From PortfolioProject_Covid..CovidDeaths death
Join PortfolioProject_Covid..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3

-- Let's use the Common Table Expressions

With Pop_vs_Vaccination (continent, location, date, population, new_vaccinations, Total_amount_of_Vacc)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as Total_amount_of_Vacc
From PortfolioProject_Covid..CovidDeaths death
Join PortfolioProject_Covid..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
-- order by 2,3
)
Select *, (Total_amount_of_Vacc/population) * 100 as percentage_of_pop_vac
From Pop_vs_Vaccination 

-- TEMP TAble 

Drop Table if exists #PercentagePopVac
Create Table #PercentagePopVac
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Total_amount_of_Vacc numeric
)
insert into #PercentagePopVac
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as Total_amount_of_Vacc
From PortfolioProject_Covid..CovidDeaths death
Join PortfolioProject_Covid..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
-- order by 2,3

Select *, (Total_amount_of_Vacc/population) * 100 as percentage_of_pop_vac
From #PercentagePopVac 

-- Creating View to store data for later visualisation

Create View PercentagePopVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as Total_amount_of_Vacc
From PortfolioProject_Covid..CovidDeaths death
Join PortfolioProject_Covid..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
-- order by 2,3

Select *
From PercentagePopVaccinated

-- UK cases views 

Create View Percentage_of_UK_total_Cases as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
and location like '%united kingdom%'
--order by 1,2

Select *
From Percentage_of_UK_total_Cases

-- Global cases Views

Create View Global_Cases as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Where continent is not null
--Group by date
--order by 1,2

Select *
From Global_Cases