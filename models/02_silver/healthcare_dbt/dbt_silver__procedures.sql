with syn_procedure as (
    select
        distinct Procedure_id as "id"
        , performedPeriod_start as "START"
        , performedPeriod_end as "STOP"
        , encounter_id
        , PARSE_JSON(code):"coding"[0]:"code"::varchar as CODE
        , PARSE_JSON(code):"coding"[0]:"display"::varchar as DESCRIPTION
    from {{ ref('dbt_bronze__Procedure') }}
)
, encounter as (
    select
        Encounter_id as "id"
        , replace(PARSE_JSON(participant):"individual"."reference"::varchar,'urn:uuid:','') AS patient
        , DECODE(PARSE_JSON(class):code, 'AMB', 'Ambulatory', 'EMER', 'Emergency', 'IMP', 'Inpatient') ENCOUNTERCLASS
        , PARSE_JSON(reasonCode):"coding"[0]:"code"::varchar as REASONCODE
        , PARSE_JSON(reasonCode):"coding"[0]:"display"::varchar as REASONDESCRIPTION
    from {{ ref('dbt_bronze__Encounter') }})
select
    distinct p."id"
    , "START"
    , "STOP"
    , patient as PATIENT
    , encounter_id as ENCOUNTER
    , ENCOUNTERCLASS
    , CODE
    , DESCRIPTION
    , null as BASE_COST
    , REASONCODE
    , REASONDESCRIPTION
from 
     syn_procedure p inner join encounter e on p.encounter_id = e."id"