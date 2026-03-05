{{ config(materialized='table') }}

WITH silver_data as (

select distinct
    med.code as medication_code,
    med.description,
    med.REASONCODE,
    med.REASONDESCRIPTION
from {{ ref('csv_bronze__medications') }} as med)

select * from silver_data
