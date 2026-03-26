with 

source as (

    select * from {{ source('json_data', 'practitioner') }}

),

renamed as (

    select

    from source

)

select * from renamed