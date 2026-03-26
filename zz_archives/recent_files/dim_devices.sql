{{ config(materialized='table') }}

WITH silver_data as (
select distinct
    "START" as  device_Start
    , "STOP"  as  device_stop
    , "PATIENT" as  patient_id
    , "ENCOUNTER" as encounter_id
    , "CODE" as  device_code
    , "DESCRIPTION" as  device_description
    , "UDI" as  device_udi
from {{ ref('csv_silver__devices') }})

select * from silver_data

