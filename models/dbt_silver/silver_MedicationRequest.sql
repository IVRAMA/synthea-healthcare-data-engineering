{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='MedicationRequest_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_MedicationRequest'
) }}

with cte_MedicationRequest as
(select
    a.patient_id
    ,  f.value[0]:authoredOn::timestamp as authoredOn
    ,  f.value[0]:dosageInstruction[0]::string as dosageInstruction
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as MedicationRequest_id
    ,  f.value[0]:intent::string as intent
    ,  f.value[0]:medicationCodeableConcept::string as medicationCodeableConcept
    ,  f.value[0]:requester::string as requester
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:subject::string as subject
from 
        {{ ref('synthea_flattened_l1') }} a  
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'MedicationRequest'
)
select * from cte_MedicationRequest