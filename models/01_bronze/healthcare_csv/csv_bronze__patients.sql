{{ config(
    materialized='table', 
    alias='bronze_patients'
) }}

with source as (
    select * from {{ source('csv_data', 'patients') }}
)

select
    {{ auto_cast('patients') }}
from source
