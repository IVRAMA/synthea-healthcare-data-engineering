SELECT 
    distinct patient_id as "id"
    , concat(PARSE_JSON(patient_name[0]):"prefix"[0]::varchar,PARSE_JSON(patient_name[0]):"family"::varchar) as given_name
    , PARSE_JSON("identifier"):"value"::varchar as Medical_Record_Number
    , birthDate
    , gender
    , PARSE_JSON(communication):"language":"coding"[0]:"code"::varchar as language_code
    , PARSE_JSON(communication):"language":"coding"[0]:"display"::varchar as lang
    , DECODE(PARSE_JSON(maritalStatus):"coding"[0]:"display", 'S', 'Single', 'M', 'Married') as maritalStatus
    , city
    , state
    , PARSE_JSON(address):"country"::varchar  as "country"
FROM 
    {{ ref('dbt_bronze__patients') }}
