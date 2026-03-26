with 

source as (

    select * from {{ source('json_data', 'goal') }}

),

renamed as (

    select *

    from source

)

select * from renamed