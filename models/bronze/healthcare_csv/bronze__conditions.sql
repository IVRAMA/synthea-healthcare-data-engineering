{{ config(materialized='table') }}

with source as (
    select * from {{ source('csv_data', 'conditions') }}
)

select
    {{ auto_cast('conditions') }}
from source
