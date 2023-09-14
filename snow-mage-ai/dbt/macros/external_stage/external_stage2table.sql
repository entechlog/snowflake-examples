{% macro external_stage(path='') %}
    @__STAGE_TOKEN__{{path}}
{% endmacro %}

{% macro ensure_external_stage(stage_name, url, file_format, temporary=False) %}
    {{ log('Making external stage: ' ~ [stage_name, url, file_format, temporary] | join(', ')) }}
    create or replace stage {{ 'temporary' if temporary }} {{ database }}.{{ schema }}.{{ stage_name }}
        url='{{ url }}'
        credentials=(aws_key_id='{{ env_var("AWS_ACCESS_KEY_ID") }}' aws_secret_key='{{ env_var("AWS_SECRET_ACCESS_KEY") }}')
        file_format = {{ file_format }};
{% endmacro %}

{% materialization external_stage2table, adapter='snowflake' -%}
    {%- set identifier = model['alias'] -%}
    {%- set stage_name = config.get('stage_name', default=identifier ~ '_stage') -%}
    {%- set url = config.require('url') -%}
    {%- set file_format = config.get('file_format', default='(type = PARQUET)') -%}
    {%- set pattern = config.get('pattern') -%}
    {%- call statement() -%}
        {{ ensure_external_stage(stage_name, url, file_format, temporary=False) }}
    {%- endcall -%}

    {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
    {%- set target_relation = api.Relation.create(database=database, schema=schema, identifier=identifier, type='table') -%}

    {%- set full_refresh_mode = (flags.FULL_REFRESH == True) -%}
    {%- set exists_as_table = (old_relation is not none and old_relation.is_table) -%}
    {%- set should_drop = (full_refresh_mode or not exists_as_table) -%}

    -- setup
    {% if old_relation is none -%}
        -- noop
    {%- elif should_drop -%}
        {{ adapter.drop_relation(old_relation) }}
        {%- set old_relation = none -%}
    {%- endif %}

    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    -- build model
    {% if full_refresh_mode or old_relation is none -%}
        {#
            -- Create an empty table with columns as specified in sql.
            -- We append a unique invocation_id to ensure no files are actually loaded, and an empty row set is returned,
            -- which serves as a template to create the table.
        #}
        {%- call statement() -%}
            CREATE OR REPLACE TABLE {{ target_relation }} AS (
                {{ sql | replace('__STAGE_TOKEN__', database ~ '.' ~ schema ~ '.' ~ stage_name ~ '/' ~ invocation_id) }}
            )
        {%- endcall -%}
    {%- endif %}

    {# Perform the main load operation using COPY INTO #}
    {# See https://docs.snowflake.net/manuals/user-guide/data-load-considerations-load.html #}
    {# See https://docs.snowflake.net/manuals/user-guide/data-load-transform.html #}

    {%- call statement('main') -%}
        COPY INTO {{ target_relation }}
        FROM (
            {{ sql | replace('__STAGE_TOKEN__', database ~ '.' ~ schema ~ '.' ~ stage_name) }}
            {% if pattern is not none and pattern != '' %}
                (pattern => {{ '"' ~ pattern ~ '"' }})
            {% endif %}
        )
        ON_ERROR = 'skip_file';
    {% endcall %}

    {{ run_hooks(post_hooks, inside_transaction=True) }}

    -- `COMMIT` happens here
    {{ adapter.commit() }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}

    {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}
