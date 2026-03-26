with 

source as (

    select * from {{ source('json_data', 'explanationofbenefit') }}

),

renamed as (

    select *

    from source

)

select * from renamed