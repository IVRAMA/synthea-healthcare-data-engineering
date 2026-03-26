{{ config(materialized='table') }}

WITH silver_data as (
select
claim_transaction_id
, "CLAIMID"
, "CHARGEID"
, "PATIENTID"
, claim_type
, claim_amount
, claim_method
, claim_fromdate
, claim_todate
, "PLACEOFSERVICE"
, "PROCEDURECODE"
, "MODIFIER1"
, "MODIFIER2"
, "DIAGNOSISREF1"
, "DIAGNOSISREF2"
, "DIAGNOSISREF3"
, "DIAGNOSISREF4"
, "UNITS"
, "DEPARTMENTID"
, "NOTES"
, "UNITAMOUNT"
, "TRANSFEROUTID"
, "TRANSFERTYPE"
, "PAYMENTS"
, "ADJUSTMENTS"
, "TRANSFERS"
, "OUTSTANDING"
, "APPOINTMENTID"
, "LINENOTE"
, "PATIENTINSURANCEID"
, "FEESCHEDULEID"
, "PROVIDERID"
, "SUPERVISINGPROVIDERID"
from {{ ref('csv_silver__claims_transactions') }}
)

select * from silver_data

