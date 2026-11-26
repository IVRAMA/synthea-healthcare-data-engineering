{% macro unpack_fhir_staging(resource_name) %}

{% set cols_query %}
    select distinct COLUMN_NAME, COLUMN_DATA_TYPE
    from {{ ref('synthea_flattened_l2') }}
    where TABLE_NAME = '{{ resource_name }}'
    order by COLUMN_NAME
{% endset %}

{% if execute %}
    {% set results = run_query(cols_query) %}
    {% set col_list = results.rows %}
{% else %}
    {% set col_list = [] %}
{% endif %}

select
    L.PATIENT_ID,
    L.LOAD_TS,
    current_timestamp()::timestamp_ntz as DBT_LOAD_TS
    {%- for row in col_list %},
    O.VALUE:"{{ row['COLUMN_NAME'] }}"::{{ row['COLUMN_DATA_TYPE'] }} as "{{ row['COLUMN_NAME'] }}"
    {%- endfor %}
from {{ ref('synthea_flattened_l1') }} L,
     lateral flatten(input => L.CLINICAL_JSON:{{ resource_name }}) O
where array_contains('{{ resource_name }}'::variant, L.PAT_TABLES)
{% if is_incremental() %}
  and L.LOAD_TS > (select coalesce(max(LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
{% endif %}

{% endmacro %}
