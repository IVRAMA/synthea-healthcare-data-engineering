{{
    config(
        materialized='incremental',
        database = 'HDB', 
        schema = 'LOADING'
    )
}}

select
    raw:entry[0].fullUrl::string as PATIENT_ID,
    LOAD_TS,
    f.value:resource:resourceType::string as FKEY,
    g.key::string as COLUMN_NAME,
    typeof(g.value)::string as DATA_TYPE_L1
from {{ source('dbt_data', 'MASTER_JSON') }},
     lateral flatten(input => raw:entry) f,
     lateral flatten(input => f.value:resource) g
{% if is_incremental() %}
where LOAD_TS > (select coalesce(max(LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
{% endif %}
