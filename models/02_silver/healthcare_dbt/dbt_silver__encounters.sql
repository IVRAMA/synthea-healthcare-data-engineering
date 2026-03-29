WITH encounter as (
select
    Encounter_id as "id"
    , encounter_start_dt as"START"
    , encounter_end_dt as "STOP"
    , replace(PARSE_JSON(participant):"individual"."reference"::varchar,'urn:uuid:','') AS patient
    , DECODE(PARSE_JSON(class):"code", 'AMB', 'Ambulatory', 'EMER', 'Emergency', 'IMP', 'Inpatient') ENCOUNTERCLASS
    , PARSE_JSON(reasonCode):"coding"[0]:"code"::varchar as REASONCODE
    , PARSE_JSON(reasonCode):"coding"[0]:"display"::varchar as REASONDESCRIPTION
from {{ ref('dbt_bronze__Encounter') }}) 
,  claims as (
    select 
        replace(PARSE_JSON(item):"encounter"[0]:"reference",'urn:uuid:','')::varchar as encounter_id
        , replace(PARSE_JSON(provider):"reference",'urn:uuid:','')::varchar as claim_provider
        , PARSE_JSON(item):"productOrService":coding[0]:"code"::varchar as "CODE"
        , PARSE_JSON(item):"productOrService":coding[0]:"display"::varchar as "DESCRIPTION"
        , PARSE_JSON(total):"value"::varchar as TOTAL_CLAIM_COST
    from {{ ref('dbt_bronze__Claim') }})
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