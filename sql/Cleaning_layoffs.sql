select *  from layoffs;

-- Data Cleaning Plan:
-- 1. Remover duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove any Columns or Rows

-- Create a new staging table with the same structure as layoffs
Create table layoffs_staging
Like layoffs;

select *  from layoffs_staging;

-- Insert all data from original table into the staging table
insert layoffs_staging
select *
from layoffs;


-- ==============================
-- Step 1: Remove duplicate records
-- ==============================

-- Create a CTE to find duplicates by assigning a row number to identical records
with duplicate_cte as
(
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
-- Display the duplicate rows (those with row_num > 1)
select *
from duplicate_cte
where row_num > 1;


-- View all entries for company 'Casper' for manual inspection
select *  
from layoffs_staging
where company= 'Casper';


-- Delete the duplicate rows using the same logic
with duplicate_cte as
(
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
delete
from duplicate_cte
where row_num > 1;


-- Create a second staging table with additional 'row_num' column
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *  
from layoffs_staging2
where row_num > 1;


-- Insert deduplicated data into layoffs_staging2 with row numbers
insert into layoffs_staging2 
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;


-- Remove rows with duplicate row_num > 1
delete  
from layoffs_staging2
where row_num > 1;


-- Check cleaned dataset
select *  
from layoffs_staging2;


-- ==============================
-- Step 2: Standardize the Data
-- ==============================

-- Trim whitespace from company names
select company,trim(company)
from layoffs_staging2;


update layoffs_staging2
set company = trim(company);


-- Standardize industry names
select distinct industry
from layoffs_staging2
order by 1;


-- See examples of similar but inconsistent values 
select *
from layoffs_staging2
where industry like 'Crypto%';


-- Unify all to 'Crypto'
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';


-- Standardize location names
select distinct location
from layoffs_staging2
order by 1;


-- Check country field for issues(United States vs United States.)
select *
from layoffs_staging2
where country like'United States%';


select distinct country , trim(trailing '.' from country)
from layoffs_staging2
order by 1; 


-- Remove trailing dot
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like'United States%';


-- Convert date column from text to DATE format
select `date`
from layoffs_staging2;


update layoffs_staging2
set `date`= str_to_date(`date`, '%m/%d/%Y');


-- Alter column type to proper DATE
alter table layoffs_staging2
modify column `date` date;


-- ==============================
-- Step 3: Handle NULL or missing values
-- ==============================


-- View rows where both key values are missing
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


-- View rows with missing or blank industry
-- we have 4 missing industry so lets try to populate them
select *
from layoffs_staging2
where industry is null
or industry = '';


-- Convert blank industry values to NULL
update layoffs_staging2
set industry = null
where industry = '';


-- Try to fill missing industries by joining with rows from the same company
select * 
from layoffs_staging2
where company = 'Airbnb';


-- Join with non-null entries of the same company
select *
from layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
 
 
-- Fill missing industry values using the matched rows from the same company
update layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;  


-- ==============================
-- Step 4: Remove any Columns or Rows
-- ==============================

-- Delete rows with both total_laid_off and percentage_laid_off as NULL
delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


-- Recheck if any rows still have both key fields NULL
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


-- Final check of the cleaned data
select * 
from layoffs_staging2;


-- Drop the temporary row_num column as it's no longer needed
alter table layoffs_staging2
drop column row_num;

-- so this is the finalized clean data













