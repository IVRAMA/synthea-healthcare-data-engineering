{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_conditions'
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
    ,"LOAD_TS"
  FROM {{ source('csv_data', 'CONDITIONS') }}
)

select {{auto_cast('CONDITIONS')}} from source