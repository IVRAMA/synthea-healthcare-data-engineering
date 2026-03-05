{{ config(
    materialized='table', 
    alias='bronze_conditions'
) }}

with source as (
    select * from {{ source('csv_data', 'conditions') }}
)

select
    {{ auto_cast('conditions') }}
from source
