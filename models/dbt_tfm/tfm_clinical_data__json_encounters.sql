{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='tfm_json_encounters'
) }}

WITH encounter as (
select
    encounter_id as "id"
    , a.encounter_start_dt as "START"
    , a.encounter_end_dt  as "STOP"
    , replace(patient_id::varchar,'urn:uuid:','') AS patient
    , DECODE(PARSE_JSON("CLASS"):"code", 'AMB', 'Ambulatory', 'EMER', 'Emergency', 'IMP', 'Inpatient') ENCOUNTERCLASS
    , PARSE_JSON("TYPE"):"coding"[0]:"code"::varchar as REASONCODE
    , PARSE_JSON("TYPE"):"coding"[0]:"display"::varchar as REASONDESCRIPTION
from {{ ref('silver_Encounter') }}) 
,  claims as (
    select 
        replace(PARSE_JSON("ITEM"):"encounter"[0]:"reference",'urn:uuid:','')::varchar as encounter_id
        , replace(PARSE_JSON("PROVIDER"):"reference",'urn:uuid:','')::varchar as claim_provider
        , PARSE_JSON("ITEM"):"productOrService":coding[0]:"code"::varchar as "CODE"
        , PARSE_JSON("ITEM"):"productOrService":coding[0]:"display"::varchar as "DESCRIPTION"
        , PARSE_JSON("TOTAL"):"value"::varchar as TOTAL_CLAIM_COST
    from {{ ref('silver_Claim') }})
, raw_encounters AS (
SELECT 
   distinct e."id" as ID
    , e."START"
    , e."STOP"
    , e.patient as PATIENT
    , claim_provider as ORGANIZATION
    , claim_provider as PROVIDER
    , null as PAYER
    , ENCOUNTERCLASS
    , c."CODE"
    , c."DESCRIPTION"
    , null as BASE_ENCOUNTER_COST
    , c.TOTAL_CLAIM_COST
    , null as PAYER_COVERAGE
    , e.REASONCODE
    , e.REASONDESCRIPTION
FROM encounter e inner join  claims c on e."id" = c.encounter_id
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


