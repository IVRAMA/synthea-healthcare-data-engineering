{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='GOLD', 
    alias='encounter_summary'
) }}


WITH encounters AS (
    SELECT 
        id AS encounter_id
        , "START" AS encounter_start_time
        , stop AS encounter_stop_time
        , patient AS patient_id
        , organization 
        , provider
        , payer
        , encounterclass
        , code AS encounter_code
        , description AS encounter_description
        , reasoncode AS diagnosis_code
        , reasondescription AS diagnosis
        , base_encounter_cost
        , total_claim_cost
        , payer_coverage
        , load_ts AS load_time
    FROM  {{ ref('fact_encounters') }}
),

patients AS (
    SELECT 
        id
        , FIRST
        , MIDDLE
        , LAST
        , birthdate
        , ssn
        , city
        , state
    FROM {{ ref('dim_patients') }}
),

organizations AS (
    SELECT 
        id
        , name
    FROM {{ ref('dim_organizations') }}
),

providers AS (
    SELECT 
        id
        , name
    FROM {{ ref('dim_Providers') }}
),

payers AS (
    SELECT 
        id
        , name
        , ownership
        , amount_covered
    FROM {{ ref('dim_payers') }}
), 
dates AS 
(
    select
    GENERATED_DATE 
    , GENERATED_DATE_YEAR
    , GENERATED_DATE_MONTH
    , GENERATED_DATE_MONTH_NAME
    , GENERATED_DATE_WEEK_NAME
    , GENERATED_DATE_DAY
from {{ ref('dim_dates') }}
)
SELECT 
    e.encounter_id
    , e.encounter_start_time
    , e.encounter_stop_time
    , e.patient_id
    , e.organization 
    , e.provider
    , e.payer
    , e.encounterclass
    , e.encounter_code
    , e.encounter_description
    , e.diagnosis_code
    , e.diagnosis
    , e.base_encounter_cost
    , e.total_claim_cost
    , e.payer_coverage
    , e.load_time
    , CONCAT(p.FIRST, ' ', COALESCE(p.MIDDLE, ''), ' ', p.LAST) AS patient_name
    , p.birthdate
    , p.ssn
    , p.city
    , p.state
    , o.name AS organization_name
    , pv.name AS provider_name
    , py.name AS payer_name
    , py.ownership AS payer_owner
    , py.amount_covered AS payer_amount_covered
    , GENERATED_DATE_YEAR
    , GENERATED_DATE_MONTH
    , GENERATED_DATE_MONTH_NAME
    , GENERATED_DATE_WEEK_NAME
    , GENERATED_DATE_DAY
FROM encounters e
LEFT JOIN patients p 
    ON e.patient_id = p.id
LEFT JOIN organizations o 
    ON e.organization = o.id
LEFT JOIN providers pv 
    ON e.provider = pv.id
LEFT JOIN payers py 
    ON e.payer = py.id
LEFT JOIN dates dt 
    on e.encounter_start_time::date  = dt.GENERATED_DATE
