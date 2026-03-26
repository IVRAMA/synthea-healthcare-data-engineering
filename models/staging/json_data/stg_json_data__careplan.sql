with 

source as (

    select * from {{ source('json_data', 'careplan') }}

),

renamed as (

    select

    from source

)

select * from renamed