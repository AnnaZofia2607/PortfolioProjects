---Notes to do  -- Case it is if satament---
select top 10 * from CovidDeaths1;
Select top 10 * from CovidVaccinations1;

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths1;


select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100
from CovidDeaths1; 


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths1
where location like '%states%'
order by location,date;
---shows likelihood of dying if you contract covid in your country


Select location,date, total_cases,population,(total_cases/population)*100 as DeathLikelihhod
from CovidDeaths1
where  location in ('Poland','India')
order by location,date;

Select location,date, total_cases,population,(total_cases/population)*100 as DeathLikelihhod
from CovidDeaths1
where location like '%United king%' and Location ='Poland'; ----why does not like  Micheal 

---looking at total cases Vs Population 

Select location,date,population, total_cases,(total_cases/population)*100 as percantagePopulationInfected
from CovidDeaths1
where  location like '%states%'
order by location,date;

---looking at countries with highest infection rate compare to population 
Select location,population, max(total_cases) as highestInfectionCount,Max((total_cases/population))*100 as percantagePopulationInfected
from CovidDeaths1
--where  location like '%states%'
group by location, Population
order by highestInfectionCount desc;

Select location,population, max(total_cases) as highestInfectionCount,Max((total_cases/population))*100 as percantagePopulationInfected
from CovidDeaths1
--where  location = 'Poland'
group by location, Population
order by percantagePopulationInfected desc;

---Countries with highest Death count per population 
Select location, Max(Total_deaths)as TotalDeathCount
from CovidDeaths1
group by location
order by TotalDeathCount desc;


/*data type issue total_death. how the data type is read when u use aggregate function
need to be converted or/CAST from nvarchar to integer so that's read as a numeric 
*/

Select location, Max(Total_deaths)as TotalDeathCount
from CovidDeaths1
group by location
order by TotalDeathCount desc
-----CAST --
----So we have world , Asia , all contines in our responds 
Select location, Max(cast(Total_deaths as int))as TotalDeathCount
from CovidDeaths1
--where  location = 'Poland'
group by location
order by TotalDeathCount desc
--- we need to add not null to eliminate continents 
Select location, Max(cast(Total_deaths as int))as TotalDeathCount
from CovidDeaths1
--where  location = 'Poland'
where continent is not null
group by location
order by TotalDeathCount desc --- it shows all locations per country 

--let's break things down by continent 

Select continent, Max(cast(Total_deaths as int))as TotalDeathCount
from CovidDeaths1
--where  location = 'Poland'
where continent is not null
group by continent
order by TotalDeathCount desc 


Select location, Max(cast(Total_deaths as int))as TotalDeathCount
from CovidDeaths1
--where  location = 'Poland'
where continent is null  ----now is NULLL  
group by location
order by TotalDeathCount desc 


---VIP Showing continents with the highest death count per population 

Select continent, Max(cast(Total_deaths as int))as TotalDeathCount
from CovidDeaths1
--where  location = 'Poland'
where continent is not null
group by continent
order by TotalDeathCount desc 

---global numbers 


SELECT 	date,total_cases, new_cases, total_deaths,
(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS death_to_case_percentage
FROM   CovidDeaths1
---where  location = 'Poland';
where continent is not null;



SELECT 	date,SUM(new_cases)as newcases---, new_cases, total_deaths,
--(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS death_to_case_percentage
FROM   CovidDeaths1
---where  location = 'Poland';
where continent is not null
group by date;

---cast again--- ASK  micheal why i can not put location ----
SELECT 	date,SUM(new_cases)as newcases, sum(cast(new_deaths as int))as newdeaths ---, new_cases, total_deaths,
--(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS death_to_case_percentage
FROM   CovidDeaths1
---where  location = 'Poland';
where continent is not null
group by date;


SELECT 	date, SUM(new_cases)as newcases, sum(cast(new_deaths as int))as Newdeaths,
sum(cast(new_deaths as int)) / nullif (sum(new_cases),0) *100 as DeathPercentage 
FROM   CovidDeaths1
---where  location = 'Poland';
where continent is not null
group by date; 

Select count(*) from CovidVaccinations1---409771

select top 10 * from CovidDeaths1;
Select top 10 * from CovidVaccinations1;


---loking as total population vs Vaccinations
select dea.location,dea.date,dea.population,vac.new_vaccinations
from CovidDeaths1 dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by dea.date,dea.population;


----:):) Windows function part 1 
select dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location)
from CovidDeaths1 dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by dea.location,dea.date;

----:):) Windows function part 2

select dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
from CovidDeaths1 dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by dea.location,dea.date;

SELECT  dea.location,dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVacc
 --, (RollingPeopleVacc/population)*100--look at total population versus vacinations 
 --YOU CAN NOT use column that you just created to the next one query/line so we need to create CTE or temp table>> next query 
FROM  CovidDeaths1 dea
JOIN  CovidVaccinations1 vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;
    
/*USE CTE total population vs vacinations RollingPeopleVacc use the 
max number people ( ex albania) and divide by the population to know how many people  in that country
are vaccinated (popvsvac population versus vaccination)*/

With popvsvac (Continent,location,date,population,new_Vaccinations,RollingPeopleVacc)---this same column needs to be in select statment 
as 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,-----this same amount of columns 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVacc 
FROM  CovidDeaths1 dea
JOIN  CovidVaccinations1 vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY dea.location, dea.date
)
Select *
from popvsvac;


With popvsvac (Continent,location,date,population,new_Vaccinations,RollingPeopleVacc)---this same column needs to be in select statment 
as 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,-----this same amount of columns 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVacc 
FROM  CovidDeaths1 dea
JOIN  CovidVaccinations1 vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY dea.location, dea.date
)
Select *, (RollingPeopleVacc/population)*100
from popvsvac
-----i can create diffrent counts 

---Temp Table 
Drop table if exists #percentagePopulationVaccinated
Create Table #percentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
insert into #percentagePopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,-----this same amount of columns 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVacc 
FROM  CovidDeaths1 dea
JOIN  CovidVaccinations1 vac ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
---ORDER BY dea.location, dea.date
Select *, (RollingPeopleVaccinated1/population)*100
from #percentagePopulationVaccinated

select * from #percentagePopulationVaccinated
select * from #percentagePopulationVaccinated1

----Creating view to store data for later visualization 

Create view percentagePopulationVaccinated as

SELECT  dea.location,dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVacc
 --, (RollingPeopleVacc/population)*100--look at total population versus vacinations 
 --YOU CAN NOT use column that you just created to the next one query/line so we need to create CTE or temp table>> next query 
FROM  CovidDeaths1 dea
JOIN  CovidVaccinations1 vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, dea.date;

select * from percentagePopulationVaccinated;


