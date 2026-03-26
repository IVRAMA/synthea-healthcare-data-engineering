with 

source as (

    select * from {{ source('json_data', 'observation') }}

),

renamed as (

    select *

    from source

)

select * from renamed