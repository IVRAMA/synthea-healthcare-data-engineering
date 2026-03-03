{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'encounters') }}
)

select
    {{ auto_cast('encounters') }}
from source
