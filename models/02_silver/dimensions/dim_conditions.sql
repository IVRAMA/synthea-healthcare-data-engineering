{{ config(materialized='table') }}

WITH silver_data as (
select
    "START" as condition_start
    , "STOP" as condition_stop
    , "PATIENT" as patient_id
    , ENCOUNTER as encounter_id
    , CODE as condition_code
    , "DESCRIPTION" as condition_Description
from {{ ref('csv_bronze__conditions') }}
)

select * from silver_data
