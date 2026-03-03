{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'payer_transitions') }}
)

select
    {{ auto_cast('payer_transitions') }}
from source
