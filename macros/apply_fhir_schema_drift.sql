{% macro apply_fhir_schema_drift() %}
  {% if execute %}
    {% set l2_relation = adapter.get_relation(database='HDB', schema='LOADING', identifier='SYNTHEA_FLATTENED_L2') %}
    {% if l2_relation is not none %}
      {% set drift_query %}
        select
          l2.TABLE_NAME,
          l2.COLUMN_NAME,
          l2.COLUMN_DATA_TYPE
        from HDB.LOADING.SYNTHEA_FLATTENED_L2 l2
        join HDB.INFORMATION_SCHEMA.TABLES t
          on t.TABLE_SCHEMA = 'STAGING'
         and t.TABLE_NAME = l2.TABLE_NAME
        left join HDB.INFORMATION_SCHEMA.COLUMNS c
          on c.TABLE_SCHEMA = 'STAGING'
         and c.TABLE_NAME = l2.TABLE_NAME
         and c.COLUMN_NAME = l2.COLUMN_NAME
        where c.COLUMN_NAME is null
      {% endset %}

      {% set new_cols = run_query(drift_query) %}
      {% for row in new_cols %}
        {% set alter_sql %}
          alter table HDB.STAGING."{{ row['TABLE_NAME'] }}"
          add column if not exists "{{ row['COLUMN_NAME'] }}" {{ row['COLUMN_DATA_TYPE'] }};
        {% endset %}
        {% do run_query(alter_sql) %}
      {% endfor %}
    {% endif %}
  {% endif %}
{% endmacro %}
