{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_payers'
) }}

with source as (
select 
    "ID"
    ,"NAME"
    ,"OWNERSHIP"
    ,"ADDRESS"
    ,"CITY"
    ,"STATE_HEADQUARTERED"
    ,"ZIP"
    ,"PHONE"
    ,"AMOUNT_COVERED"
    ,"AMOUNT_UNCOVERED"
    ,"REVENUE"
    ,"COVERED_ENCOUNTERS"
    ,"UNCOVERED_ENCOUNTERS"
    ,"COVERED_MEDICATIONS"
    ,"UNCOVERED_MEDICATIONS"
    ,"COVERED_PROCEDURES"
    ,"UNCOVERED_PROCEDURES"
    ,"COVERED_IMMUNIZATIONS"
    ,"UNCOVERED_IMMUNIZATIONS"
    ,"UNIQUE_CUSTOMERS"
    ,"QOLS_AVG"
    ,"MEMBER_MONTHS"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'PAYERS') }}
)

select {{auto_cast('PAYERS')}} from source