with 

source as (

    select * from {{ source('json_data', 'DiagnosticReport') }}

),

renamed as (

    select *

    from source

)

select * from renamed