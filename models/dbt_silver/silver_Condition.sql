{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Condition_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_Condition'
) }}

with cte_Condition as
(select
    a.patient_id
    ,  f.value[0]:clinicalStatus::string as clinicalStatus
    ,  f.value[0]:code::string as code
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as Condition_id
    ,  f.value[0]:onsetDateTime::timestamp as onsetDateTime
    ,  f.value[0]:recordedDate::timestamp as recordedDate
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:subject::string as subject
    ,  f.value[0]:verificationStatus::string as verificationStatus

from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Condition'
)
select * from cte_Condition
