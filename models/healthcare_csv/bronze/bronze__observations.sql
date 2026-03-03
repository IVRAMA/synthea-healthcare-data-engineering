{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'observations') }}
)

select
    {{ auto_cast('observations') }}
from source
