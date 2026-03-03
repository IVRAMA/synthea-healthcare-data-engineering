{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'careplans') }}
)

select
    {{ auto_cast('careplans') }}
from source
