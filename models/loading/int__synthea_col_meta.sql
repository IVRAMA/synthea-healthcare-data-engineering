{{
    config(
        materialized='incremental',
        database = 'HDB', 
        schema = 'LOADING',
        unique_key='PATIENT_ID',
        incremental_strategy='merge'
    )
}}

with distinct_cols as (
    select distinct
        PATIENT_ID,
        FKEY,
        COLUMN_NAME,
        DATA_TYPE_L1,
        LOAD_TS
    from {{ ref('int__synthea_col_data') }}
    {% if is_incremental() %}
    where LOAD_TS > (select coalesce(max(LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)

select
    PATIENT_ID,
    max(LOAD_TS) as LOAD_TS,
    array_agg(
        object_construct(
            'TABLE', FKEY,
            'COLUMN', COLUMN_NAME,
            'DATATYPE', DATA_TYPE_L1
        )
    )::variant as COL_VAL
from distinct_cols
group by PATIENT_ID
