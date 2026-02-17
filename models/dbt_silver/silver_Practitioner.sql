{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Practitioner_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_Practitioner'
) }}

with cte_Practitioner as
(select
    f.value[0]:active::string as active
    ,  f.value[0]:address[0]::string as address
    ,  f.value[0]:gender::string as gender
    ,  f.value[0]:id::string as Practitioner_id
    ,  f.value[0]:identifier[0]::string as identifier
    ,  f.value[0]:name[0]::string as name
    ,  f.value[0]:resourceType::string as resourceType
from 
        {{ ref('synthea_flattened_l1') }} a  
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Practitioner'
)
select *  from cte_Practitioner