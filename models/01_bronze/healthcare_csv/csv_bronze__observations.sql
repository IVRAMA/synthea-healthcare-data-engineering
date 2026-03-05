{{ config(
    materialized='table', 
    alias='bronze_observations'
) }}

with source as (
    select * from {{ source('csv_data', 'observations') }}
)

select
    {{ auto_cast('observations') }}
from source
