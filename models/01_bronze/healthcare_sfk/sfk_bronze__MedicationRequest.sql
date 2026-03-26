with 

source as (

    select * from {{ source('json_data', 'MedicationRequest') }}

),

renamed as (

    select *

    from source

)

select * from renamed