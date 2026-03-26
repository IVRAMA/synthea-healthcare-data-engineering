with 

source as (

    select * from {{ source('json_data', 'condition') }}

),

renamed as (

    select

    from source

)

select * from renamed