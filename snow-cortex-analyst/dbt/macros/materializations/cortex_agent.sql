{#
  Custom Materialization: cortex_agent

  Allows Cortex Analyst agents to be managed as dbt models.
  Pure config — instructions live in separate macro files.

  Features:
    - Idempotent: only ALTER when spec changes, CREATE when agent doesn't exist
    - DAG-aware: agents depend on semantic views via ref()
    - Selective: dbt run --select sales_agent
    - Environment-aware: resolves env prefixes automatically

  Model file format:
    {{ config(
        materialized = 'cortex_agent',
        instructions = 'sales_agent',
        semantic_views = ['order_stats_1d', 'customer_stats_1d'],
        ...
    ) }}

  Instructions macro convention (in macros/cortex/instructions/):
    {instructions}_orchestration()    - How the agent should think and query
    {instructions}_response()         - How the agent should format answers
    {instructions}_sample_questions() - Returns list of starter questions
#}

{% materialization cortex_agent, adapter='snowflake' -%}

  {% set original_query_tag = set_query_tag() %}

  {# --- Resolve environment context --- #}
  {% set env_code = env_var('ENV_CODE', 'dev') | trim | upper %}
  {% set project_code = env_var('PROJ_CODE', 'entechlog') | trim | upper %}
  {% set agent_database = database %}
  {% set agent_schema = schema %}

  {# --- Resolve agent identity --- #}
  {% set agent_name = model['alias'] %}
  {% set full_agent_name = agent_database ~ '.' ~ agent_schema ~ '.' ~ agent_name %}

  {% set display_name = config.get('display_name', agent_name) %}
  {% set description = config.get('description', '') %}

  {# --- Resolve semantic views --- #}
  {% set semantic_view_names = config.get('semantic_views', []) %}
  {% set warehouse_short = config.get('warehouse', 'CORTEX_WH_XS') %}
  {% set agent_warehouse = env_code ~ '_' ~ project_code ~ '_' ~ warehouse_short %}

  {# --- Budget --- #}
  {% set timeout_seconds = config.get('timeout_seconds', 60) %}
  {% set token_limit = config.get('token_limit', 16000) %}
  {% set query_timeout_seconds = config.get('query_timeout_seconds', 60) %}

  {# --- Instructions (from macro files referenced by config.instructions) --- #}
  {% set instructions_name = config.get('instructions', '') %}
  {% set orchestration_instructions = '' %}
  {% set response_instructions = '' %}
  {% set sample_questions = [] %}

  {% if instructions_name %}
    {% set orch_macro = instructions_name ~ '_orchestration' %}
    {% if orch_macro in context %}
      {% set orchestration_instructions = context[orch_macro]() | trim %}
    {% endif %}

    {% set resp_macro = instructions_name ~ '_response' %}
    {% if resp_macro in context %}
      {% set response_instructions = context[resp_macro]() | trim %}
    {% endif %}

    {% set sq_macro = instructions_name ~ '_sample_questions' %}
    {% if sq_macro in context %}
      {% set sample_questions = context[sq_macro]() %}
    {% endif %}
  {% endif %}

  {# --- Build semantic view paths --- #}
  {% set semantic_views = [] %}
  {% for view_name in semantic_view_names %}
    {% set full_view_path = agent_database ~ '.' ~ agent_schema ~ '.' ~ view_name %}
    {% do semantic_views.append(full_view_path) %}
  {% endfor %}

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

  {% set new_spec = {
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

  {% set new_spec_json = new_spec | tojson %}
  {% set profile = {"display_name": display_name} %}

  {{ run_hooks(pre_hooks) }}

  {# --- Idempotent deployment: compare before create/alter --- #}
  {% set agent_exists = false %}
  {% set spec_changed = true %}

  {% if execute %}
    {# Check if agent exists via SHOW AGENTS #}
    {% set show_sql = "SHOW AGENTS LIKE '" ~ agent_name ~ "' IN SCHEMA " ~ agent_database ~ "." ~ agent_schema ~ ";" %}
    {% set show_results = run_query(show_sql) %}

    {% if show_results | length > 0 %}
      {% set agent_exists = true %}

      {# Get current spec via DESCRIBE AGENT #}
      {% set desc_sql = "DESCRIBE AGENT " ~ full_agent_name ~ ";" %}
      {% set desc_results = run_query(desc_sql) %}

      {% if desc_results | length > 0 %}
        {# agent_spec is the 7th column (index 6) #}
        {% set current_spec = desc_results.columns[6].values()[0] | trim %}
        {% set new_spec_trimmed = new_spec_json | trim %}

        {# Normalize for comparison: parse and re-serialize both #}
        {% set current_parsed = fromjson(current_spec) if current_spec else {} %}
        {% set new_parsed = fromjson(new_spec_trimmed) if new_spec_trimmed else {} %}

        {% if current_parsed | tojson == new_parsed | tojson %}
          {% set spec_changed = false %}
        {% endif %}
      {% endif %}
    {% endif %}
  {% endif %}

  {% if execute %}
    {% if not agent_exists %}
      {# --- CREATE new agent --- #}
      {{ log("Creating agent: " ~ full_agent_name, info=True) }}
      {% call statement('main') -%}
        CREATE AGENT {{ full_agent_name }}
        WITH PROFILE = '{{ profile | tojson }}'
        {% if description %}
        , COMMENT = '{{ description | replace("'", "''") }}'
        {% endif %}
        FROM SPECIFICATION $${{ new_spec_json }}$$
        ;
      {%- endcall %}
      {{ log("  Created successfully", info=True) }}

    {% elif spec_changed %}
      {# --- ALTER existing agent (preserves chat history) --- #}
      {{ log("Updating agent: " ~ full_agent_name ~ " (spec changed)", info=True) }}
      {% call statement('main') -%}
        ALTER AGENT {{ full_agent_name }}
        MODIFY LIVE VERSION SET SPECIFICATION = $${{ new_spec_json }}$$
        ;
      {%- endcall %}

      {# Update profile and comment separately if needed #}
      {% call statement('update_profile') -%}
        ALTER AGENT {{ full_agent_name }} SET
        PROFILE = '{{ profile | tojson }}'
        {% if description %}
        , COMMENT = '{{ description | replace("'", "''") }}'
        {% endif %}
        ;
      {%- endcall %}
      {{ log("  Updated successfully (ALTER, chat history preserved)", info=True) }}

    {% else %}
      {# --- No changes, skip --- #}
      {{ log("Skipping agent: " ~ full_agent_name ~ " (no changes)", info=True) }}
      {% call statement('main') -%}
        SELECT 1 {# no-op #}
      {%- endcall %}
    {% endif %}

    {# --- Grant permissions --- #}
    {% set grant_to_roles = config.get('grant_to_roles', []) %}
    {% if grant_to_roles is string %}
      {% set grant_to_roles = [grant_to_roles] %}
    {% endif %}

    {% for role in grant_to_roles %}
      {% set grant_sql %}
        GRANT USAGE ON AGENT {{ full_agent_name }} TO ROLE "{{ role }}";
      {% endset %}
      {% do run_query(grant_sql) %}
      {{ log("  Granted USAGE to: " ~ role, info=True) }}
    {% endfor %}
  {% endif %}

  {# --- Return relation for dbt catalog --- #}
  {% set target_relation = this.incorporate(type='view') %}

  {{ run_hooks(post_hooks) }}
  {% do unset_query_tag(original_query_tag) %}
  {% do return({'relations': [target_relation]}) %}

{%- endmaterialization %}
