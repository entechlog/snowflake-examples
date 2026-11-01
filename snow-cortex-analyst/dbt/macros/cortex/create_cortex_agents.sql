{#
  Cortex Agent utility macros.

  Agent creation is handled by the cortex_agent materialization (models/agents/).
  These macros provide drop and list operations for ad-hoc management.

  Usage:
    dbt run-operation drop_cortex_agent --args '{name: dev_sales_agent}'
    dbt run-operation drop_cortex_agent --args '{name: [dev_sales_agent, dev_support_agent]}'
    dbt run-operation list_cortex_agents
#}

{% macro drop_cortex_agent(name=None, database=None, schema='semantic') %}
  {% if name is not defined or name is none %}
    {{ log("ERROR: name is required. Usage: --args '{name: dev_sales_agent}' or --args '{name: [agent1, agent2]}'", info=True) }}
    {{ return('') }}
  {% endif %}

  {% set names = name if name is iterable and name is not string else [name] %}

  {% set env_code = env_var('ENV_CODE', 'dev') | trim | upper %}
  {% set project_code = env_var('PROJ_CODE', 'entechlog') | trim | upper %}
  {% set agent_database = database or (env_code ~ '_' ~ project_code ~ '_DW_DB') %}

  {% for agent_name in names %}
    {% set full_agent_name = agent_database ~ '.' ~ schema ~ '.' ~ agent_name %}
    {{ log("Dropping agent: " ~ full_agent_name, info=True) }}
    {% do run_query("DROP AGENT IF EXISTS " ~ full_agent_name ~ ";") %}
    {{ log("  Dropped successfully", info=True) }}
  {% endfor %}
{% endmacro %}


{% macro list_cortex_agents(database=None, schema='semantic') %}
  {% set env_code = env_var('ENV_CODE', 'dev') | trim | upper %}
  {% set project_code = env_var('PROJ_CODE', 'entechlog') | trim | upper %}
  {% set agent_database = database or (env_code ~ '_' ~ project_code ~ '_DW_DB') %}

  {{ log("Listing agents in " ~ agent_database ~ "." ~ schema, info=True) }}
  {% set results = run_query("SHOW AGENTS IN " ~ agent_database ~ "." ~ schema ~ ";") %}

  {% if execute and results %}
    {{ log("Found " ~ results | length ~ " agent(s):", info=True) }}
    {% for row in results %}
      {{ log("  - " ~ row[1], info=True) }}
    {% endfor %}
  {% else %}
    {{ log("No agents found", info=True) }}
  {% endif %}
{% endmacro %}
