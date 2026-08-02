{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_patients'
) }}

with source as (
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
    from {{ source('csv_data', 'PATIENTS') }} 
)

SELECT {{auto_cast ('PATIENTS')}} from source