{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='tfm_json_observations'
) }}

with observation as (
select 
    observation_id as "id"
    , effectivedatetime as "DATE"
    , encounter_id as encounter_id
    , parse_json(category):"coding"[0]: "display"::varchar as CATEGORY
    , parse_json(code):"coding"[0]:"code"::varchar as CODE
    , parse_json(code):"coding"[0]:"display"::varchar as DESCRIPTION
    , parse_json(valuequantity):"value"::double as  VALUE_VALUE
    , parse_json(valuequantity):"code"::varchar as  VALUE_CODE
    , 'numeric' as "TYPE"
from  {{ ref('silver_Observation') }})
, encounter as (
    select ID , patient from {{ ref('tfm_clinical_data__json_encounters') }})
, raw_observations AS
(
    select 
    distinct o."id"
    , "DATE"
    , patient
    , encounter_id as ENCOUNTER
    , CATEGORY
    , CODE
    , DESCRIPTION
    , VALUE_VALUE AS VALUE
    , VALUE_CODE AS UNITS
    , "TYPE"
from observation o inner join  encounter e on o.encounter_id = e.ID
)
select
TO_TIMESTAMP_NTZ("DATE") as OBSERVATION_DT,
"PATIENT",
"ENCOUNTER",
"CATEGORY",
"CODE",
"DESCRIPTION",
"VALUE",
"UNITS",
"TYPE"
FROM  raw_observations