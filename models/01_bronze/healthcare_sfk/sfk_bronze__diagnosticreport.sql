with 

source as (

    select * from {{ source('json_data', 'diagnosticreport') }}

),

renamed as (

    select *

    from source

)

select * from renamed