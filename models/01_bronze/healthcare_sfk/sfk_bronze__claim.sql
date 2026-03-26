with 

source as (

    select * from {{ source('json_data', 'claim') }}

),

renamed as (

    select

    from source

)

select * from renamed