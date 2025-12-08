{% macro generate_database_name(custom_database_name, node) %}
    {% if custom_database_name is none or custom_database_name in ['', 'none', 'null'] %}
        {{ return(node.project_name | upper ~ '_RAW') }}  
        -- OR return the exact value you want, if not pattern-based
    {% else %}
        {{ return(custom_database_name | upper) }}
    {% endif %}
{% endmacro %}
