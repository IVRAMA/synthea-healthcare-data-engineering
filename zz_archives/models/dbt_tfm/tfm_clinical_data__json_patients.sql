{{ config(
    materialized='table',
    database='HEALTHCARE_ANALYTICS',
    schema='BRONZE', 
    alias='tfm_json_Patients'
) }}

WITH raw_patients as (
select 
    patient_id as "id"
    , concat("PATIENT_NAME"[0]:"prefix"[0]::varchar,"PATIENT_NAME"[0]:"family"::varchar) as given_name
    , "identifier":"value"::varchar as Medical_Record_Number
    , BIRTHDATE
    , GENDER
    , PARSE_JSON("COMMUNICATION"):"language":"coding"[0]:"code"::varchar as language_code
    , PARSE_JSON("COMMUNICATION"):"language":"coding"[0]:"display"::varchar as lang
    , DECODE("MARITALSTATUS":"coding"[0]:"display", 'S', 'Single', 'M', 'Married') as maritalStatus
    , CITY
    , STATE
    , 'US' AS COUNTRY
from {{ ref('silver_patients') }}
)

SELECT *  FROM raw_patients


