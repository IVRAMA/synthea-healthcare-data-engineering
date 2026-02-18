{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='tfm_json_immunizations'
) }}

with raw_immunizations AS (
select
    immunization_id as "id"
    , occurrencedatetime as "DATE"
    , patient_id as PATIENT
    , ENCOUNTER_ID AS ENCOUNTER
    , PARSE_JSON("VACCINECODE"):"coding"[0]:"code"::varchar as CODE
    , PARSE_JSON("VACCINECODE"):"coding"[0]:"display"::varchar as DESCRIPTION
    , 140.52::varchar as BASE_COST
from {{ ref('silver_Immunization') }}
)

SELECT
    TO_TIMESTAMP_NTZ("DATE") AS "DATE",
    "PATIENT" AS "PATIENT",
    "ENCOUNTER" AS "ENCOUNTER",
    TO_NUMBER("CODE") AS "CODE",
    "DESCRIPTION" AS "DESCRIPTION",
    TRY_TO_DOUBLE("BASE_COST") AS "BASE_COST" FROM raw_immunizations