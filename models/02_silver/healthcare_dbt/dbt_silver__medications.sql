WITH encounter as (
    select
        "id"
        , "period":"start"::VARCHAR as"START"
        , "period":"end"::VARCHAR as "STOP"
        , replace("participant"[0]:"individual"."reference"::varchar,'urn:uuid:','') AS patient
        , DECODE("class":"code", 'AMB', 'Ambulatory', 'EMER', 'Emergency', 'IMP', 'Inpatient') ENCOUNTERCLASS
        , "reasonCode"[0]:"coding"[0]:"code"::varchar as REASONCODE
        , "reasonCode"[0]:"coding"[0]:"display"::varchar as REASONDESCRIPTION
    from {{ ref('dbt_bronze__Encounter') }}) 
, medications as (
    select
        distinct "id"
        , replace("requester":"reference",'urn:uuid:','') as PATIENT
        , replace("encounter":"reference",'urn:uuid:','') as ENCOUNTER
        , "medicationCodeableConcept":"coding"[0]:"code"::varchar as CODE
        , "medicationCodeableConcept":"coding"[0]:"display"::varchar as DESCRIPTION
    FROM {{ ref('dbt_bronze__MedicationRequest') }} )
,  claims as (
    select 
        replace( "item"[0]:"encounter"[0]:"reference",'urn:uuid:','')::varchar as encounter_id
        , replace("provider":"reference",'urn:uuid:','')::varchar as claim_provider
        , "item"[0]:"productOrService":coding[0]:"code"::varchar as "CODE"
        , "item"[0]:"productOrService":coding[0]:"display"::varchar as "DESCRIPTION"
        , "total":"value"::varchar as TOTAL_CLAIM_COST
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