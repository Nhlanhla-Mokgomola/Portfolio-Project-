--- The data used was collected from https://ourworldindata.org/covid-deaths
SELECT * FROM portfolio_project.covidnew_death;
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
 From portfolio_project.covidnew_death; 

 
 -- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covidenew_death
Where continent is not null 
order by 1,2; 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
From covidenew_death
Where location = 'South Africa'
and continent is not null 
ORDER BY DeathPercentage DESC ; 

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in South Africa 

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covidenew_death
Where location = 'South Africa'; 

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covidenew_death
WHERE location is not null
Group by Location, Population
order by PercentPopulationInfected desc; 

-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From covidenew_death
Where continent is not null 
Group by Location
order by TotalDeathCount desc; 

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths ) as TotalDeathCount
From covidenew_death
Where continent is not null 
Group by continent
order by TotalDeathCount desc; 

 -- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project.covidnew_death
where continent is not null
Group by date
ORDER by date;

Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project.covidnew_death
where continent is not null;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select * from covidvaccinations;

Select continent, location, covidenew_death.date, covidenew_death.population, new_vaccinations, SUM(new_vaccinations) OVER
 (Partition by location  ORDER BY location, covidenew_death.date) as PeopleVaccinated
From covidenew_death 
Join covidvaccinations
	On covidenew_death.population = covidvaccinations.population
    and covidenew_death.date = covidvaccinations.date
where covidenew_death.continent is not null
order by 2,3 ; 



--- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as
(
Select continent, location, covidenew_death.date, covidenew_death.population, new_vaccinations
, SUM(new_vaccinations) OVER (Partition by covidenew_death.Location Order by covidenew_death.location, covidenew_death.Date) as PeopleVaccinated
From covidenew_death
Join covidvaccinations 
	On covidenew_death.population = covidvaccinations.population
	and covidenew_death.date = covidvaccinations.date
where covidenew_death.continent is not null 
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac ; 

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists Percent_Population_Vaccinated;
CREATE TABLE Percent_Population_Vaccinated(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
); 

Insert into Percent_Population_Vaccinated
Select continent, location, covidenew_death.date, covidenew_death.population, new_vaccinations
, SUM(new_vaccinations) OVER (Partition by Location Order by location, covidenew_death.date) as PeopleVaccinated
From covidenew_death
Join covidvaccinations
	On covidenew_death.population = covidvaccinations.population
	and covidenew_death.date = covidvaccinations.date; 
Select *, (PeopleVaccinated/Population)*100
From Percent_Population_Vaccinated; 




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select continent, location, covidenew_death.date, covidenew_death.population, new_vaccinations, SUM(new_vaccinations) OVER
 (Partition by location  ORDER BY location, covidenew_death.date) as PeopleVaccinated
From covidenew_death 
Join covidvaccinations
	On covidenew_death.population = covidvaccinations.population
    and covidenew_death.date = covidvaccinations.date
where covidenew_death.continent is not null; 



