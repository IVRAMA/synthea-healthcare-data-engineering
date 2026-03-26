with 

source as (

    select * from {{ source('json_data', 'Organization') }}

),

renamed as (

    select *

    from source

)

select * from renamed