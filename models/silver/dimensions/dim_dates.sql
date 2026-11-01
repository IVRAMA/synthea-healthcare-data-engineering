{{ config (
    materialized='table',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='dim_dates'
) }}

WITH RECURSIVE date_sequence AS (
    -- Start Date
    SELECT '1942-01-01'::DATE AS generated_date
    UNION ALL
    -- Increment by 1 day until the End Date
    SELECT DATEADD(day, 1, generated_date)
    FROM date_sequence
    WHERE generated_date < '2026-12-31'::DATE
)

SELECT 
    generated_date
    , row_number() over (order by generated_date) as seq
    , YEAR(generated_date) generated_date_year
    , MONTH(generated_date) generated_date_month
    , monthname(generated_date) generated_date_month_name
    , DAYNAME(generated_date) generated_date_week_name
    , dayofyear(generated_date) generated_date_day
FROM date_sequence
ORDER BY generated_date