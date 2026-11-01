{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_devices'
) }}

with source as (
select 
    "START"
    ,"STOP"
    ,"PATIENT"
    ,"ENCOUNTER"
    ,"CODE"
    ,"DESCRIPTION"
    ,"UDI"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'DEVICES') }}
)

select {{auto_cast('DEVICES')}} from source