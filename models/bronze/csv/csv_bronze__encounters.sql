{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_encounters'
) }}


with source as (
select "ID" 
,"START" 
,"STOP" 
,"PATIENT" 
,"ORGANIZATION" 
,"PROVIDER" 
,"PAYER" 
,"ENCOUNTERCLASS" 
,"CODE" 
,"DESCRIPTION" 
,"BASE_ENCOUNTER_COST" 
,"TOTAL_CLAIM_COST" 
,"PAYER_COVERAGE" 
,"REASONCODE" 
,"REASONDESCRIPTION" 
from {{ source('csv_data', 'ENCOUNTERS') }} 
)

select {{ auto_cast('ENCOUNTERS') }} from source
