{{ config(
    materialized='table', 
    alias='bronze_organizations'
) }}

with source as (
    select * from {{ source('csv_data', 'organizations') }}
)

select
    {{ auto_cast('organizations') }}
from source
