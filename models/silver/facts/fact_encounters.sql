{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='fact_encounters'
) }}

with csv_source as (

    select "ID" 
    ,"START" 
    ,"STOP" 
    ,"PATIENT" 
    ,"ORGANIZATION" 
    ,"PROVIDER" 
    ,"PAYER" 
    ,"ENCOUNTERCLASS" 
    ,"CODE" 
    ,"DESCRIPTION" 
    ,"BASE_ENCOUNTER_COST" 
    ,"TOTAL_CLAIM_COST" 
    ,"PAYER_COVERAGE" 
    ,"REASONCODE" 
    ,"REASONDESCRIPTION" 
    , "LOAD_TS"
from {{ ref('csv_bronze__encounters') }}
 {% if is_incremental() %}
   WHERE LOAD_TS > (SELECT MAX(load_ts) FROM {{ this }})
{% endif %}
)
SELECT *  from csv_source