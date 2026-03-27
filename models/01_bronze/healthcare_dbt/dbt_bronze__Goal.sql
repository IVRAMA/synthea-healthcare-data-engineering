{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Goal_id',
    on_schema_change='append_new_columns',
    database='HDB',
    schema='BRONZE', 
    alias='dbt_bronze_Goal'
) }}

with cte_Goal as
(select
    a.patient_id
   ,  f.value[0]:achievementStatus::string as achievementStatus
    ,  f.value[0]:description::string as description
    ,  f.value[0]:id::string as Goal_id
    ,  f.value[0]:lifecycleStatus::string as lifecycleStatus
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:subject::string as subject
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Goal'
)
select * from cte_Goal
