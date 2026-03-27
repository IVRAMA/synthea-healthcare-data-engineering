select
    distinct "id"
    , "occurrenceDateTime"::varchar  as "DATE"
    , replace("patient":"reference", 'urn:uuid:','')::varchar as PATIENT
    , replace("encounter":"reference", 'urn:uuid:','')::varchar  as ENCOUNTER
    , "vaccineCode":"coding"[0]:"code"::varchar as CODE
    , "vaccineCode":"coding"[0]:"display"::varchar as DESCRIPTION
    , 140.52::varchar as BASE_COST
FROM {{ ref('dbt_bronze__Immunization') }}