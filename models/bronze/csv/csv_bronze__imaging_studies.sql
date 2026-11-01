{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_imaging_studies'
) }}

with source as (
select 
    "ID"
    ,"DATE"
    ,"PATIENT"
    ,"ENCOUNTER"
    ,"SERIES_UID"
    ,"BODYSITE_CODE"
    ,"BODYSITE_DESCRIPTION"
    ,"MODALITY_CODE"
    ,"MODALITY_DESCRIPTION"
    ,"INSTANCE_UID"
    ,"SOP_CODE"
    ,"SOP_DESCRIPTION"
    ,"PROCEDURE_CODE"
    ,"LOAD_TS"
FROM {{ source('csv_data', 'IMAGING_STUDIES') }}
)

select {{auto_cast('IMAGING_STUDIES')}} from source