with 

source as (

    select * from {{ source('json_data', 'Immunization') }}

),

renamed as (

    select *

    from source

)

select SELECT
    TO_TIMESTAMP_NTZ("DATE") AS "DATE",
    "PATIENT" AS "PATIENT",
    "ENCOUNTER" AS "ENCOUNTER",
    TO_NUMBER("CODE") AS "CODE",
    "DESCRIPTION" AS "DESCRIPTION",
    TRY_TO_DOUBLE("BASE_COST") AS "BASE_COST" from renamed