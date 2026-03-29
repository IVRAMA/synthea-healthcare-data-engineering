SELECT 
    distinct "id"
    , concat("name"[0]:"prefix"[0]::varchar,"name"[0]:"family"::varchar) as given_name
    , "identifier"[0]:"value"::varchar as Medical_Record_Number
    , "birthDate"
    , "gender"
    , "communication"[0]:"language":"coding"[0]:"code"::varchar as language_code
    , "communication"[0]:"language":"coding"[0]:"display"::varchar as lang
    , DECODE("maritalStatus":"coding"[0]:"display", 'S', 'Single', 'M', 'Married') as maritalStatus
    , "address"[0]:"city"::varchar  as "city"
    , "address"[0]:"state"::varchar  as "state"
    , "address"[0]:"country"::varchar  as "country"
FROM 
    {{ ref('sfk_bronze__Patient') }}
