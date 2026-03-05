{{ config(materialized='table') }}

WITH silver_data as (
select
    provider.id as provider_id,
    provider.name as provider_name,
    provider.organization as organization_id
from {{ ref('csv_bronze__providers') }} as provider
)

select * from silver_data
