{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='stg_immunizations'
) }}

with raw_immunizations AS (
select * from {{ source('clinical_data', 'immunizations') }}
)

SELECT
    TO_TIMESTAMP_NTZ("DATE") AS "DATE",
    "PATIENT" AS "PATIENT",
    "ENCOUNTER" AS "ENCOUNTER",
    TO_NUMBER("CODE") AS "CODE",
    "DESCRIPTION" AS "DESCRIPTION",
    TRY_TO_DOUBLE("BASE_COST") AS "BASE_COST" FROM raw_immunizations