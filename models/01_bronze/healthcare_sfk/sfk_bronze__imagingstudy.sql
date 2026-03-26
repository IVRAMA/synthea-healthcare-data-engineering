with 

source as (

    select * from {{ source('json_data', 'imagingstudy') }}

),

renamed as (

    select

    from source

)

select * from renamed