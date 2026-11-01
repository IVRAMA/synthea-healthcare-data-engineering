{{ config (
    materialized='table',
    database='HCB',
    schema='BRONZE', 
    alias='csv_bronze_Claims'
) }}

with source as (
select 
    "ID"
    ,"PATIENTID"
    ,"PROVIDERID"
    ,"PRIMARYPATIENTINSURANCEID"
    ,"SECONDARYPATIENTINSURANCEID"
    ,"DEPARTMENTID"
    ,"PATIENTDEPARTMENTID"
    ,"DIAGNOSIS1"
    ,"DIAGNOSIS2"
    ,"DIAGNOSIS3"
    ,"DIAGNOSIS4"
    ,"DIAGNOSIS5"
    ,"DIAGNOSIS6"
    ,"DIAGNOSIS7"
    ,"DIAGNOSIS8"
    ,"REFERRINGPROVIDERID"
    ,"APPOINTMENTID"
    ,"CURRENTILLNESSDATE"
    ,"SERVICEDATE"
    ,"SUPERVISINGPROVIDERID"
    ,"STATUS1"
    ,"STATUS2"
    ,"STATUSP"
    ,"OUTSTANDING1"
    ,"OUTSTANDING2"
    ,"OUTSTANDINGP"
    ,"LASTBILLEDDATE1"
    ,"LASTBILLEDDATE2"
    ,"LASTBILLEDDATEP"
    ,"HEALTHCARECLAIMTYPEID1"
    ,"HEALTHCARECLAIMTYPEID2"
    ,"LOAD_TS"
  FROM {{ source('csv_data', 'CLAIMS') }}
)

select {{auto_cast('CLAIMS')}} from source