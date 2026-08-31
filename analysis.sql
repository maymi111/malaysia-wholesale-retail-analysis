#data quality check
 
SELECT DISTINCT division
FROM iowrt
WHERE division NOT IN ('45', '46', '47');
 
#data duplicate
SELECT
    series,
    date,
    division,
    COUNT(*) AS duplicate_rows
FROM iowrt
GROUP BY series, date, division
HAVING COUNT(*) > 1;

  #Missing Query
SELECT
    series,
    division,
    COUNT(*) AS total_rows,
    SUM(sales IS NULL) AS missing_sales,
    SUM(volume IS NULL) AS missing_volume,
    SUM(volume_sa IS NULL) AS missing_volume_sa
FROM iowrt
GROUP BY series, division
ORDER BY series, division;

 #Missing / Availability Check
select 
    min(date) as first_missing_date, 
    max(date) as last_missing_date,
    count(*) as missing_row
from iowrt
where series = "growth_yoy" 
and volume_sa is null;

select 
    date, 
    count(*) as missing_value
from iowrt  
where series = "abs" and volume_sa is null
group by date
order by date;

 #Division Data Quality & Coverage
SELECT
    division,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    COUNT(*) AS total_rows,
    SUM(volume_sa IS NULL) AS missing_volume_sa
FROM iowrt
WHERE series = "abs"
GROUP BY division
ORDER BY division;

 #Negative Values by Division
SELECT
    division,
    SUM(sales < 0) AS negative_sales,
    SUM(volume < 0) AS negative_volume,
    SUM(volume_sa < 0) AS negative_volume_sa
FROM iowrt
WHERE series = "abs"
GROUP BY division
ORDER BY division;

#Available Months by Year
SELECT
    YEAR(date) AS year,
    COUNT(DISTINCT MONTH(date)) AS months_available
FROM iowrt
WHERE series = "abs"
GROUP BY YEAR(date)
ORDER BY year;

# SALES PERFORMANCE

 #Division Performance
SELECT
    division,
    SUM(sales) AS total_sales,
    AVG(sales) AS avg_sales,
    MIN(sales) AS min_sales,
    MAX(sales) AS max_sales
FROM iowrt
WHERE series = "abs"
GROUP BY division
ORDER BY total_sales DESC;

 #Sales Trend by Year (2018–Jun 2026)
SELECT
    YEAR(date) AS year,
    division,
    SUM(sales) AS total_sales
FROM iowrt
WHERE series = "abs"
GROUP BY YEAR(date), division
ORDER BY year, division;

 #2025 Monthly Sales Trend
SELECT
    MONTH(date) AS month,
    division,
    SUM(sales) AS monthly_sales
FROM iowrt
WHERE series = "abs"
  AND YEAR(date) = 2025
GROUP BY MONTH(date), division
ORDER BY month, division;

#Sales Contribution by Division 2025（%）
SELECT
    division,
    SUM(sales) AS total_sales,
    ROUND(
        SUM(sales) /
        (
            SELECT SUM(sales)
            FROM iowrt
            WHERE series = 'abs'
              AND YEAR(date) = 2025
        ) * 100,
        2
    ) AS sales_contribution_pct
FROM iowrt
WHERE series = 'abs'
  AND YEAR(date) = 2025
GROUP BY division
ORDER BY total_sales DESC;

#GROWTH ANALYSIS

 #Latest YoY Sales Growth
SELECT
    date,
    division,
    sales AS latest_yoy_sales_growth
FROM iowrt
WHERE series = 'growth_yoy'
  AND date = (
      SELECT MAX(date)
      FROM iowrt
      WHERE series = 'growth_yoy'
  )
ORDER BY latest_yoy_sales_growth DESC;

#Latest mom Sales Growth（环比销售增长率）
SELECT
    date,
    division,
    sales AS latest_mom_sales_growth
FROM iowrt
WHERE series = 'growth_mom'
  AND date = (
      SELECT MAX(date)
      FROM iowrt
      WHERE series = 'growth_mom'
  )
ORDER BY latest_mom_sales_growth DESC;

#VOLUME ANALYSIS

 #Volume
SELECT
    date,
    division,
    sales,
    volume AS volume_index,
    volume_sa AS volume_index_sa
FROM iowrt
WHERE series = 'abs'
ORDER BY date, division;
 