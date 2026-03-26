{{ config(materialized='table') }}

WITH silver_data as (
select distinct
    supply_code,
    sup.description
from {{ ref('csv_silver__supplies') }} as sup
)

select * from silver_data

