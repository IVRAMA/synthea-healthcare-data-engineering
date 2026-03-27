with syn_procedure as (
    select
        distinct "id"
        , "performedPeriod":"start"::varchar as "START"
        , "performedPeriod":"end"::varchar as "STOP"
        , replace("encounter":"reference"::varchar,'urn:uuid:','') as encounter_id
        , "code":"coding"[0]:"code"::varchar as CODE
        , "code":"coding"[0]:"display"::varchar as DESCRIPTION
    from {{ ref('dbt_bronze__Procedure') }}
)
, encounter as (
    select
        "id"
        , replace("participant"[0]:"individual"."reference"::varchar,'urn:uuid:','') AS patient
        , "reasonCode"[0]:"coding"[0]:"code"::varchar as REASONCODE
        , "reasonCode"[0]:"coding"[0]:"display"::varchar as REASONDESCRIPTION
    from {{ ref('dbt_bronze__Encounter') }})
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
     syn_procedure p inner join encounter e on p.encounter_id = e."id"