WITH silver_data as (
select distinct
    sup.code as supply_code,
    sup.description
from {{ ref('csv_bronze__supplies') }} as sup
)

select * from silver_data