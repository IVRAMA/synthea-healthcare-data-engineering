{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='SILVER'
) }}


select distinct
    "DATE" as immunization_date
    , "PATIENT" as patient_id
    , "ENCOUNTER" as encounter_id
    , "CODE" as immunization_code
    , "DESCRIPTION" as immunization_description
    , "BASE_COST" as immunization_base_cost
from {{ ref('tfm_clinical_data__json_immunizations') }} as imm
