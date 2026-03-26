WITH silver_data as (

select distinct
    "DATE" as immunization_date
    , "PATIENT" as patient_id
    , "ENCOUNTER" as encounter_id
    , "CODE" as immunization_code
    , "DESCRIPTION" as immunization_description
    , "BASE_COST" as immunization_base_cost
from {{ ref('csv_bronze__immunizations') }} as imm
)

select * from silver_data
