-- To run on the default target database:
-- dbt run-operation delete_orphaned_tables --args "{dry_run: False}"

-- To run on a list of databases, for instance 'DATABASE1' and 'DATABASE2':
-- dbt run-operation delete_orphaned_tables --args "{databases_list: ['DATABASE1', 'DATABASE2'], dry_run: False}"

-- To run in dry run mode (it will not delete but will log tables and views that would be deleted) on a list of databases:
-- dbt run-operation delete_orphaned_tables --args "{databases_list: ['DATABASE1', 'DATABASE2'], dry_run: True}"

{% macro delete_orphaned_tables(databases_list=[target.database], dry_run=False) %}
  
  {% do log("", True) %}
  {% do log("Searching for orphaned tables/views...", True) %}
  
  {# Loop over all items provided in the databases_list, which may include schema names #}
  {% for db_schema in databases_list %}
    {% set split_db_schema = db_schema.split('.') %}
    {% set database = split_db_schema[0] %}
    {% set schema = split_db_schema[1] if split_db_schema|length > 1 else None %}
    
    {% if schema %}
      {% do log("Using target profile: " ~ target.name ~ " (database: " ~ database ~ ", schema: " ~ schema ~ ").", True) %}
    {% else %}
      {% do log("Using target profile: " ~ target.name ~ " (database: " ~ database ~ ").", True) %}
    {% endif %}
    
    {% set schema_query %}
      SELECT distinct table_schema
      from (
        SELECT distinct table_schema
        FROM "{{ database }}".information_schema.tables
        UNION ALL
        SELECT distinct table_schema
        FROM "{{ database }}".information_schema.views
      ) u
      where table_schema <> 'INFORMATION_SCHEMA'
      {% if schema %}AND table_schema = '{{ schema }}'{% endif %}
    {% endset %}
    
    {%- set result = run_query(schema_query) -%}
    {% if result %}
      {%- for row in result -%}
        {% set current_schema = row[0] %}
        
        {% do log("", True) %}
        {% do log("schema: " ~ current_schema, True) %}
    
        {% set query %}
          SELECT UPPER(c.database_name) AS database_name,
                  UPPER(c.schema_name) AS schema_name,
                  UPPER(c.ref_name) AS ref_name,
                  UPPER(c.ref_type) AS ref_type
          FROM (
            SELECT  '{{ database }}' AS database_name,
                    table_schema AS schema_name,
                    table_name  AS ref_name,
                    'table'    AS ref_type
            FROM "{{ database }}".information_schema.tables
            WHERE table_schema = '{{ current_schema }}'
            AND TABLE_TYPE = 'BASE TABLE'
            UNION ALL
            SELECT '{{ database }}' AS database_name,
                    table_schema AS schema_name,
                    table_name   AS ref_name,
                    'view'     AS ref_type
            FROM "{{ database }}".information_schema.views
            WHERE table_schema = '{{ current_schema }}'
          ) AS c
          LEFT JOIN (
            {%- for node in graph.nodes.values() | selectattr("resource_type", "equalto", "model") | list
                        + graph.nodes.values() | selectattr("resource_type", "equalto", "seed")  | list %}
              SELECT
              upper('{{node.config.schema}}') AS schema_name,
                  CASE WHEN '{{node.alias}}' IS NOT NULL AND '{{node.alias}}' <> ''
                  THEN upper('{{node.alias}}')
                  ELSE upper('{{node.name}}')
                  END AS ref_name
              {% if not loop.last %} UNION ALL {% endif %}
            {%- endfor %}
          ) AS desired on desired.schema_name = c.schema_name
                        and desired.ref_name    = c.ref_name
          WHERE desired.ref_name is null
        {% endset %}
        
        {%- set result = run_query(query) -%}
        {% if result %}
            {%- for to_delete in result -%}
              {%- if dry_run -%}
                  {%- do log('To be dropped: ' ~ to_delete[3] ~ ' ' ~ to_delete[0] ~ '.' ~ to_delete[1] ~ '.' ~ to_delete[2], True) -%}
              {%- else -%}
                  {% set drop_command = 'DROP ' ~ to_delete[3] ~ ' IF EXISTS ' ~ to_delete[0] ~ '.' ~ to_delete[1] ~ '.' ~ to_delete[2] ~ ' CASCADE;' %}
                  {% do run_query(drop_command) %}
                  {%- do log('Dropped ' ~ to_delete[2] ~ ' ' ~ to_delete[0] ~ '.' ~ to_delete[1], True) -%}
              {%- endif -%}
            {%- endfor -%}
        {% else %}
          {% do log('No orphan tables to clean in ' ~ current_schema ~ '.', True) %}
        {% endif %}
      {%- endfor -%}
    {% else %}
      {% do log('No schemas to check or no orphan tables to clean.', True) %}
    {% endif %}
  {% endfor %}
{% endmacro %}
