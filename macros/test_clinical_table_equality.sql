{% test clinical_table_equality(model, compare_table, compare_database='HJB', compare_schema='STAGING', exclude_cols=['LOAD_TS', 'DBT_LOAD_TS', 'BATCH_NO', 'PATIENT_ID']) %}

{% set cols = adapter.get_columns_in_relation(model) %}
{% set compare_cols = [] %}
{% for col in cols %}
    {% if col.name.upper() not in exclude_cols %}
        {% do compare_cols.append('"' ~ col.name ~ '"') %}
    {% endif %}
{% endfor %}

{% set col_list_str = compare_cols | join(', ') %}
{% set target_table = compare_database ~ '.' ~ compare_schema ~ '."' ~ compare_table ~ '"' %}

with a_minus_b as (
    select {{ col_list_str }} from {{ model }}
    minus
    select {{ col_list_str }} from {{ target_table }}
),
b_minus_a as (
    select {{ col_list_str }} from {{ target_table }}
    minus
    select {{ col_list_str }} from {{ model }}
)

select * from a_minus_b
union all
select * from b_minus_a

{% endtest %}
