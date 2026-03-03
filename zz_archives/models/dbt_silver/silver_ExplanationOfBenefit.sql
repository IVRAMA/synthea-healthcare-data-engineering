{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ExplanationOfBenefit_id',
    on_schema_change='append_new_columns',
    database='HEALTHCARE_RAW',
    schema='DBT_SILVER', 
    alias='silver_ExplanationOfBenefit'
) }}

with cte_ExplanationOfBenefit as
(select
    a.patient_id
    ,  f.value[0]:billablePeriod.start::timestamp as billablePeriod_start_dt
    ,  f.value[0]:billablePeriod.end::timestamp as billablePeriod_end_dt
    ,  f.value[0]:careTeam[0]::string as careTeam
    ,  f.value[0]:claim::string as claim
    ,  f.value[0]:contained[0]::string as contained
    ,  f.value[0]:created::timestamp as created
    ,  f.value[0]:id::string as ExplanationOfBenefit_id
    ,  f.value[0]:identifier[0]::string as identifier
    ,  f.value[0]:insurance[0]::string as insurance
    ,  f.value[0]:insurer::string as insurer
    ,  f.value[0]:item[0]::string as item
    ,  f.value[0]:outcome::string as outcome
    ,  f.value[0]:patient::string as patient
    ,  f.value[0]:payment::string as payment
    ,  f.value[0]:provider::string as provider
    ,  f.value[0]:referral::string as referral
    ,  f.value[0]:resourceType::string as resourceType
    ,  f.value[0]:status::string as status
    ,  f.value[0]:total[0]::string as total
    ,  f.value[0]:type::string as type
    ,  f.value[0]:use::string as use
from 
    {{ ref('synthea_flattened_l1') }} a 
    , lateral flatten (input =>  CLINICAL_JSON) f
where f.key = 'ExplanationOfBenefit'
)
select * from cte_ExplanationOfBenefit
