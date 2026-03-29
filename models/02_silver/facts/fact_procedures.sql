{{ config(materialized='table') }}

WITH silver_data as (
(
    select 
        PROCEDURE_START
        , PROCEDURE_STOP
        , PATIENT_ID
        , ENCOUNTER_ID
        , PROCEDURE_CODE
        , PROCEDURE_DESCRIPTION
        , PROCEDURE_BASE_COST
        , PROCEDURE_REASONCODE
        , PROCEDURE_REASONDESCRIPTION
    from 
        {{ ref('csv_silver__procedures') }}
)
union all
(
    select 
        "START" AS PROCEDURE_START
        , "STOP" AS PROCEDURE_STOP
        , "PATIENT" AS PATIENT_ID
        , "ENCOUNTER" AS ENCOUNTER_ID
        , "CODE" AS PROCEDURE_CODE
        , "DESCRIPTION" AS PROCEDURE_DESCRIPTION
        , "BASE_COST" AS PROCEDURE_BASE_COST
        , "REASONCODE" AS PROCEDURE_REASONCODE
        , "REASONDESCRIPTION" AS PROCEDURE_REASONDESCRIPTION
    from 
        {{ ref('sfk_silver__procedures') }})
union all
(
    select 
        "START" AS PROCEDURE_START
        , "STOP" AS PROCEDURE_STOP
        , "PATIENT" AS PATIENT_ID
        , "ENCOUNTER" AS ENCOUNTER_ID
        , "CODE" AS PROCEDURE_CODE
        , "DESCRIPTION" AS PROCEDURE_DESCRIPTION
        , "BASE_COST" AS PROCEDURE_BASE_COST
        , "REASONCODE" AS PROCEDURE_REASONCODE
        , "REASONDESCRIPTION" AS PROCEDURE_REASONDESCRIPTION
    from 
        {{ ref('dbt_silver__procedures') }}
)
)
select * from silver_data

