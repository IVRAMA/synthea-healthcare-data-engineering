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
,  claims as (
    select 
        replace( "item"[0]:"encounter"[0]:"reference",'urn:uuid:','')::varchar as encounter_id
        , replace("provider":"reference",'urn:uuid:','')::varchar as claim_provider
        , "item"[0]:"productOrService":coding[0]:"code"::varchar as "CODE"
        , "item"[0]:"productOrService":coding[0]:"display"::varchar as "DESCRIPTION"
        , "total":"value"::varchar as TOTAL_CLAIM_COST
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