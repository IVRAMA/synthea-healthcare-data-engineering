{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_supplies'
) }}

with source as (
select 
    "DATE"
    ,"PATIENT"
    ,"ENCOUNTER"
    ,"CODE"
    ,"DESCRIPTION"
    ,"QUANTITY"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'SUPPLIES') }}
)

select {{auto_cast('SUPPLIES')}} from source