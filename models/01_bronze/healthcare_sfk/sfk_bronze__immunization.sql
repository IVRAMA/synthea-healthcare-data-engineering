with 

source as (

    select * from {{ source('json_data', 'immunization') }}

),

renamed as (

    select *

    from source

)

select * from renamed