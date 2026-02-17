{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Organization_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_Organization'
) }}

with cte_Organization as
(select
   f.value[0]:active::string as active
    ,  f.value[0]:address[0]::string as address
    ,  f.value[0]:id::string as Organization_id
    ,  f.value[0]:identifier[0]::string as org_identifier
    ,  f.value[0]:name::string as org_name
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:telecom[0]::string as telecom
    ,  f.value[0]:type[0]::string as org_type
from 
        {{ ref('synthea_flattened_l1') }} a  
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Organization'
)
select * from cte_Organization
