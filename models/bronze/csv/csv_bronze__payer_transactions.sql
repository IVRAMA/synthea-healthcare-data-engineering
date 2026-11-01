{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_payer_transactions'
) }}

with source as (
select 
    "PATIENT"
    ,"MEMBERID"
    ,"START_YEAR"
    ,"END_YEAR"
    ,"PAYER"
    ,"SECONDARY_PAYER"
    ,"OWNERSHIP"
    ,"OWNERNAME"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'PAYER_TRANSITIONS') }}
)

select {{auto_cast('PAYER_TRANSITIONS')}} from source