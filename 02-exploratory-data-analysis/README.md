# Layoffs Data: Exploratory Data Analysis (EDA)

Exploratory analysis of the cleaned layoffs dataset (layoffs_staging2) using MySQL, following Alex The Analyst's SQL series.

## What this project covers
- Overview: maximum layoffs and companies that shut down completely
- Aggregations by company, industry, country, year, and funding stage
- Monthly layoffs and rolling totals (CTE and window functions)
- Top 5 companies by layoffs per year (DENSE_RANK)

## Tools
MySQL 8.0, MySQL Workbench

## How to run
Run the 01-data-cleaning project first to create the layoffs_staging2 table, then run 02_layoffs_eda.sql.
