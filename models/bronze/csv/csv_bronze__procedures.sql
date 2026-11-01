{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_procedures'
) }}

with source as (
select 
    "START"
    ,"STOP"
    ,"PATIENT"
    ,"ENCOUNTER"
    ,"SYSTEM"
    ,"CODE"
    ,"DESCRIPTION"
    ,"BASE_COST"
    ,"REASONCODE"
    ,"REASONDESCRIPTION"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'PROCEDURES') }}
)

select {{auto_cast('PROCEDURES')}} from source