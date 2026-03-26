with 

source as (

    select * from {{ source('json_data', 'organization') }}

),

renamed as (

    select

    from source

)

select * from renamed