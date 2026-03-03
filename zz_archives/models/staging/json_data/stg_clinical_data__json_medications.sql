{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='stg_json_medications'
) }}

with raw_medications AS(
    select * from {{ source('clinical_data', 'json_medications') }}
)

SELECT
TO_TIMESTAMP_NTZ("START") AS "START",
TO_TIMESTAMP_NTZ("STOP") AS "STOP",
"PATIENT" AS "PATIENT",
"PAYER" AS "PAYER",
"ENCOUNTER" AS "ENCOUNTER",
TO_NUMBER("CODE") AS "CODE",
"DESCRIPTION" AS "DESCRIPTION",
TRY_TO_DOUBLE("BASE_COST") AS "BASE_COST",
TRY_TO_DOUBLE("PAYER_COVERAGE") AS "PAYER_COVERAGE",
TO_NUMBER("DISPENSES") AS "DISPENSES",
TRY_TO_DOUBLE("TOTALCOST") AS "TOTALCOST",
"REASONCODE" AS "REASONCODE",
"REASONDESCRIPTION" AS "REASONDESCRIPTION" FROM raw_medications