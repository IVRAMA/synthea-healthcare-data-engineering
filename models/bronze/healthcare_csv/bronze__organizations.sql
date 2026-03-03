{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'organizations') }}
)

select
    {{ auto_cast('organizations') }}
from source
