{{
    config(
        materialized='incremental',
        full_refresh=false,
	    transient=false,    
	    on_schema_change='sync_all_columns'
    )
}}

{#- Check if the table already exists. -#}
{%- set target_relation = adapter.get_relation(
      database=this.database,
      schema=this.schema,
      identifier=this.name) -%}
{%- set table_exists=target_relation is not none -%}

{% set source = ref('all_match_data') %}

{% if table_exists %}
    {% set target = this %}
{%- else -%}
    {% set target = "(select '' as change_type, * from " ~ source ~ " where unique_id = '0')" %}
{% endif %}

{{ identify_table_changes(source, target) }}
