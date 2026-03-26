{{ config(materialized='table') }}

WITH silver_data as (

select distinct
    immunization_date
    , patient_id
    , encounter_id
    , immunization_code
    , immunization_description
    , immunization_base_cost
from {{ ref('csv_silver__immunizations') }} as imm
)

select * from silver_data
