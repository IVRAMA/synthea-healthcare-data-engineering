with 

source as (

    select * from {{ source('json_data', 'AllergyIntolerance') }}

),

renamed as (

    select *

    from source

)

select * from renamed