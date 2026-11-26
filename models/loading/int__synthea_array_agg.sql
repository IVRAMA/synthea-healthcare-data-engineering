{{
    config(
        materialized='incremental',
        database = 'HDB', 
        schema = 'LOADING',
        unique_key=['PATIENT_ID', 'FKEY'],
        incremental_strategy='merge'
    )
}}

select
    PATIENT_ID,
    max(LOAD_TS) as LOAD_TS,
    FKEY,
    cast(array_agg(FVAL) as variant) as FVAL
from {{ ref('int__synthea_tab_data') }}
{% if is_incremental() %}
where LOAD_TS > (select coalesce(max(LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
{% endif %}
group by PATIENT_ID, FKEY
