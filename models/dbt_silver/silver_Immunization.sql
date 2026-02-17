{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Immunization_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_Immunization'
) }}


with cte_Immunization as
(select
    a.patient_id
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as Immunization_id
    ,  f.value[0]:occurrenceDateTime::timestamp as occurrenceDateTime
    ,  f.value[0]:patient::string as patient
    ,  f.value[0]:primarySource::string as primarySource
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:vaccineCode::string as vaccineCode
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Immunization'
)
select * from cte_Immunization
