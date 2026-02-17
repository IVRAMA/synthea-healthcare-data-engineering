{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='SILVER'
) }}

select
"ID" AS encounter_id
, "START_TIME"
, "STOP_TIME"
, "PATIENT" as patient_id
, "ORGANIZATION" 
, "PROVIDER" as PROVIDER_id
, "PAYER" as PAYER_ID
, "ENCOUNTERCLASS"
, "CODE"
, "DESCRIPTION"
, "BASE_ENCOUNTER_COST"
, "TOTAL_CLAIM_COST"
, "PAYER_COVERAGE"
, "REASONCODE"
, "REASONDESCRIPTION"
from {{ ref('stg_clinical_data__json_encounters') }}
