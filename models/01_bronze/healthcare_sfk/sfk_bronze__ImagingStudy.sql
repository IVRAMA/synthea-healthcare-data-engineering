with 

source as (

    select * from {{ source('json_data', 'ImagingStudy') }}

),

renamed as (

    select *

    from source

)

select * from renamed