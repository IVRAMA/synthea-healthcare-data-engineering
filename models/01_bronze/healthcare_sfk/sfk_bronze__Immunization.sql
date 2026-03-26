with 

source as (

    select * from {{ source('json_data', 'Immunization') }}

),

renamed as (

    select *

    from source

)

 SELECT
     * from renamed