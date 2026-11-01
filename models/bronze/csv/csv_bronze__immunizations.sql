{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_immunizations'
) }}

with source as (
select 
    "DATE"
    ,"PATIENT"
    ,"ENCOUNTER"
    ,"CODE"
    ,"DESCRIPTION"
    ,"BASE_COST"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'IMMUNIZATIONS') }}
)

select {{auto_cast('IMMUNIZATIONS')}} from source