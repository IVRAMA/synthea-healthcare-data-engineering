{% macro generate_schema_name(custom_schema_name, node) %}
    {% if custom_schema_name is none or custom_schema_name in ['', 'none', 'null'] %}
        {{ return(node.project_schema | upper) }}   -- same as dbt_project.yml schema
    {% else %}
        {{ return(custom_schema_name | upper) }}
    {% endif %}
{% endmacro %}
