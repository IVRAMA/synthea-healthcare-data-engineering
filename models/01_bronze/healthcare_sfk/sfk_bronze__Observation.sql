with 

source as (

    select * from {{ source('json_data', 'Observation') }}

),

renamed as (

    select *

    from source

)

select * from renamed