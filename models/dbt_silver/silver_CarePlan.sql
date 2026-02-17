{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='CarePlan_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_CarePlan'
) }}

with cte_careplan as
(select
    a.patient_id
    ,  f.value[0]:activity[0]::string as activity
    ,  f.value[0]:category[0]::string as category
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as CarePlan_id
    ,  f.value[0]:intent::string as intent
    ,  f.value[0]:period::string as period
    ,  f.value[0]:period.start::timestamp as care_start_dt
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:subject::string as subject
    ,  f.value[0]:text::string as text
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'CarePlan'
)
select * from cte_careplan