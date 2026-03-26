with 

source as (

    select * from {{ source('json_data', 'ExplanationOfBenefit') }}

),

renamed as (

    select *

    from source

)

select * from renamed