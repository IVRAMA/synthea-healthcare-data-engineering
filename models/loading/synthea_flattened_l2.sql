{{
    config(
        materialized='incremental',
        database = 'HDB', 
        schema = 'LOADING',
        unique_key=['TABLE_NAME', 'COLUMN_NAME'],
        incremental_strategy='merge'
    )
}}

with l1_delta as (
    select
        COL_META,
        LOAD_TS
    from {{ ref('synthea_flattened_l1') }}
    {% if is_incremental() %}
    where LOAD_TS > (select coalesce(max(LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)

select
    f.value:TABLE::string as TABLE_NAME,
    f.value:COLUMN::string as COLUMN_NAME,
    max_by(f.value:DATATYPE::string, l.LOAD_TS) as COLUMN_DATA_TYPE,
    max(l.LOAD_TS) as LOAD_TS,
    current_timestamp()::timestamp_ntz as DBT_LOAD_TS
from l1_delta l,
     lateral flatten(input => l.COL_META) f
group by
    f.value:TABLE::string,
    f.value:COLUMN::string
