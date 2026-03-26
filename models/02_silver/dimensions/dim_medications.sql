{{ config(materialized='table') }}

WITH silver_data as (

select distinct
    med.medication_code,
    med.description,
    med.REASONCODE,
    med.REASONDESCRIPTION
from {{ ref('csv_silver__medications') }} as med)

select * from silver_data
