-- drop table if exists "CovidDeaths";
create table "covid_deaths"(
"iso_code" text,
"continent" text,
"location" text,
"date" date,
"population" numeric,
"total_cases" numeric,
"new_cases" numeric,
"new_cases_smoothed" numeric,
"total_deaths" numeric,
"new_deaths" numeric,
"new_deaths_smoothed" numeric,
"total_cases_per_million" numeric,
"new_cases_per_million" numeric,
"new_cases_smoothed_per_million" numeric,
"total_deaths_per_million" numeric,
"new_deaths_per_million" numeric,
"new_deaths_smoothed_per_million" numeric,
"reproduction_rate" numeric,
"icu_patients" numeric,
"icu_patients_per_million" numeric,
"hosp_patients" numeric,
"hosp_patients_per_million" numeric,
"weekly_icu_admissions" numeric,
"weekly_icu_admissions_per_million" numeric,
"weekly_hosp_admissions" numeric,
"weekly_hosp_admissions_per_million" numeric
);
drop table if exists "CovidVaccine";
create table "covid_vaccine"(
"iso_code" text,
"continent" text,
"location" text,
"date" date,
"new_tests" numeric,
"total_tests" numeric,
"total_tests_per_thousand" numeric,
"new_tests_per_thousand" numeric,
"new_tests_smoothed" numeric,
"new_tests_smoothed_per_thousand" numeric,
"positive_rate" numeric,
"tests_per_case" numeric,
"tests_units" text,
"total_vaccinations" numeric,
"people_vaccinated" numeric,
"people_fully_vaccinated" numeric,
"new_vaccinations" numeric,
"new_vaccinations_smoothed" numeric,
"total_vaccinations_per_hundred" numeric,
"people_vaccinated_per_hundred" numeric,
"people_fully_vaccinated_per_hundred" numeric,
"new_vaccinations_smoothed_per_million" numeric,
"stringency_index" numeric,
"population_density" numeric,
"median_age" numeric,
"aged_65_older" numeric,
"aged_70_older" numeric,
"gdp_per_capita" numeric,
"extreme_poverty" numeric,
"cardiovasc_death_rate" numeric,
"diabetes_prevalence" numeric,
"female_smokers" numeric,
"male_smokers" numeric,
"handwashing_facilities" numeric,
"hospital_beds_per_thousand" numeric,
"life_expectancy" numeric,
"human_development_index" numeric

);
select *
from covid_vaccine
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths;

-- 1.looking at total cases vs total deaths
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,3) as death_percent
from covid_deaths
where location in ('Nigeria');

-- total cases vs population
select location, date, population, total_cases, round((total_cases/population)*100,3) as percent
from covid_deaths
where location in ('Nigeria');

-- what country with highest infection rate compared to population
select location, date, population, max(total_cases) as HighestInfectionCount , round(max((total_cases/population))*100,3) as PercentPopulationInfected
from covid_deaths
-- where location in ('Nigeria')
group by location, date, population
order by PercentPopulationInfected desc NULLS last;

-- what countries with the highest perc death count per pop
select location, population, max(total_deaths) as total_deaths, round(max(total_deaths/population)*100,3) as PopulationPercentDeath
from covid_deaths
-- where location in ('Nigeria')
group by location, population
order by PopulationPercentDeath desc NULLS last;

-- what countries with the highest death count per pop
select location, max(total_deaths) as total_deaths
from covid_deaths
-- where location in ('Nigeria')
where continent is not null
group by location, population
order by total_deaths desc NULLS last;

-- continent with highest death count
select location, max(total_deaths) as total_deaths
from covid_deaths
-- where location in ('Nigeria')
where continent is null and location not in ('International','World','European Union')
group by location
order by total_deaths desc;

-- global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercent
from covid_deaths
where continent is not null
-- group by date
order by 1,2;

-- looking at total population vs vaccination
with PopvsVac as
(select de.continent, de.location, de.date, de.population, va.new_vaccinations
		,sum(new_vaccinations) over (partition by de.location order by de.location, de.date)
		as RollingCount
 from covid_deaths de
join covid_vaccine va
	on de.location = va.location and
		de.date =va.date
where de.continent is not null
group by de.continent, de.location, de.date, de.population,va.new_vaccinations
order by 2,3)
select continent, location, date, population, new_vaccinations
		,RollingCount, RollingCount/Population *100
from PopvsVac
group by continent, location, date, population, new_vaccinations
		,RollingCount
order by 2,3