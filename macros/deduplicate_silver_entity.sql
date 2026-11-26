{% macro deduplicate_silver_entity(
    sources,
    unique_key,
    columns,
    allow_null_overwrite_cols=[],
    ts_col='LOAD_TS'
) %}

{% set all_cols = [unique_key] + columns %}

with
{% for src in sources %}
src_{{ loop.index }} as (
    select
        {% for col in all_cols %}
        "{{ col }}",
        {% endfor %}
        {{ ts_col }} as SOURCE_LOAD_TS,
        '{{ src }}' as SOURCE_SYSTEM
    from {{ ref(src) }}
    {% if is_incremental() %}
    where {{ ts_col }} > (select coalesce(max(SOURCE_LOAD_TS), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
),
{% endfor %}

new_arrivals as (
    {% for src in sources %}
    select * from src_{{ loop.index }}
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
),

{% if is_incremental() %}
existing_records as (
    select
        {% for col in all_cols %}
        t."{{ col }}",
        {% endfor %}
        t.SOURCE_LOAD_TS,
        t.LATEST_SOURCE_SYSTEM as SOURCE_SYSTEM
    from {{ this }} t
    where t."{{ unique_key }}" in (
        select distinct "{{ unique_key }}" from new_arrivals
    )
),
{% endif %}

unified_stream as (
    select * from new_arrivals
    {% if is_incremental() %}
    union all
    select * from existing_records
    {% endif %}
)

select
    "{{ unique_key }}",
    {% for col in columns %}
        {% if col in allow_null_overwrite_cols %}
        max_by("{{ col }}", SOURCE_LOAD_TS) as "{{ col }}",
        {% else %}
        max_by("{{ col }}", iff("{{ col }}" is not null, SOURCE_LOAD_TS, null)) as "{{ col }}",
        {% endif %}
    {% endfor %}
    max_by(SOURCE_SYSTEM, SOURCE_LOAD_TS) as LATEST_SOURCE_SYSTEM,
    max(SOURCE_LOAD_TS) as SOURCE_LOAD_TS,
    current_timestamp() as DBT_LOAD_TS
from unified_stream
group by "{{ unique_key }}"

{% endmacro %}
