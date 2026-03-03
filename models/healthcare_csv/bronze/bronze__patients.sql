{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'patients') }}
)

select
    {{ auto_cast('patients') }}
from source
