{{ config(
    materialized='table', 
    alias='bronze_payers'
) }}


with source as (
    select * from {{ source('csv_data', 'payers') }}
)

select
    {{ auto_cast('payers') }}
from source
