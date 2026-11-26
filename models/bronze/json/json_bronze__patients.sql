{{ config (
    materialized='table',
    database='HJB',
    schema='BRONZE', 
    alias='json_bronze_patients'
) }}

with Social_security as
(
select  
    "id" as Pat_id
    , f.value:"type"."coding"[0]."code"::string as Pat_Identifier_code
    , f.value:"type"."text"::string as Pat_Identifier_Type
    , f.value:"value"::string as  Pat_Identifier_Value
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "identifier") f 
where 
    Pat_Identifier_code = 'SS'
)
, MR AS
(
select  
    "id" as Pat_id
    , f.value:"type"."coding"[0]."code"::string as Pat_Identifier_code
    , f.value:"type"."text"::string as Pat_Identifier_Type
    , f.value:"value"::string as  Pat_Identifier_Value
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "identifier") f 
where 
    Pat_Identifier_code = 'MR'
) 
, DL AS
(
select  
    "id" as Pat_id
    , f.value:"type"."coding"[0]."code"::string as Pat_Identifier_code
    , f.value:"type"."text"::string as Pat_Identifier_Type
    , f.value:"value"::string as  Pat_Identifier_Value
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "identifier") f 
where 
    Pat_Identifier_code = 'DL'
)
, PPN AS
(
select  
    "id" as Pat_id
    , f.value:"type"."coding"[0]."code"::string as Pat_Identifier_code
    , f.value:"type"."text"::string as Pat_Identifier_Type
    , f.value:"value"::string as  Pat_Identifier_Value
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "identifier") f 
where 
    Pat_Identifier_code = 'PPN'
)
, OName as 
(
select
    "id" as Pat_id
    , replace(replace(f.value:prefix,'["',''),'"]','') as prefix
    , f.value:given[0]::string as "first"
    , f.value:given[1]::string as "Middle"
    , f.value:family::string as "Last"
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "name") f 
where f.value:use::string = 'official'
)
, MName as
(select
    "id" as Pat_id
    , f.value:family::string as "Maiden"
from 
   {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "name") f 
where f.value:use::string = 'maiden'
)
, MarSts as
(
select
    "id" as Pat_id
    , f.value:code::string Marital_status
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "maritalStatus":"coding") f
)
, PRace as
(
select
    "id" as Pat_id
    , f.value:extension[1]:valueString::STRING AS race_text
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "extension") f
where 
    "id" = 'f9ba83f7-9940-16ae-0854-24bd34bf1843' and f.value:url::STRING = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
)
, Ethnic as
(
select
    "id" as Pat_id
    , f.value:extension[1]:valueString::STRING AS Ethnict
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "extension") f
where f.value:url::STRING = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity'
)
, BPlace as
(
select
    "id" as Pat_id
   , concat(f.value:"valueAddress":"city"::string,' ', f.value:"valueAddress":"state"::string)  BPlace
   , f.value:"valueAddress":"state"::string as state
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "extension") f
where f.value:url::STRING = 'http://hl7.org/fhir/StructureDefinition/patient-birthPlace'
)

, adrs1 AS
(
select
    "id"  as Pat_id
     , f.value:"city"::string as city
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "address", outer => TRUE) f
)
, adrs AS
(
    
select
    "id"  as Pat_id
    , replace(replace(f.value:"line",'["',''),'"]','' ) as adr 
from 
    {{ source('json_data', 'Patient') }} 
    , lateral flatten(input => "address", outer => TRUE) f
)
select 
    "id" AS  "ID"
    , "birthDate" AS "BIRTHDATE"
    , "deceasedDateTime" as "DEATHDATE"
    , ss.Pat_Identifier_Value as "SSN"  
    , DL.Pat_Identifier_Value as "DRIVERS"
    , PPN.Pat_Identifier_Value as "PASSPORT" 
    , prefix as "PREFIX"
    , "first" as "FIRST"
    , "Middle" as "MIDDLE"
    , "Last" as "LAST"
    , "Maiden" as "MAIDEN"
    , NULL AS "SUFFIX"
    , Marital_status as "MARITAL"
    , race_text as "RACE"
    , Ethnict as "ETHNICITY"
    , "gender" as "GENDER"
    , BPlace as "BIRTHPLACE"
    , adr as "ADDRESS"
    , city as "CITY"
    , state as "STATE"
    , null as "COUNTY"
    , null as "FIPS"
    , null as "ZIP"
    , null as "LAT"
    , null as "LON"
    , null as "HEALTHCARE_EXPENSES"
    , null as "HEALTHCARE_COVERAGE"
    , null as "INCOME"
    , pt.load_ts as "LOAD_TS"
from  
    {{ source('json_data', 'Patient') }}  pt 
    left join Social_security ss on pt."id" = ss.Pat_id
    left join MR on "id"    = MR.Pat_id
    left join DL on "id"    = DL.Pat_id
    left join PPN on "id"   = PPN.Pat_id
    left join OName on "id" = OName.Pat_id
    left join MName on "id" = MName.Pat_id
    left join MarSts on "id" = MarSts.Pat_id
    left join PRace on "id" = PRace.Pat_id
    left join Ethnic on "id" = Ethnic.Pat_id
    left join BPlace on "id" = BPlace.Pat_id
    left join adrs on "id" = adrs.Pat_id
    left join adrs1 on "id" = adrs1.Pat_id
