{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='SILVER'
) }}

select distinct
    med.code as medication_code,
    med.description,
    med.REASONCODE,
    med.REASONDESCRIPTION
from {{ ref('stg_clinical_data__medications') }} as med