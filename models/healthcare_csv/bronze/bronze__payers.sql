{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'payers') }}
)

select
    {{ auto_cast('payers') }}
from source
