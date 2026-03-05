{{ config(
    materialized='table', 
    alias='bronze_claims_transactions'
) }}


with source as (
    select * from {{ source('csv_data', 'claims_transactions') }}
)

select
    {{ auto_cast('claims_transactions') }}
from source
