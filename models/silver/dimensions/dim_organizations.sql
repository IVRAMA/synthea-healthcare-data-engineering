{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='dim_organizations'
) }}

with csv_source as (
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
FROM {{ ref('csv_bronze__organizations') }}
 {% if is_incremental() %}
  WHERE LOAD_TS > (SELECT MAX(load_ts) FROM {{ this }})
{% endif %}
)

select * from csv_source