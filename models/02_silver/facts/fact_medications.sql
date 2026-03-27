{{ config(materialized='table') }}

WITH silver_data as (
(select
    "START" as medication_start_dt
    , "STOP" as medication_stop_dt
    , "PATIENT" as patient_id
    , "PAYER" as payer_id
    , "ENCOUNTER" as encounter_id
    , "BASE_COST" as medication_base_cost
    , "PAYER_COVERAGE" as payer_coverage
    , "DISPENSES" as DISPENSES
    , "TOTALCOST" as TOTALCOST
    , code as medication_code
    , "DESCRIPTION" medication_description
    , REASONCODE
    , REASONDESCRIPTION
from {{ ref('sfk_silver__medications') }})
union all
(select
    "START" as medication_start_dt
    , "STOP" as medication_stop_dt
    , "PATIENT" as patient_id
    , "PAYER" as payer_id
    , "ENCOUNTER" as encounter_id
    , "BASE_COST" as medication_base_cost
    , "PAYER_COVERAGE" as payer_coverage
    , "DISPENSES" as DISPENSES
    , "TOTALCOST" as TOTALCOST
    , code as medication_code
    , "DESCRIPTION" medication_description
    , REASONCODE
    , REASONDESCRIPTION
from {{ ref('dbt_silver__medications') }})

)

select * from silver_data



