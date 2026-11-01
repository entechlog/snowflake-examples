{#
  Drop semantic view(s) from Snowflake.

  Usage:
    dbt run-operation drop_semantic_view --args '{name: order_stats_1d}'
    dbt run-operation drop_semantic_view --args '{name: [order_stats_1d, customer_stats_1d]}'
#}

{% macro drop_semantic_view(name=None, database=None, schema='semantic') %}
  {% if name is not defined or name is none %}
    {{ log("ERROR: name is required. Usage: --args '{name: order_stats_1d}' or --args '{name: [view1, view2]}'", info=True) }}
    {{ return('') }}
  {% endif %}

  {% set names = name if name is iterable and name is not string else [name] %}

  {% set env_code = env_var('ENV_CODE', 'dev') | trim | upper %}
  {% set project_code = env_var('PROJ_CODE', 'entechlog') | trim | upper %}
  {% set view_database = database or (env_code ~ '_' ~ project_code ~ '_DW_DB') %}

  {% for view_name in names %}
    {% set full_view_name = view_database ~ '.' ~ schema ~ '.' ~ view_name %}
    {{ log("Dropping semantic view: " ~ full_view_name, info=True) }}
    {% do run_query("DROP SEMANTIC VIEW IF EXISTS " ~ full_view_name ~ ";") %}
    {{ log("  Dropped successfully", info=True) }}
  {% endfor %}
{% endmacro %}
