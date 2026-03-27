{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Claim_id',
    on_schema_change='append_new_columns',
    database='HDB',
    schema='BRONZE',
    alias='dbt_bronze_Claim'
) }}

with cte_Claim as
(select
    a.patient_id
   ,  f.value[0]:text::string as text
    ,  f.value[0]:billablePeriod::string as billablePeriod
    ,  f.value[0]:billablePeriod.start::timestamp as billablePeriod_start_dt
    ,  f.value[0]:billablePeriod.end::timestamp as billablePeriod_end_dt
    ,  f.value[0]:created::timestamp as created
    ,  f.value[0]:id::string as Claim_id
    ,  f.value[0]:insurance[0]::string as insurance
    ,  f.value[0]:item[0]::string as item
    ,  f.value[0]:patient::string as patient
    ,  f.value[0]:priority::string as priority
    ,  f.value[0]:provider::string as provider
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:total::string as total
    ,  f.value[0]:type::string as claim_type
    ,  f.value[0]:use::string as claim_use
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Claim'
)
select * from cte_Claim
