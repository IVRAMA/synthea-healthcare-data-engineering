with 

source as (

    select * from {{ source('json_data', 'AllergyIntolerance') }}

)

select * from source