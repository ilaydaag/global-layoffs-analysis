# Layoffs Cleaning and Exploratory Data Analysis (EDA)

This project focuses on cleaning and analyzing global layoffs data using SQL.  
The dataset includes information about company layoffs such as date, industry, location, percentage laid off, and more.

---


- **Original file**: `layoffs.csv`
- **Cleaned file**: `layoffs_staging2.csv`


---

## 🧹 Cleaning Process

Performed in `Cleaning_layoffs.sql`:

- Removed duplicate rows using `ROW_NUMBER()`
- Trimmed whitespace and standardized text fields (e.g., `"CryptoCurrency"` → `"Crypto"`)
- Converted string dates to `DATE` format
- Filled missing `industry` values using self joins
- Deleted rows with both `total_laid_off` and `percentage_laid_off` as NULL

---

## 📊 Exploratory Data Analysis (EDA)

Performed in `eda_layoffs.sql`:

- Layoffs by year, country, industry, and company
- Monthly layoffs trend and rolling totals
- Top 5 companies with highest layoffs each year

---

## 🛠️ Tools Used

- MySQL
- SQL (CTEs, aggregation, window functions)

---

