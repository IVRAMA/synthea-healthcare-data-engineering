with 

source as (

    select * from {{ source('json_data', 'CarePlan') }}

),

renamed as (

    select *

    from source

)

select * from renamed