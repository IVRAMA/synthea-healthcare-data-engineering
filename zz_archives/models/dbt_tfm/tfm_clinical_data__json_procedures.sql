{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='tfm_json_procedures'
) }}

with syn_procedure as (
select 
    procedure_id as "id"
    , performedperiod_start as "START"
    , performedperiod_end as "STOP"
    , encounter_id as encounter_id
    , parse_json(code):"coding"[0]:"code"::varchar as CODE
    , parse_json(code):"coding"[0]:"display"::varchar as DESCRIPTION
from  {{ ref('silver_Procedure') }}
)
, encounter as (
    select
        ID
        , patient
        , REASONCODE
        , REASONDESCRIPTION
    from {{ ref('tfm_clinical_data__json_encounters') }})

, raw_procedures AS (
select
    distinct p."id"
    , "START"
    , "STOP"
    , patient as PATIENT
    , encounter_id as ENCOUNTER
    , CODE
    , DESCRIPTION
    , null as BASE_COST
    , REASONCODE
    , REASONDESCRIPTION
from 
     syn_procedure p inner join encounter e on p.encounter_id = e.ID
)

SELECT
TO_TIMESTAMP_NTZ("START") AS "START",
TO_TIMESTAMP_NTZ("STOP") AS "STOP",
"PATIENT" AS "PATIENT",
"ENCOUNTER" AS "ENCOUNTER",
"CODE" AS "CODE",
"DESCRIPTION" AS "DESCRIPTION",
"BASE_COST",
"REASONCODE" AS "REASONCODE",
"REASONDESCRIPTION" AS "REASONDESCRIPTION" FROM raw_procedures