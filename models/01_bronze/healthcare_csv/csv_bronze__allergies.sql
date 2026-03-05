{{ config(
    materialized='table', 
    alias='bronze_allergies'
) }}

with source as (
    select * from {{ source('csv_data', 'allergies') }}
)

select *
from source
