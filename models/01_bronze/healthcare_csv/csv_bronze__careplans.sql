{{ config(
    materialized='table', 
    alias='bronze_careplans'
) }}

with source as (
    select * from {{ source('csv_data', 'careplans') }}
)

select
    {{ auto_cast('careplans') }}
from source
