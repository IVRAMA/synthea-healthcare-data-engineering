with 

source as (

    select * from {{ source('json_data', 'Patient') }}

),

renamed as (

    select *

    from source

)

select * from renamed