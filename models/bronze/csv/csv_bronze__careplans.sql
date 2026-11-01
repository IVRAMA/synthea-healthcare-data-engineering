{{
    config(
        materialized = 'table',
        database = 'HCB',
        schema ='BRONZE',
        alias = 'csv_bronze_careplans'
    )
}}

with source as (
    select 
        "ID"
        ,"START"
        ,"STOP"
        ,"PATIENT"
        ,"ENCOUNTER"
        ,"CODE"
        ,"DESCRIPTION"
        ,"REASONCODE"
        ,"REASONDESCRIPTION"
        ,"LOAD_TS"
    from {{ source('csv_data', 'CAREPLANS') }}
    )

    SELECT {{auto_cast ('CAREPLANS')}} from source