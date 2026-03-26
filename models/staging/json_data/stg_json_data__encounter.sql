with 

source as (

    select * from {{ source('json_data', 'encounter') }}

),

renamed as (

    select

    from source

)

select * from renamed