
SELECT *
FROM protofolio_project.coviddeaths
WHERE continent <> ''
ORDER BY 3, 4;


-- select the data that we will be using

select location,date,total_cases,new_cases,total_deaths,population
from protofolio_project.coviddeaths
order by 1,2 

-- looking at the total cases vs the total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
location,
date,
total_cases,
total_deaths, 
(total_deaths/total_cases) *100 AS Death_percentage
FROM protofolio_project.coviddeaths
WHERE location like '%Rwanda%'
ORDER BY 1,2 

-- Total Cases vs Population
-- Shows what percentage of the total population got infected by Covid

SELECT 
location,
date,
total_cases,
population,
(total_cases/population) *100 AS Case_population_percentage
FROM protofolio_project.coviddeaths
WHERE location like '%Rwanda%'
ORDER BY 1,2 

-- Countries with Highest Infection Rate compared to Population

SELECT location,
 population, 
 MAX(total_cases) AS Highest_infection_count, 
 MAX(total_cases/population) *100 AS Percentage_population_infected
FROM protofolio_project.coviddeaths
GROUP BY location, population
ORDER BY Percentage_population_infected DESC

-- Countries with Highest Death Count

Select Location, MAX(cast(Total_deaths AS SIGNED)) as TotalDeathCount
From protofolio_project.coviddeaths
WHERE continent <> ''
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT 
-- Showing contintents with the highest death

SELECT continent, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount_percontinent
FROM protofolio_project.coviddeaths
WHERE continent <> '' 
GROUP BY continent
ORDER BY TotalDeathCount_percontinent DESC;

-- Join the table of coviddeaths and covidvaccination

SELECT *
FROM protofolio_project.coviddeaths AS Deaths
JOIN protofolio_project.covidvaccinations AS Vaccinations
ON
Deaths.location = Vaccinations.location
AND
Deaths.date = Vaccinations.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
Deaths.continent, 
Deaths.location, 
Deaths.date, 
Deaths.population,
Vaccinations.new_vaccinations,
SUM(CONVERT(Vaccinations.new_vaccinations, SIGNED))
 OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) 
 AS RollingPeopleVaccinated
FROM protofolio_project.CovidDeaths Deaths
JOIN protofolio_project.CovidVaccinations Vaccinations
    ON Deaths.location = Vaccinations.location
    AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
Deaths.continent, 
Deaths.location, 
Deaths.date, 
Deaths.population,
Vaccinations.new_vaccinations,
SUM(CONVERT(Vaccinations.new_vaccinations, SIGNED)) 
OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingPeopleVaccinated
FROM protofolio_project.CovidDeaths Deaths
JOIN protofolio_project.CovidVaccinations Vaccinations
    ON Deaths.location = Vaccinations.location
    AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

 --Creating views for visualisation later
 
CREATE VIEW Continent_with_the_highest_deaths
AS
SELECT continent, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount_percontinent
FROM protofolio_project.coviddeaths
WHERE continent <> '' 
GROUP BY continent
ORDER BY TotalDeathCount_percontinent DESC;

CREATE VIEW Percentage_infected_EAC
AS
SELECT 
    location,
    date,
    total_cases,
    total_deaths, 
    (total_deaths / total_cases) * 100 AS Death_percentage
FROM 
    protofolio_project.coviddeaths
WHERE 
    location LIKE '%Rwanda%'
    OR location LIKE '%Kenya%'
    OR location LIKE '%Uganda%'
     OR location LIKE '%Tanzania%'
      OR location LIKE '%Burundi%'
       OR location LIKE '%South Sudan%'
        OR location LIKE '%Somalia%'
ORDER BY 
    3, 4; DESC
    
 CREATE VIEW Total_death_percountry
 AS
    Select Location, MAX(cast(Total_deaths AS SIGNED)) as TotalDeathCount
From protofolio_project.coviddeaths
WHERE continent <> ''
Group by Location
order by TotalDeathCount desc


CREATE VIEW Max_cases_Europe
AS
SELECT location, MAX(total_cases) AS Maximum_CaseCount
FROM coviddeaths
WHERE continent = 'Europe'
GROUP BY location
ORDER BY Maximum_CaseCount DESC