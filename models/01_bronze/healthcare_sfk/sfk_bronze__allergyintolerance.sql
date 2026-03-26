with 

source as (

    select * from {{ source('json_data', 'allergyintolerance') }}

),

renamed as (

    select *

    from source

)

select * from renamed