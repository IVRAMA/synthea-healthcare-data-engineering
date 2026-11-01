{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='dim_Providers'
) }}

with csv_source as (
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
    , "LOAD_TS"
from {{ ref('csv_bronze__Providers') }} 
{% if is_incremental() %}
  WHERE LOAD_TS > (SELECT MAX(load_ts) FROM {{ this }})
{% endif %}
)

SELECT *  from csv_source