{{ config(
    materialized='incremental',
    unique_key='resource_md5',  
    incremental_strategy='delete+insert',
    database='SYNTHEA_RAW',
    schema='UTIL'
) }}

WITH TEMP_SYNTHEA_FLATTENED_L2 AS
(SELECT
    TABLE_NAME       AS TABLE_NAME,
    COLUMN_NAME      AS COLUMN_NAME,
    COL_DATA_TYPE    AS COLUMN_DATA_TYPE,
    MD5(CONCAT(TABLE_NAME,'-',COLUMN_NAME)) AS resource_md5
FROM (
    SELECT
        F.VALUE:COLUMN::STRING   AS COLUMN_NAME,
        F.VALUE:TABLE::STRING    AS TABLE_NAME,
        F.VALUE:DATATYPE::STRING AS COL_DATA_TYPE
    FROM  {{ ref('SYNTHEA_FLATTENED_L1') }},
         LATERAL FLATTEN (INPUT => COL_META) F
    GROUP BY 1,2,3
    ORDER BY 1,2,3
) )
select 'Batch-01' as batch_no, * from TEMP_SYNTHEA_FLATTENED_L2
