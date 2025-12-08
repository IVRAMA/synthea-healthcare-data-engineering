{{ config(
    materialized='incremental',
    unique_key='resource_md5',
    incremental_strategy='delete+insert'
) }}

WITH resource_json AS (
    SELECT
        f.value:resource.resourceType::string AS resource_type,
        f.value:resource AS resource_json,
        g.key AS column_name,
        typeof(g.value) AS data_type_L1,
        g.value AS col_data          -- do NOT cast here
    FROM {{ source('raw_data', 'MASTER_JSON') }},
        LATERAL FLATTEN(input => raw:entry) f,
        LATERAL FLATTEN(input => f.value:resource) g
),
json_flattened_L1 AS (
    SELECT
        r.resource_type AS table_name,
        r.column_name AS parent_column,
        child.key AS column_name_L2,
        typeof(child.value) AS data_type_L2,
        child.value AS col_data_L2
    FROM resource_json r,
        LATERAL FLATTEN(input => r.col_data) child
    WHERE r.data_type_L1 IN ('OBJECT', 'ARRAY')
)
SELECT *
FROM json_flattened_L1