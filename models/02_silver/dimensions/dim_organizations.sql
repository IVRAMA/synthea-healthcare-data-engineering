{{ config(materialized='table') }}
WITH silver_data as (
select
    id as organization_id,
    name as organization_name,
    address,
    city,
    state,
    zip
from {{ ref('csv_bronze__organizations') }}
)

select * from silver_data
