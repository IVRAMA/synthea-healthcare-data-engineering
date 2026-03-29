WITH encounter as (
    select
        Encounter_id as "id"
        , encounter_start_dt ::VARCHAR as"START"
        , encounter_end_dt::VARCHAR as "STOP"
        , replace(PARSE_JSON(participant):"individual"."reference"::varchar,'urn:uuid:','') AS patient
        , DECODE(PARSE_JSON(class):code, 'AMB', 'Ambulatory', 'EMER', 'Emergency', 'IMP', 'Inpatient') ENCOUNTERCLASS
        , PARSE_JSON(reasonCode):"coding"[0]:"code"::varchar as REASONCODE
        , PARSE_JSON(reasonCode):"coding"[0]:"display"::varchar as REASONDESCRIPTION
    from {{ ref('dbt_bronze__Encounter') }}) 
, medications as (
    select
        distinct MedicationRequest_id as "id"
        , replace(PARSE_JSON(requester):"reference",'urn:uuid:','') as PATIENT
        , encounter_id as ENCOUNTER
        , PARSE_JSON(medicationCodeableConcept):"coding"[0]:"code"::varchar as CODE
        , PARSE_JSON(medicationCodeableConcept):"coding"[0]:"display"::varchar as DESCRIPTION
    FROM {{ ref('dbt_bronze__MedicationRequest') }} )
,  claims as (
    select 
        replace( PARSE_JSON(item):"encounter"[0]:"reference",'urn:uuid:','')::varchar as encounter_id
        , replace(PARSE_JSON(provider):"reference",'urn:uuid:','')::varchar as claim_provider
        , PARSE_JSON(item):"productOrService":coding[0]:"code"::varchar as "CODE"
        , PARSE_JSON(item):"productOrService":coding[0]:"display"::varchar as "DESCRIPTION"
        , PARSE_JSON(total):"value"::varchar as TOTAL_CLAIM_COST
    from {{ ref('dbt_bronze__Claim') }})
select
    DISTINCT m.ENCOUNTER 
    , e."START"
    , e."STOP"
    , m.PATIENT
    , null as payer
    , c.encounter_id
    , m.CODE
    , M.DESCRIPTION
    , NULL AS BASE_COST
    , NULL AS PAYER_COVERAGE
    , NULL AS DISPENSES
    , TOTAL_CLAIM_COST AS TOTALCOST
    , REASONCODE
    , REASONDESCRIPTION
from encounter e inner join medications m on e."id"  = m.ENCOUNTER inner join claims c on e."id" = c.encounter_id