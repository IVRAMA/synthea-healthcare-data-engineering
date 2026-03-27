{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='DiagnosticReport_id',
    on_schema_change='append_new_columns',
    database='HDB',
    schema='BRONZE',
    alias='dbt_bronze_DiagnosticReport'
) }}

with cte_DiagnosticReport as
(select
    a.patient_id
    ,  f.value[0]:category[0]::string as category
    ,  f.value[0]:code::string as code
    ,  f.value[0]:effectiveDateTime::timestamp as effectiveDateTime
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as DiagnosticReport_id
    ,  f.value[0]:issued::timestamp as issued
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:result[0]::string as result
    ,  f.value[0]:status::string as status
    ,  f.value[0]:subject::string as subject
from 
        {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'DiagnosticReport'
)
select * from cte_DiagnosticReport
