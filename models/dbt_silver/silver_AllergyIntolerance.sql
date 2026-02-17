{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='AllergyIntolerance_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_AllergyIntolerance'
) }}

with cte_AllergyIntolerance as 
(select
a.patient_id
, f.value[0]:category[0]::string as category
 ,f.value[0]:clinicalStatus::string as clinicalStatus
 ,f.value[0]:code::string as code
 ,f.value[0]:criticality::string as criticality
 ,f.value[0]:id::string as AllergyIntolerance_id
 ,f.value[0]:patient::string as patient
 ,f.value[0]:recordedDate::timestamp as recordedDate
 ,f.value[0]:resourceType::string as resourceType
 ,f.value[0]:type::string as type
 ,f.value[0]:verificationStatus::string as verificationStatus
 from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'AllergyIntolerance')

select * from cte_AllergyIntolerance
