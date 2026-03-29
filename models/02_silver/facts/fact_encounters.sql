{{ config(materialized='table') }}

WITH silver_data as (

(select
encounter_id
, "START_TIME"
, "STOP_TIME"
, patient_id
, "ORGANIZATION" 
, PROVIDER_id
, PAYER_ID
, "ENCOUNTERCLASS"
, "CODE"
, "DESCRIPTION"
, "BASE_ENCOUNTER_COST"
, "TOTAL_CLAIM_COST"
, "PAYER_COVERAGE"
, "REASONCODE"
, "REASONDESCRIPTION"
from {{ ref('csv_silver__encounters') }})
union all
(select
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
from {{ ref('sfk_silver__encounters') }})
union all
(select
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
from {{ ref('dbt_silver__encounters') }})
)

select * from silver_data

