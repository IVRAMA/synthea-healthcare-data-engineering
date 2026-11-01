{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_allergies'
) }}


with source as (
    select 
        "START"
        ,"STOP"
        ,"PATIENT"
        ,"ENCOUNTER"
        ,"CODE"
        ,"SYSTEM"
        ,"DESCRIPTION"
        ,"TYPE"
        ,"CATEGORY"
        ,"REACTION1"
        ,"DESCRIPTION1"
        ,"SEVERITY1"
        ,"REACTION2"
        ,"DESCRIPTION2"
        ,"SEVERITY2"
        ,"LOAD_TS"
        from {{ source('csv_data', 'ALLERGIES') }}

)

SELECT {{auto_cast ('ALLERGIES')}} from source
