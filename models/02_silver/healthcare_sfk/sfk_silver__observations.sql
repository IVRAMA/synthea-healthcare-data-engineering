with observation as (
SELECT
    DISTINCT "id"
    , "effectiveDateTime" as "DATE"
    , replace("encounter":"reference"::varchar,'urn:uuid:','') as encounter_id
    , "category"[0]:"coding"[0]: "display"::varchar as CATEGORY
    , "code":"coding"[0]:"code"::varchar as CODE
    , "code":"coding"[0]:"display"::varchar as DESCRIPTION
    , "valueQuantity":"value"::varchar as  VALUE
    , "valueQuantity":"code"::varchar as  UNITS
    , 'numeric' as "TYPE"
FROM {{ ref('sfk_bronze__Observation') }})
, encounter as (
    select
        "id"
        , replace("participant"[0]:"individual"."reference"::varchar,'urn:uuid:','') AS patient
    from {{ ref('sfk_bronze__Encounter') }})
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
