{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='tfm_json_medications'
) }}


WITH encounter as (
select
    ID
    , "START_TIME"
    , "STOP_TIME"
    , patient
    , ENCOUNTERCLASS
    , REASONCODE
    , REASONDESCRIPTION        
    , ID as encounter_id
    , "PROVIDER" as claim_provider
    , "CODE"
    , "DESCRIPTION"
    , TOTAL_CLAIM_COST
from  {{ ref('tfm_clinical_data__json_encounters') }} a) 

, medications as (
select 
    medicationrequest_id as "id"
    , replace(patient_id,'urn:uuid:','') as PATIENT
    , ENCOUNTER_ID AS ENCOUNTER
    , parse_json("MEDICATIONCODEABLECONCEPT"):"coding"[0]:"code"::varchar as CODE
    , parse_json("MEDICATIONCODEABLECONCEPT"):"coding"[0]:"display"::varchar as DESCRIPTION
from {{ ref('silver_MedicationRequest') }})
, raw_medications AS(
    select
    DISTINCT m.ENCOUNTER 
    , e."START_TIME" as "START" 
    , e."STOP_TIME" as "STOP"
    , m.PATIENT
    , null as payer
    , encounter_id
    , m.CODE
    , M.DESCRIPTION
    , NULL AS BASE_COST
    , NULL AS PAYER_COVERAGE
    , NULL AS DISPENSES
    , TOTAL_CLAIM_COST AS TOTALCOST
    , REASONCODE
    , REASONDESCRIPTION
from encounter e inner join medications m on e.ID  = m.ENCOUNTER
)

SELECT
TO_TIMESTAMP_NTZ("START") AS "START",
TO_TIMESTAMP_NTZ("STOP") AS "STOP",
"PATIENT" AS "PATIENT",
"PAYER" AS "PAYER",
"ENCOUNTER" AS "ENCOUNTER",
TO_NUMBER("CODE") AS "CODE",
"DESCRIPTION" AS "DESCRIPTION",
"BASE_COST",
"PAYER_COVERAGE",
TO_NUMBER("DISPENSES") AS "DISPENSES",
"TOTALCOST",
"REASONCODE" AS "REASONCODE",
"REASONDESCRIPTION" AS "REASONDESCRIPTION" FROM raw_medications