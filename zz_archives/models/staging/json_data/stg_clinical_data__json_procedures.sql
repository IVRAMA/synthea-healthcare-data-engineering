{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='stg_json_procedures'
) }}

with raw_procedures AS (
select * from  {{ source('clinical_data', 'json_procedures') }}
)

SELECT
TO_TIMESTAMP_NTZ("START") AS "START",
TO_TIMESTAMP_NTZ("STOP") AS "STOP",
"PATIENT" AS "PATIENT",
"ENCOUNTER" AS "ENCOUNTER",
"CODE" AS "CODE",
"DESCRIPTION" AS "DESCRIPTION",
TRY_TO_DOUBLE("BASE_COST") AS "BASE_COST",
"REASONCODE" AS "REASONCODE",
"REASONDESCRIPTION" AS "REASONDESCRIPTION" FROM raw_procedures