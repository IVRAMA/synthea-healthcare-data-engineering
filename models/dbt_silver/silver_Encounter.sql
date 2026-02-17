{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Encounter_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_Encounter'
) }}


with cte_Encounter as
(select
    a.patient_id
    ,  f.value[0]:class::string as class
    ,  f.value[0]:id::string as Encounter_id
    ,  f.value[0]:participant[0]::string as participant
    ,  f.value[0]:period.start::timestamp as encounter_start_dt
    ,  f.value[0]:period.end::timestamp as encounter_end_dt
    ,  f.value[0]:period::string as period
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:serviceProvider::string as serviceProvider
    ,  f.value[0]:status::string as status
    ,  f.value[0]:subject::string as subject
    ,  f.value[0]:type[0]::string as type
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Encounter'
)
select * from cte_Encounter
