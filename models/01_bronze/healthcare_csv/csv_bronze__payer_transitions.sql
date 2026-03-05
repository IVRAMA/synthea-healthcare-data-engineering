{{ config(
    materialized='table', 
    alias='bronze_payer_transitions'
) }}


with source as (
    select * from {{ source('csv_data', 'payer_transitions') }}
)

select
    {{ auto_cast('payer_transitions') }}
from source
