{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_organizations'
) }}

with source as (
select 
    "ID"
    ,"NAME"
    ,"ADDRESS"
    ,"CITY"
    ,"STATE"
    ,"ZIP"
    ,"LAT"
    ,"LON"
    ,"PHONE"
    ,"REVENUE"
    ,"UTILIZATION"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'ORGANIZATIONS') }}
)

select {{auto_cast('ORGANIZATIONS')}} from source