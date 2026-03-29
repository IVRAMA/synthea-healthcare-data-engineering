{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='Procedure_id',
    on_schema_change='append_new_columns',
    database='HDB',
    schema='BRONZE',
    alias='dbt_bronze_Procedure'
) }}

with cte_Procedure as
(select
    a.patient_id
    ,  f.value[0]:code as code
    ,  replace(replace(replace(replace(f.value[0]:encounter,'{"reference"',''),'urn:uuid:',')'),':")',''),'"}','')::string as encounter_id
    ,  f.value[0]:id::string as Procedure_id
    ,  f.value[0]:performedPeriod.end::timestamp as performedPeriod_end
    ,  f.value[0]:performedPeriod.start::timestamp as performedPeriod_start
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:subject::string as subject
from 
        {{ ref('synthea_flattened_l1') }} a  
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'Procedure'
)
select *  from cte_Procedure
