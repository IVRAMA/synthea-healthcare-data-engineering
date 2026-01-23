{% macro generate_clinical_tables() %}
  -- Extract unique table/column metadata
  {% set metadata_query %}
    SELECT DISTINCT 
      TABLE_NAME,
      COLUMN_NAME,
      COLUMN_DATA_TYPE
    FROM {{ ref('SYNTHEA_FLATTENED_L2') }}
    WHERE TABLE_NAME IS NOT NULL AND COLUMN_NAME IS NOT NULL
  {% endset %}
  
  {% set results = run_query(metadata_query) %}
  {% set tables = {} %}
  
  -- Group columns by table
  {% for row in results.rows %}
    {% set table_name = row[0] %}
    {% if not tables[table_name] %}
      {% do tables.update({table_name: []}) %}
    {% endif %}
    {% do tables[table_name].append({'name': row[1], 'type': row[2]}) %}
  {% endfor %}
  
  -- Generate CREATE TABLE for each
  {% for table_name, cols in tables.items() %}
    {% set ddl = 'CREATE OR REPLACE TABLE synthea_raw.silver_staging.' ~ table_name ~ ' (' %}
    {% for col in cols %}
      {% set ddl = ddl ~ col.name ~ ' ' ~ col.type %}
      {% if not loop.last %}{% set ddl = ddl ~ ',' %}{% endif %}
    {% endfor %}
    {% set ddl = ddl ~ ')' %}
    
    {{ log("Creating: " ~ ddl, info=true) }}
    {% do run_query(ddl) %}
  {% endfor %}
  
  {{ log("Created tables: " ~ tables.keys() | list, info=true) }}
{% endmacro %}
