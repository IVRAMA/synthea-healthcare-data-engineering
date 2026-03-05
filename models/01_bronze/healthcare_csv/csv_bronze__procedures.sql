{{ config(
    materialized='table', 
    alias='bronze_procedures'
) }}


with source as (
    select * from {{ source('csv_data', 'procedures') }}
)

select
    {{ auto_cast('procedures') }}
from source
