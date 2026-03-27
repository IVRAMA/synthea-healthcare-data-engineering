{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Observation_id',
    on_schema_change='append_new_columns',
    database='HDB',
    schema='BRONZE',
    alias='dbt_bronze_Observation'
) }}

with cte_Observation as
(select
    a.patient_id
    ,  f.value[0]:category[0]::string as category
    ,  f.value[0]:code::string as code
    ,  f.value[0]:effectiveDateTime::timestamp as effectiveDateTime
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as Observation_id
    ,  f.value[0]:issued::timestamp as issued
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:subject::string as subject
    ,  f.value[0]:valueQuantity::string as valueQuantity
from 
        {{ ref('synthea_flattened_l1') }} a  
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Observation'
)
select * from cte_Observation