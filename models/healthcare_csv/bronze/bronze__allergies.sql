{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'allergies') }}
)

select *
from source
