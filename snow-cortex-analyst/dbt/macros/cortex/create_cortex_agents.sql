{% macro create_cortex_agents() %}
  {#
    Creates Cortex Analyst agents defined in dbt_project.yml vars.cortex_agents.
    Call via: dbt run-operation create_cortex_agents

    Uses CREATE OR REPLACE AGENT ... FROM SPECIFICATION (JSON) syntax.
    Each agent can span multiple semantic views (multi-tool agent).
  #}

  {% set agents = var('cortex_agents', []) %}

  {% if agents | length > 0 %}
    {% for agent in agents %}
      {{ create_single_agent(agent) }}
    {% endfor %}
  {% else %}
    {{ log("No Cortex Agents defined in dbt_project.yml vars.cortex_agents", info=True) }}
  {% endif %}

{% endmacro %}


{% macro create_single_agent(agent_config) %}
  {#
    Creates a single Cortex Analyst agent with:
    - JSON specification (tools, resources, instructions, budget)
    - Role-based grants
    - Environment-aware naming
  #}

  {% set enabled = agent_config.get('enabled', True) %}
  {% if not enabled %}
    {{ log("Skipping disabled agent: " ~ agent_config.name, info=True) }}
    {{ return('') }}
  {% endif %}

  {# --- Resolve agent identity (render all values that may contain Jinja) --- #}
  {% set agent_database_raw = agent_config.get('database', var('dw_db')) %}
  {% set agent_database = render(agent_database_raw) if '{{' in agent_database_raw else agent_database_raw %}
  {% set agent_schema = agent_config.get('schema', 'semantic') %}

  {% set agent_name_raw = agent_config.name %}
  {% set agent_name = render(agent_name_raw) if '{{' in agent_name_raw else agent_name_raw %}
  {% set full_agent_name = agent_database ~ '.' ~ agent_schema ~ '.' ~ agent_name %}

  {% set display_name_raw = agent_config.get('display_name', agent_name) %}
  {% set display_name = render(display_name_raw) if '{{' in display_name_raw else display_name_raw %}

  {% set description_raw = agent_config.get('description', '') %}
  {% set description = render(description_raw) if description_raw and '{{' in description_raw else description_raw %}

  {# --- Resolve warehouse and budget --- #}
  {% set agent_warehouse_raw = agent_config.get('warehouse', var('agent_warehouse_default')) %}
  {% set agent_warehouse = render(agent_warehouse_raw) if '{{' in agent_warehouse_raw else agent_warehouse_raw %}
  {% set timeout_seconds = agent_config.get('timeout_seconds', 60) %}
  {% set token_limit = agent_config.get('token_limit', 16000) %}
  {% set query_timeout_seconds = agent_config.get('query_timeout_seconds', 60) %}

  {# --- Build semantic view paths --- #}
  {% set semantic_view_names = agent_config.get('semantic_views', []) %}
  {% set semantic_views = [] %}
  {% for view_name in semantic_view_names %}
    {% set full_view_path = agent_database ~ '.' ~ agent_schema ~ '.' ~ view_name %}
    {% do semantic_views.append(full_view_path) %}
  {% endfor %}

  {% if semantic_views | length == 0 %}
    {{ log("WARNING: Agent " ~ agent_name ~ " has no semantic views defined", info=True) }}
    {{ return('') }}
  {% endif %}

  {# --- Get instructions from macros --- #}
  {% set instructions_macro = agent_config.get('instructions', '') %}
  {% set orchestration_instructions = '' %}
  {% set response_instructions = '' %}
  {% set sample_questions = [] %}

  {% if instructions_macro %}
    {% set orchestration_macro = instructions_macro ~ '_orchestration' %}
    {% if orchestration_macro in context %}
      {% set orchestration_instructions = context[orchestration_macro]() %}
    {% endif %}

    {% set response_macro = instructions_macro ~ '_response' %}
    {% if response_macro in context %}
      {% set response_instructions = context[response_macro]() %}
    {% endif %}

    {% set questions_macro = instructions_macro ~ '_sample_questions' %}
    {% if questions_macro in context %}
      {% set sample_questions = context[questions_macro]() %}
    {% endif %}
  {% endif %}

  {# --- Build JSON specification --- #}
  {% set tools = [] %}
  {% set tool_resources = {} %}

  {% for view in semantic_views %}
    {% set view_name = view.split('.')[-1] %}
    {% do tools.append({
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": view_name,
        "description": "Analyst for " ~ view_name
      }
    }) %}
    {% do tool_resources.update({
      view_name: {
        "semantic_view": view,
        "execution_environment": {
          "type": "warehouse",
          "warehouse": agent_warehouse,
          "query_timeout_seconds": query_timeout_seconds
        }
      }
    }) %}
  {% endfor %}

  {% set instructions_obj = {} %}
  {% if orchestration_instructions %}
    {% set _ = instructions_obj.update({"orchestration": orchestration_instructions}) %}
  {% endif %}
  {% if response_instructions %}
    {% set _ = instructions_obj.update({"response": response_instructions}) %}
  {% endif %}
  {% if sample_questions | length > 0 %}
    {% set question_objects = [] %}
    {% for question in sample_questions %}
      {% do question_objects.append({"question": question}) %}
    {% endfor %}
    {% set _ = instructions_obj.update({"sample_questions": question_objects}) %}
  {% endif %}

  {% set specification = {
    "orchestration": {
      "budget": {
        "seconds": timeout_seconds,
        "tokens": token_limit
      }
    },
    "instructions": instructions_obj,
    "tools": tools,
    "tool_resources": tool_resources
  } %}

  {% set profile = {"display_name": display_name} %}

  {# --- Execute CREATE OR REPLACE AGENT --- #}
  {% set create_agent_sql %}
    CREATE OR REPLACE AGENT {{ full_agent_name }}
    WITH PROFILE = '{{ profile | tojson }}'
    {% if description %}
    COMMENT = '{{ description | replace("'", "''") }}'
    {% endif %}
    FROM SPECIFICATION $${{ specification | tojson }}$$
    ;
  {% endset %}

  {{ log("Creating Cortex Analyst Agent: " ~ full_agent_name, info=True) }}
  {{ log("  Display Name: " ~ display_name, info=True) }}
  {{ log("  Warehouse: " ~ agent_warehouse, info=True) }}
  {{ log("  Semantic Views: " ~ semantic_views | join(', '), info=True) }}

  {% do run_query(create_agent_sql) %}

  {{ log("Successfully created agent: " ~ full_agent_name, info=True) }}

  {# --- Grant permissions --- #}
  {% set grant_to_roles = agent_config.get('grant_to_roles', []) %}
  {% if grant_to_roles is string %}
    {% set grant_to_roles = [grant_to_roles] %}
  {% endif %}

  {% if grant_to_roles | length > 0 %}
    {% for role_raw in grant_to_roles %}
      {% set role = render(role_raw) if '{{' in role_raw else role_raw %}
      {% set grant_sql %}
        GRANT USAGE ON AGENT {{ full_agent_name }} TO ROLE "{{ role }}";
      {% endset %}
      {% do run_query(grant_sql) %}
      {{ log("  Granted USAGE to: " ~ role, info=True) }}
    {% endfor %}
  {% endif %}

{% endmacro %}


{% macro drop_cortex_agent(agent_name, database=None, schema='semantic') %}
  {% set agent_database = database or var('dw_db') %}
  {% set full_agent_name = agent_database ~ '.' ~ schema ~ '.' ~ agent_name %}

  {{ log("Dropping Cortex Analyst Agent: " ~ full_agent_name, info=True) }}
  {% do run_query("DROP AGENT IF EXISTS " ~ full_agent_name ~ ";") %}
  {{ log("Successfully dropped agent: " ~ full_agent_name, info=True) }}
{% endmacro %}


{% macro list_cortex_agents(database=None, schema='semantic') %}
  {% set agent_database = database or var('dw_db') %}

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
