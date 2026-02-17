{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='stg_procedures'
) }}

with raw_procedures AS (
select * from  {{ source('clinical_data', 'procedures') }}
)

SELECT
TO_TIMESTAMP_NTZ("START") AS "START",
TO_TIMESTAMP_NTZ("STOP") AS "STOP",
"PATIENT" AS "PATIENT",
"ENCOUNTER" AS "ENCOUNTER",
TO_NUMBER("CODE") AS "CODE",
"DESCRIPTION" AS "DESCRIPTION",
TRY_TO_DOUBLE("BASE_COST") AS "BASE_COST",
"REASONCODE" AS "REASONCODE",
"REASONDESCRIPTION" AS "REASONDESCRIPTION" FROM raw_procedures