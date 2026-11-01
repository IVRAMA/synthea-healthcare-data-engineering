{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='dim_payers'
) }}

with csv_source as (
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
FROM 
 {{ ref('csv_bronze__payers') }} )

select *  from csv_source