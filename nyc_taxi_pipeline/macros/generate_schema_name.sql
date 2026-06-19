-- macros/generate_schema_name.sql
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'prod' -%}
        {#- Production: use exact schema name as defined in dbt_project.yml -#}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ custom_schema_name | trim | upper }}
        {%- endif -%}

    {%- else -%}
        {#- Development / CI: always prefix with target.schema (DEV_ABDUL) -#}
        {#- This keeps dev models isolated from production schemas -#}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ target.schema }}_{{ custom_schema_name | trim | upper }}
        {%- endif -%}

    {%- endif -%}

{%- endmacro %}