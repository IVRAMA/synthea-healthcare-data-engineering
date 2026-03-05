{{ config(
    materialized='table', 
    alias='bronze_providers'
) }}

with source as (
    select * from {{ source('csv_data', 'providers') }}
)

select
    {{ auto_cast('providers') }}
from source
