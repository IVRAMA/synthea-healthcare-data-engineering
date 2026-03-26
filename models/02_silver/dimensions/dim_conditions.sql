{{ config(materialized='table') }}

WITH silver_data as (
select
    condition_start
    , condition_stop
    , patient_id
    , encounter_id
    , condition_code
    , condition_Description
from {{ ref('csv_silver__conditions') }}
)

select * from silver_data
