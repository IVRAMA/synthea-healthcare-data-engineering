{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_providers'
) }}

with source as (
select 
    "ID" 
    ,"ORGANIZATION" 
    ,"NAME" 
    ,"GENDER" 
    ,"SPECIALITY" 
    ,"ADDRESS" 
    ,"CITY" 
    ,"STATE" 
    ,"ZIP" 
    ,"LAT" 
    ,"LON" 
    ,"ENCOUNTERS" 
    ,"PROCEDURES" 
  FROM {{ source('csv_data', 'PROVIDERS') }}
)

select {{auto_cast('PROVIDERS')}} from source