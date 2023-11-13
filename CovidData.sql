SELECT * from Covid_Deaths
order by 3,4 

/* SELECT * from Covid_Vaccinations
order by 3,4 
 */
 --Select data that is going to be used
 SELECT location, date, total_cases, new_cases, total_deaths, population 
 from Covid_Data..Covid_Deaths
 order by 1,2

 --Looking at total_cases and total deaths in a country 
--shows the likelyhood dying if you attract covid in country
 SELECT location, date, total_cases, total_deaths, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from Covid_Data..Covid_Deaths
 where [location] like '%Pakistan'
 order by 1,2

 --looking at total cases vs population
--shows what percent of population got covid
 SELECT location, date,  population, total_cases,  (total_cases/population)*100 as CovidPercentage
 from Covid_Data..Covid_Deaths
 where [location] like '%Pakistan' 
 order by 1,2
 --what country have highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationInfected
from Covid_Data..Covid_Deaths
where continent is not NULL
GROUP BY [location],population
order by PopulationInfected DESC
--what country have highest DEATHS rate compared to population

SELECT location,  MAX(cast(total_deaths as int)) as HighestDeathsCount
from Covid_Data..Covid_Deaths
where continent is not NULL
GROUP BY [location]
order by HighestDeathsCount DESC

--checking by continent 
--showing continents with death counts
SELECT continent,  MAX(cast(total_deaths as int)) as HighestDeathsCount
from Covid_Data..Covid_Deaths
where continent is not NULL
GROUP BY [continent]
order by HighestDeathsCount DESC
 

--Globle numbers
SELECT date, SUM(cast(new_cases as int)) , SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as Total_Infection_Rate
from Covid_Data..Covid_Deaths
where continent is NULL
GROUP by [date]
order by 1,2


--looking at total population vs people vaccinated

SELECT DEA.continent , DEA.[location], DEA.[date], DEA.population, Covid_Data..Covid_Vaccinations.new_vaccinations,
SUM(CONVERT(float,Covid_Data..Covid_Vaccinations.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location,DEA.date) 
AS Rolling_People_Vaccinated

from Covid_Data..Covid_Vaccinations 
join  Covid_Data..Covid_Deaths DEA
on [DEA].[location] = Covid_Data..Covid_Vaccinations.location
and [DEA].[date] = Covid_Data..Covid_Vaccinations.date
where DEA.continent is NOT NULL

order by 1,2,3

--Use CTE

with PopvsVac(continent,location,date,population, new_vaccinations, Rolling_People_Vaccinated)
as (
SELECT DEA.continent , DEA.[location], DEA.[date], DEA.population, Covid_Data..Covid_Vaccinations.new_vaccinations,
SUM(CONVERT(float,Covid_Data..Covid_Vaccinations.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location,DEA.date) 
AS Rolling_People_Vaccinated

from Covid_Data..Covid_Deaths DEA
join  Covid_Data..Covid_Vaccinations  
on [DEA].[location] = Covid_Data..Covid_Vaccinations.location
and [DEA].[date] = Covid_Data..Covid_Vaccinations.date
where DEA.continent is NOT NULL

--order by 2,3
)
SELECT *, (Rolling_People_Vaccinated/population)*100 as Total_people_Vaccinated
from 
PopvsVac


--Temp Table
drop TABLE if exists #PercentPeopleVacc 
create TABLE #PercentPeopleVacc(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population numeric,
    new_vacc NUMERIC,
    Rolling_people_Vaccinated NUMERIC

)
INSERT into #PercentPeopleVacc
SELECT DEA.continent , DEA.[location], DEA.[date], DEA.population, Covid_Data..Covid_Vaccinations.new_vaccinations,
SUM(CONVERT(float,Covid_Data..Covid_Vaccinations.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location,DEA.date) 
AS Rolling_People_Vaccinated

from Covid_Data..Covid_Deaths DEA
join  Covid_Data..Covid_Vaccinations  
on [DEA].[location] = Covid_Data..Covid_Vaccinations.location
and [DEA].[date] = Covid_Data..Covid_Vaccinations.date
--where DEA.continent is NOT NULL 

SELECT *, (Rolling_People_Vaccinated/population)*100 as Total_people_Vaccinated
from 
#PercentPeopleVacc 

--creating view to store data for visualization

CREATE VIEW PercentPeopleVaccinated AS
SELECT DEA.continent , DEA.[location], DEA.[date], DEA.population, Covid_Data..Covid_Vaccinations.new_vaccinations,
SUM(CONVERT(float,Covid_Data..Covid_Vaccinations.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location,DEA.date) 
AS Rolling_People_Vaccinated

from Covid_Data..Covid_Deaths DEA
join  Covid_Data..Covid_Vaccinations  
on [DEA].[location] = Covid_Data..Covid_Vaccinations.location
and [DEA].[date] = Covid_Data..Covid_Vaccinations.date
--where DEA.continent is NOT NULL 