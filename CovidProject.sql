--SELECT location, date, total_cases, new_cases,total_deaths, population
--FROM PortfolioProject.dbo.CovidDeaths
-- WHERE continent is NOT NULL
--ORDER BY 1,2

-- Comparing Total cases to Total deaths
-- Shows the likelihood of dying if you contract covid in the united kingdom as at these dates
SELECT location, date, total_cases, total_deaths, 
		(total_deaths/total_cases)*100 AS percentage_death
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY 1,2

-- Total cases vs population in the UK
-- Shows the percentage of the infected population
SELECT location, date, population, total_cases,
		(total_cases/population)*100 AS percentage_infected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Kingdom' AND continent IS NOT NULL
ORDER BY 1,2

-- What countries have the highest infection rates
SELECT location, population, MAX(total_cases) AS Highest_case_count,
		(MAX(total_cases)/population)*100 AS percentage_of_population_infected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Looking at the death rate per population
SELECT location, MAX(CAST(total_deaths AS int)) AS Highest_deaths, population,
		(MAX(CAST(total_deaths AS int))/population) *100 AS Death_rate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY 2 DESC

-- Looking at it by continent
-- Total deaths
SELECT continent, MAX(CAST(total_deaths AS int)) AS Highest_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers
SELECT date, SUM(new_cases) total_cases, SUM(cast(new_deaths AS int)) total_deaths, 
		SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- SELECT Total Population VS Vaccinations
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations AS int)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths dea
	ON vac.location = dea.location AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,3


-- USE CTE
-- To get the (rolling_people_population/population) *100
WITH PopVsVac (location, continent, date, population, new_vaccinations, Rolling_people_vaccinated )
AS
	(SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations AS int)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
	FROM PortfolioProject.dbo.CovidVaccinations vac
	JOIN PortfolioProject.dbo.CovidDeaths dea
		ON vac.location = dea.location AND vac.date = dea.date
	WHERE dea.continent IS NOT NULL)
	

SELECT *, (Rolling_people_vaccinated/population) * 100
FROM PopVsVac

-- Create View
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations AS int)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths dea
	ON vac.location = dea.location AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,3
