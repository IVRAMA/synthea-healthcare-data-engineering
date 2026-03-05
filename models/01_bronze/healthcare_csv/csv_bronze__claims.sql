{{ config(
    materialized='table', 
    alias='bronze_claims'
) }}

with source as (
    select * from {{ source('csv_data', 'claims') }}
)

select
    {{ auto_cast('claims') }}
from source
