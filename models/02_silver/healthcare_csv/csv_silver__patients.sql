WITH silver_data as (
select
"ID"
    , "BIRTHDATE"
    , "DEATHDATE"
    , "SSN"
    , "DRIVERS"
    , "PASSPORT"
    , "PREFIX"
    , "FIRST"
    , "LAST"
    , "SUFFIX"
    , "MAIDEN"
    , "MARITAL"
    , "RACE"
    , "ETHNICITY"
    , "GENDER"
    , "BIRTHPLACE"
    , "ADDRESS"
    , "CITY"
    , "STATE"
    , "COUNTY"
    , "ZIP"
    , "HEALTHCARE_EXPENSES"
    , "HEALTHCARE_COVERAGE"
from {{ ref('csv_bronze__patients') }}
)

select * from silver_data