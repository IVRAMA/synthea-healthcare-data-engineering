{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='GOLD'
) }}

select distinct
     e.ENCOUNTER_ID,
    e.PATIENT_ID,
    e.PROVIDER_ID,
    e."START_TIME"::date as encounter_start,
    e."STOP_TIME"::date as encounter_stop,
    dt.month_name,
    dt.week_of_year,
    dt.quarter, 
    observation_value,
    medication_code,
    medication_description,
    immunization_code,
    procedure_code
from
    {{ ref('dim_encounters') }} d 
inner join  
    {{ ref('fact_encounters') }} e
    on e.encounter_id = d.encounter_id
inner join {{ ref('dim_dates') }} dt
    on e."START_TIME"::date = dt.date_day
inner join {{ ref('fact_observations') }} o
    on d.encounter_id = o.ENCOUTER_ID
inner join {{ ref('fact_medications') }} m
    on d.encounter_id = m.ENCOUNTER_ID
inner join {{ ref('fact_immunizations') }} i
    on d.encounter_id = i.ENCOUNTER_ID
inner join {{ ref('fact_procedures') }} pr
     on d.encounter_id = pr.ENCOUNTER_ID
