{{ config (
    materialized='table',
    database='HJB',
    schema='BRONZE', 
    alias='json_bronze_encounters'
) }}


with source as (

select 
    "id" as ID
    ,"period":"start"::DATETIME   as "START"
    ,"period":"end"::DATETIME   as "STOP"
    , "period":"end"::DATETIME  - "period":"start"::DATETIME as consulhrs
    , replace("subject":reference, 'urn:uuid:','')::string as PATIENT
    , replace("serviceProvider":reference, 'Organization?identifier=https://github.com/synthetichealth/synthea|','')::string as ORGANIZATION
    , "serviceProvider":"display"::string as ORGANIZATION_NAME
    , '' as PROVIDER
    , '' as PAYER
    , "type"[0]:"text" as ENCOUNTERCLASS    
    , "type"[0]:"coding"[0]."code"::NUMBER as CODE
    , "type"[0]:"coding"[0]."display"::STRING as DESCRIPTION
    , 0 as BASE_ENCOUNTER_COST
    , 0 as TOTAL_CLAIM_COST
    , 0 as PAYER_COVERAGE
    , "reasonCode"[0]:"coding"[0]:"code"::number as REASONCODE
    , "reasonCode"[0]:"coding"[0]:"display"::string as REASONDESCRIPTION
    , LOAD_TS
from 
    {{ source('json_data', 'ENCOUNTER') }} 
)
select * from source