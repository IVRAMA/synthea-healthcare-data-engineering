{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_medications'
) }}

with source as (
select 
    "START"
    ,"STOP"
    ,"PATIENT"
    ,"PAYER"
    ,"ENCOUNTER"
    ,"CODE"
    ,"DESCRIPTION"
    ,"BASE_COST"
    ,"PAYER_COVERAGE"
    ,"DISPENSES"
    ,"TOTALCOST"
    ,"REASONCODE"
    ,"REASONDESCRIPTION"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'MEDICATIONS') }}
)

select {{auto_cast('MEDICATIONS')}} from source