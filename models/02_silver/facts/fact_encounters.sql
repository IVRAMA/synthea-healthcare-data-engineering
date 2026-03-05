{{ config(materialized='table') }}

WITH silver_data as (

select
"ID" AS encounter_id
, "START" AS "START_TIME"
, "STOP" AS "STOP_TIME"
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
from {{ ref('csv_bronze__encounters') }}
)

select * from silver_data

