{{ config(
    materialized='table', 
    alias='bronze_medications'
) }}

with source as (
    select * from {{ source('csv_data', 'medications') }}
)

select
    {{ auto_cast('medications') }}
from source
