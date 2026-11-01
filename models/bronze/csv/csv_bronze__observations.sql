{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_observations'
) }}

with source as (
select 
    "DATE"
    ,"PATIENT"
    ,"ENCOUNTER"
    ,"CATEGORY"
    ,"CODE"
    ,"DESCRIPTION"
    ,"VALUE"
    ,"UNITS"
    ,"TYPE"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'OBSERVATIONS') }}
)

select {{auto_cast('OBSERVATIONS')}} from source