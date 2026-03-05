{{ config(
    materialized='table', 
    alias='bronze_imaging_studies'
) }}

with source as (
    select * from {{ source('csv_data', 'imaging_studies') }}
)

select
    {{ auto_cast('imaging_studies') }}
from source
