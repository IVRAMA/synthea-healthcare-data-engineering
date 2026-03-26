with 

source as (

    select * from {{ source('json_data', 'Condition') }}

),

renamed as (

    select *

    from source

)

select * from renamed