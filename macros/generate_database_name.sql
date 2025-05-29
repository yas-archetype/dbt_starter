{% macro generate_database_name(custom_database_name=none, node=none) -%}

    {%- if custom_database_name -%}
        {{ target.name }}_{{ custom_database_name | trim }}
    {%- else -%}
        {{ target.database }}
    {%- endif -%}

{%- endmacro %}
