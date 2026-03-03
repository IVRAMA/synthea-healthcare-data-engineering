{{ config(
    materialized='table',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER_UTIL', 
    alias='synthea_flattened_l2'
) }}

WITH RAW AS
(
        SELECT
        F.VALUE:COLUMN::STRING   AS COLUMN_NAME,
        F.VALUE:TABLE::STRING    AS TABLE_NAME,
        F.VALUE:DATATYPE::STRING AS COL_DATA_TYPE,
        MAX(batch_no) as batch_no
    FROM {{ ref('synthea_flattened_l1') }},
         LATERAL FLATTEN (INPUT => COL_META) F
    GROUP BY 1,2,3
    ORDER BY 1,2,3,4
)
, SYNTHEA_FLATTENED_L2 AS
(SELECT
    TABLE_NAME       AS TABLE_NAME,
    COLUMN_NAME      AS COLUMN_NAME,
    COL_DATA_TYPE    AS COLUMN_DATA_TYPE,
    batch_no
FROM RAW)
SELECT *  FROM SYNTHEA_FLATTENED_L2 