select
    distinct Immunization_id as "id"
    , occurrenceDateTime::varchar  as "DATE"
    , replace(PARSE_JSON(patient):"reference", 'urn:uuid:','')::varchar as PATIENT
    , encounter_id  as ENCOUNTER
    , PARSE_JSON(vaccineCode):"coding"[0]:"code"::varchar as CODE
    , PARSE_JSON(vaccineCode):"coding"[0]:"display"::varchar as DESCRIPTION
    , 140.52::varchar as BASE_COST
from {{ ref('dbt_bronze__Immunization') }}