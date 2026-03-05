{{ config(
    materialized='table', 
    alias='bronze_immunizations'
) }}
with source as (
    select * from {{ source('csv_data', 'immunizations') }}
)

select
    {{ auto_cast('immunizations') }}
from source
