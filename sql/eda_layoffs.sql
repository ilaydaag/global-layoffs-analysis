-- 	Exploratory Data Analysis for layoffs_staging2 table

select *
from layoffs_staging2;


-- Get the maximum number of people laid off  and the highest layoff percentage
select max(total_laid_off), Max(percentage_laid_off)
from layoffs_staging2;


-- Get all companies that laid off 100% of their employees
select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;


-- Aggregate total layoffs per company and order by highest total
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;


-- Get the earliest and latest layoff dates in the dataset
select min(`date`), max(`date`)
from layoffs_staging2;


-- Total layoffs per industry, ordered by the highest sum
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;


-- Total layoffs per country, ordered by the highest sum
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;


-- Yearly layoff totals, ordered by year descending
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;


-- Total layoffs per company stage
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;


-- Monthly layoffs (YYYY-MM format), excluding NULL values
select substring(`date`,1,7) as `month`, sum(total_laid_off )
from layoffs_staging2 
where substring(`date`,1,7) is not null 
group by `month`
order by 1 asc;


-- Rolling total: Calculate cumulative layoffs month by month
with Rolling_Total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2 
where substring(`date`,1,7) is not null 
group by `month`
order by 1 asc
)
select `month`,total_off ,
		sum(total_off) over(order by `month`) as rolling_total
from Rolling_Total;


-- Groups data by company and year, then sorts by the total number of layoffs in descending order.
select company, year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;


with Company_Year (company, years,total_laid_off) as
(
select company, year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
),                                      	-- CTE (Common Table Expression) named "Company_Year":
											-- It computes the total layoffs per company per year.
 Company_Year_Rank as 
(
select *, dense_rank() over (partition by years order by total_laid_off  desc) as Ranking
from Company_Year
where years is not null
)                                         	-- CTE named "Company_Year_Rank":
											-- It ranks companies by total layoffs **within each year** using DENSE_RANK,
											-- ignoring null year values.
select * 
from Company_Year_Rank
where Ranking <= 5;          				-- Final query selects the top 5 companies with the most layoffs for each year.












