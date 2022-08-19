/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject_1..Coviddeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_1..Coviddeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country (This example uses the USA)

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From PortfolioProject_1..Coviddeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population is infected with Covid by Country and by Day

Select Location, date, Population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject_1..Coviddeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as InfectionCount,  Max((total_cases/population))*100 as InfectionRate
From PortfolioProject_1..Coviddeaths
Group by Location, Population
order by InfectionRate desc


-- Countries with Highest death Count per Population

Select Location, MAX(cast(Total_deaths as float)) as TotaldeathCount
From PortfolioProject_1..Coviddeaths
Where continent is not null 
Group by Location
order by TotaldeathCount desc



-- Continents with Highest death Count per Population

Select continent, MAX(cast(Total_deaths as float)) as TotaldeathCount
From PortfolioProject_1..Coviddeaths
Where continent is not null 
Group by continent
order by TotaldeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as deathPercentage
From PortfolioProject_1..Coviddeaths
where continent is not null 
order by 1,2



-- Total Population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid vaccine

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinecinated
--, (RollingPeoplevaccinecinated/population)*100 (Cannot use column that was just created)
From PortfolioProject_1..Coviddeaths death
Join PortfolioProject_1..Covidvaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3


-- Using CTE/WITH query to perform Calculation on Partition By in previous query

With PopVsVaccine (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeoplevaccinecinated
From PortfolioProject_1..Coviddeaths death
Join PortfolioProject_1..Covidvaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVaccine




-- Creating View to store data for later visualizations in Tableau

Create VIEW PopVsVaccine as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinecinated/population)*100
From PortfolioProject_1..Coviddeaths death
Join PortfolioProject_1..Covidvaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 