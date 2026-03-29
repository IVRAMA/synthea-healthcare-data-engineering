{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='patient_id',
    on_schema_change='append_new_columns',
    database='HDB',
    schema='BRONZE',
    alias='dbt_bronze_Patient'
) }}

WITH patients_flattened AS (
select 
     f.value[0]:id::string as patient_id
    , f.value[0]:address[0]  as address
    , f.value[0]:address[0].city::string as city
    , f.value[0]:address[0].state::string as state
    , f.value[0]:birthDate::date as birthDate
    , f.value[0]:birthDate::timestamp as birthDate1
    , f.value[0]:communication[0] as communication
    , f.value[0]:gender::string as gender
    , f.value[0]:identifier[0] as  "identifier"
    , f.value[0]:maritalStatus as maritalStatus
    , f.value[0]:multipleBirthBoolean::string as multipleBirthBoolean
    , f.value[0]:name as patient_name
    , f.value[0]:telecom[0]::string as telecom
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Patient')

select * from patients_flattened
