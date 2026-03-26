with 

source as (

    select * from {{ source('json_data', 'Immunization') }}

),

renamed as (

    select *

    from source

)

select * from renamed