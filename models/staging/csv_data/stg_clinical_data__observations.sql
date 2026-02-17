{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='stg_observations'
) }}

with raw_observations AS
(
    select * from {{ source('clinical_data', 'observations') }}
)
select
TO_TIMESTAMP_NTZ("DATE") as OBSERVATION_DT,
"PATIENT",
"ENCOUNTER",
"CATEGORY",
"CODE",
"DESCRIPTION",
"VALUE",
"UNITS",
"TYPE"
FROM  raw_observations