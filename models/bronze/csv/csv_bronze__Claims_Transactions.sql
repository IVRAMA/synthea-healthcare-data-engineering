{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_Claims_Transactions'
) }}

with source as (
select 
    "ID"
    ,"CLAIMID"
    ,"CHARGEID"
    ,"PATIENTID"
    ,"TYPE"
    ,"AMOUNT"
    ,"METHOD"
    ,"FROMDATE"
    ,"TODATE"
    ,"PLACEOFSERVICE"
    ,"PROCEDURECODE"
    ,"MODIFIER1"
    ,"MODIFIER2"
    ,"DIAGNOSISREF1"
    ,"DIAGNOSISREF2"
    ,"DIAGNOSISREF3"
    ,"DIAGNOSISREF4"
    ,"UNITS"
    ,"DEPARTMENTID"
    ,"NOTES"
    ,"UNITAMOUNT"
    ,"TRANSFEROUTID"
    ,"TRANSFERTYPE"
    ,"PAYMENTS"
    ,"ADJUSTMENTS"
    ,"TRANSFERS"
    ,"OUTSTANDING"
    ,"APPOINTMENTID"
    ,"LINENOTE"
    ,"PATIENTINSURANCEID"
    ,"FEESCHEDULEID"
    ,"PROVIDERID"
    ,"SUPERVISINGPROVIDERID"
    ,"LOAD_TS"
  FROM {{ source('csv_data', 'CLAIMS_TRANSACTIONS') }}
)

select {{auto_cast('CLAIMS_TRANSACTIONS')}} from source