with observation as (
SELECT
    DISTINCT Observation_id as "id"
    , effectiveDateTime as "DATE"
    , encounter_id
    , PARSE_JSON(category):"coding"[0]: "display"::varchar as CATEGORY
    , PARSE_JSON(code):"coding"[0]:"code"::varchar as CODE
    , PARSE_JSON(code):"coding"[0]:"display"::varchar as DESCRIPTION
    , PARSE_JSON(valueQuantity):"value"::varchar as  VALUE
    , PARSE_JSON(valueQuantity):"code"::varchar as  UNITS
    , 'numeric' as "TYPE"
FROM {{ ref('dbt_bronze__Observation') }})
, encounter as (
    select
        Encounter_id as "id"
        , replace(PARSE_JSON(participant):"individual"."reference"::varchar,'urn:uuid:','') AS patient
    from {{ ref('dbt_bronze__Encounter') }})
select 
    distinct o."id"
    , "DATE"
    , patient
    , encounter_id as ENCOUNTER
    , CATEGORY
    , CODE
    , DESCRIPTION
    , VALUE
    , UNITS
    , "TYPE"
from observation o inner join  encounter e on o.encounter_id = e."id"
