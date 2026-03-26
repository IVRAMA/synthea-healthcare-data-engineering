with 

source as (

    select * from {{ source('json_data', 'Encounter') }}

),

renamed as (

    select *

    from source

)

select * from renamed