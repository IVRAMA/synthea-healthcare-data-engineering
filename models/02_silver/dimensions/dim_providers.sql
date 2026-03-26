{{ config(materialized='table') }}

WITH silver_data as (
select
    provider_id,
    provider_name,
    organization_id
from {{ ref('csv_silver__providers') }} as provider
)

select * from silver_data
