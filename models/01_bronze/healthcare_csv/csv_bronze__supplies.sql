{{ config(
    materialized='table', 
    alias='bronze_supplies'
) }}

with source as (
    select * from {{ source('csv_data', 'supplies') }}
)

select
    {{ auto_cast('supplies') }}
from source
