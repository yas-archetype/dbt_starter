{% macro clone_schemas_and_tables(
    source_db='raw',
    source_env='starter_prod',
    target_env='starter_test',
    target_db='raw'
) %}

{%- set full_source_db = source_env ~ '_' ~ source_db -%}
{%- set full_target_db = target_env ~ '_' ~ target_db -%}

-- Get all schemas from the source database
{% set get_schemas_query %}
    SELECT schema_name
    FROM {{ full_source_db | upper }}.information_schema.schemata
    WHERE schema_name NOT IN ('INFORMATION_SCHEMA')
{% endset %}

{% set schemas = run_query(get_schemas_query).columns[0].values() %}

{% if schemas|length == 0 %}
    {{ log("No schemas found in " ~ full_source_db, info=True) }}
{% else %}

    {% for schema in schemas %}
        {% set source_schema = full_source_db ~ '.' ~ schema %}
        {% set target_schema = full_target_db ~ '.' ~ schema %}

        -- Create the schema in the target database if it doesn't exist
        {{ log("Creating schema if not exists: " ~ target_schema, info=True) }}
        CREATE SCHEMA IF NOT EXISTS {{ full_target_db }}.{{ schema }};

        -- Get all base tables in the source schema
        {% set get_tables_query %}
            SELECT table_name
            FROM {{ full_source_db }}.information_schema.tables
            WHERE table_schema = '{{ schema }}'
              AND table_type = 'BASE TABLE'
        {% endset %}

        {% set tables = run_query(get_tables_query).columns[0].values() %}

        {% for table in tables %}
            {% set source_table = full_source_db ~ '.' ~ schema ~ '.' ~ table %}
            {% set target_table = full_target_db ~ '.' ~ schema ~ '.' ~ table %}
            
            {{ log("Cloning table: " ~ source_table ~ " -> " ~ target_table, info=True) }}
            CREATE OR REPLACE TABLE {{ target_table }} CLONE {{ source_table }};
        {% endfor %}

    {% endfor %}

{% endif %}

{% endmacro %}