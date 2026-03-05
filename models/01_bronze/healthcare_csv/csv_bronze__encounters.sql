{{ config(
    materialized='table', 
    alias='bronze_encounters'
) }}

with source as (
    select * from {{ source('csv_data', 'encounters') }}
)

select
    {{ auto_cast('encounters') }}
from source
