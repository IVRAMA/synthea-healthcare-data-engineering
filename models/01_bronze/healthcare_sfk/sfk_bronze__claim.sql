with 

source as (

    select * from {{ source('json_data', 'Claim') }}

),

renamed as (

    select *

    from source

)

select * from renamed