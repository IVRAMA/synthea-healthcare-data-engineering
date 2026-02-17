{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='stg_encounters'
) }}

WITH raw_encounters AS (
  SELECT * 
  FROM {{ source('clinical_data', 'encounters') }}
)

SELECT 
  "ID",
  TO_TIMESTAMP_NTZ("START")     AS "START_TIME",
  TO_TIMESTAMP_NTZ("STOP")      AS "STOP_TIME",
  "PATIENT",
  "ORGANIZATION",
  "PROVIDER",
  "PAYER",
  "ENCOUNTERCLASS",
  TO_NUMBER("CODE")             AS "CODE",
  "DESCRIPTION",
  TRY_TO_DOUBLE("BASE_ENCOUNTER_COST")  AS "BASE_ENCOUNTER_COST",
  TRY_TO_DOUBLE("TOTAL_CLAIM_COST")     AS "TOTAL_CLAIM_COST",
  TRY_TO_DOUBLE("PAYER_COVERAGE")       AS "PAYER_COVERAGE",
  "REASONCODE",
  "REASONDESCRIPTION"
FROM raw_encounters


