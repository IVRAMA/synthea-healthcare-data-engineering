{{ config(
    materialized='table',
    transient=true
) }}

WITH flattened AS (
    SELECT
        table_name,
        column_date_type,
        g.key AS column_name,
        g.value AS column_value
    FROM  {{ ref('flattened_json_L1') }},
         LATERAL FLATTEN(input => resource_json) g
),

ranked AS (
    SELECT
        table_name,
        column_date_type,
        column_name,
        column_value,
        ROW_NUMBER() OVER (PARTITION BY resource_type, column_name ORDER BY column_value) AS rn
    FROM flattened
)

SELECT
    table_name AS table_name,
    column_name,
    column_date_type,
    MAX(CASE WHEN rn = 1 THEN column_value::string END) AS data1,
    MAX(CASE WHEN rn = 2 THEN column_value::string END) AS data2,
    MAX(CASE WHEN rn = 3 THEN column_value::string END) AS data3,
    MAX(CASE WHEN rn = 4 THEN column_value::string END) AS data4,
    MAX(CASE WHEN rn = 5 THEN column_value::string END) AS data5
FROM ranked
GROUP BY table_name, column_name, column_date_type
ORDER BY table_name, column_name
