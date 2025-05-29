{% macro generate_schema_name(custom_schema_name=none, node=none) -%}

    {%- if custom_schema_name -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}

{%- endmacro %}
