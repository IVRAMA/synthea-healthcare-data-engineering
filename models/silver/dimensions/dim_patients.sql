{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='dim_patients'
) }}

with csv_source as (
    select
        "ID" 
        ,"BIRTHDATE" 
        ,"DEATHDATE" 
        ,"SSN" 
        ,"DRIVERS" 
        ,"PASSPORT" 
        ,"PREFIX"
        ,"FIRST"
        ,"MIDDLE"
        ,"LAST"
        ,"SUFFIX"
        ,"MAIDEN"
        ,"MARITAL"
        ,"RACE"
        ,"ETHNICITY"
        ,"GENDER"
        ,"BIRTHPLACE"
        ,"ADDRESS"
        ,"CITY"
        ,"STATE"
        ,"COUNTY"
        ,"FIPS"
        ,"ZIP"
        ,"LAT"
        ,"LON"
        ,"HEALTHCARE_EXPENSES"
        ,"HEALTHCARE_COVERAGE"
        ,"INCOME"
        , LOAD_TS
    from {{ ref('csv_bronze__patients') }} 
    {% if is_incremental() %}
  WHERE LOAD_TS > (SELECT MAX(load_ts) FROM {{ this }})
{% endif %}
)

SELECT *  from csv_source