{{
    config(
        materialized='incremental',
        database = 'HDB', 
        schema = 'LOADING',
        unique_key='PATIENT_ID',
        incremental_strategy='merge'
    )
}}

select
    a.PATIENT_ID,
    greatest(a.LOAD_TS, c.LOAD_TS) as LOAD_TS,
    array_agg(a.FKEY) as PAT_TABLES,
    max(c.COL_VAL) as COL_META,
    object_agg(a.FKEY, a.FVAL) as CLINICAL_JSON,
    current_timestamp()::timestamp_ntz as DBT_LOAD_TS
from {{ ref('int__synthea_array_agg') }} a
join {{ ref('int__synthea_col_meta') }} c
    on a.PATIENT_ID = c.PATIENT_ID
{% if is_incremental() %}
where a.LOAD_TS > (select coalesce(max(LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
{% endif %}
group by a.PATIENT_ID, greatest(a.LOAD_TS, c.LOAD_TS)
