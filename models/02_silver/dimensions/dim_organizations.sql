{{ config(materialized='table') }}
WITH silver_data as (
select
    organization_id,
    organization_name,
    address,
    city,
    state,
    zip
from {{ ref('csv_silver__organizations') }}
)

select * from silver_data
