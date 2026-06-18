-- macros/generate_schema_name.sql
-- Overrides dbt's default schema naming which concatenates target+custom schema.
-- This macro uses the custom schema name exactly as defined in model configs,
-- falling back to the target schema when no custom schema is set.

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim | upper }}
    {%- endif -%}

{%- endmacro %}