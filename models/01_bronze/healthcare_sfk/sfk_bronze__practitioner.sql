with 

source as (

    select * from {{ source('json_data', 'Practitioner') }}

),

renamed as (

    select *

    from source

)

select * from renamed