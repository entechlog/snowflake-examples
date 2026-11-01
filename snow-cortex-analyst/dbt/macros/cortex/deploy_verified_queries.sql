{#
  Deploy verified queries to semantic views.

  Reads verified_queries from model meta (defined in .yml files),
  fetches current semantic view YAML, appends verified queries, and writes back.

  Usage:
    dbt run-operation deploy_verified_queries                                    # All semantic views
    dbt run-operation deploy_verified_queries --args '{name: order_stats_1d}'    # Single view
#}

{% macro deploy_verified_queries(name=None) %}

  {% set env_code = env_var('ENV_CODE', 'dev') | trim | upper %}
  {% set project_code = env_var('PROJ_CODE', 'entechlog') | trim | upper %}
  {% set database = env_code ~ '_' ~ project_code ~ '_DW_DB' %}

  {# Normalize name to a list for consistent filtering #}
  {% set name_filter = [] %}
  {% if name is not none %}
    {% if name is iterable and name is not string %}
      {% set name_filter = name %}
    {% else %}
      {% set name_filter = [name] %}
    {% endif %}
  {% endif %}

  {# --- Find semantic view models with verified_queries in meta --- #}
  {% set views_to_process = [] %}

  {% for node in graph.nodes.values() %}
    {% if node.resource_type == 'model' and node.config.materialized == 'semantic_view' %}
      {% set vqs = node.meta.get('verified_queries', []) if node.meta else [] %}
      {% set view_alias = node.alias if node.alias else node.name | replace('semantic__', '') %}
      {% set view_schema = node.config.schema | default('semantic') | upper %}

      {% if vqs | length > 0 %}
        {% if name_filter | length == 0 or view_alias in name_filter %}
          {% do views_to_process.append({'alias': view_alias, 'schema': view_schema, 'verified_queries': vqs}) %}
        {% endif %}
      {% endif %}
    {% endif %}
  {% endfor %}

  {% if views_to_process | length == 0 %}
    {{ log("No semantic views with verified queries found" ~ (" for '" ~ name ~ "'" if name else ""), info=True) }}
    {{ return('') }}
  {% endif %}

  {% for view in views_to_process %}
    {% set full_schema = database ~ '.' ~ view.schema %}
    {% set full_view = full_schema ~ '.' ~ view.alias %}
    {% set vqs = view.verified_queries %}

    {{ log("Deploying " ~ vqs | length ~ " verified queries to " ~ full_view, info=True) }}

    {# --- Read current YAML --- #}
    {% set read_sql %}
      SELECT SYSTEM$READ_YAML_FROM_SEMANTIC_VIEW('{{ full_view }}')
    {% endset %}
    {% set yaml_result = run_query(read_sql) %}

    {% if yaml_result | length == 0 or yaml_result.columns[0].values()[0] is none %}
      {{ log("  WARNING: Could not read YAML for " ~ full_view ~ ", skipping", info=True) }}
      {% continue %}
    {% endif %}

    {% set current_yaml = yaml_result.columns[0].values()[0] %}

    {# --- Build verified_queries YAML block --- #}
    {% set vq_lines = [] %}
    {% do vq_lines.append('verified_queries:') %}

    {% for vq in vqs %}
      {% do vq_lines.append('  - name: "' ~ vq.name ~ '"') %}
      {% do vq_lines.append('    question: "' ~ vq.question | replace('"', '\\"') ~ '"') %}
      {% if vq.get('use_as_onboarding_question', false) %}
        {% do vq_lines.append('    use_as_onboarding_question: true') %}
      {% endif %}
      {% set clean_sql = vq.sql | replace('"', '\\"') | replace("\n", " ") | trim %}
      {% do vq_lines.append('    sql: "' ~ clean_sql ~ '"') %}
    {% endfor %}

    {% set vq_yaml = vq_lines | join("\n") %}

    {# --- Strip existing verified_queries and append new --- #}
    {% set clean_yaml = current_yaml %}
    {% if 'verified_queries:' in current_yaml %}
      {% set clean_yaml = current_yaml.split('verified_queries:')[0] | trim %}
    {% endif %}

    {% set combined_yaml = clean_yaml ~ "\n\n" ~ vq_yaml %}

    {# --- Write back --- #}
    {% set deploy_sql %}
      CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML('{{ full_schema }}', $${{ combined_yaml }}$$)
    {% endset %}
    {% do run_query(deploy_sql) %}
    {{ log("  Deployed successfully", info=True) }}

  {% endfor %}

{% endmacro %}
