{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key= 'unique_id',
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

{#- Below, input the name of the model that has your source data. This model MUST include the following fields: -#}
{#- unique_id: This is the unique identifier for your record. -#}
{#- updated_at: This field is the last time the data was updated in your model. -#}
{% set source = ref('all_match_data') %}

{#- If there are any other fields that you want to exclude from your feed, list them below. Do not remove unique_id or updated_at. -#}
{% set exclude_columns = ['unique_id','updated_at'] %}
{% set col_string = dbt_utils.star(source, except=exclude_columns) | replace('"','') | replace(' ','') | replace('\n','') | lower %}
{% set colarr = col_string.split(',') %}

with 

-- Below converts your source model to a json object
source_tbl_obj as (
  select
    unique_id
    , object_construct(
    {% for col in colarr -%}
      {% if col != colarr[0] %}, {% endif %}'{{col}}', {{col}}
    {% endfor %}
    ) as payload
    , updated_at
  from {{ source }}
)

{% if table_exists %}
-- Below pulls in existing records and flattens them
, existing_tbl_data as (
  select u.unique_id, v.key::varchar as key, v.value::variant as value, u.updated_at
  from {{this}} u,
  table(flatten(input => u.payload)) v
  qualify row_number() over (partition by u.unique_id, v.key order by u.updated_at desc) = 1
)
{% endif %}

-- Below flattens your existing records
, source_tbl_data as (
  select u.unique_id, v.key::varchar as key, v.value::variant as value, u.updated_at
  from source_tbl_obj u,
  table(flatten(input => u.payload)) v
)

-- Compares the most recent records with existing record, by unique_id
-- If the new data is different from the existing data, that data will be transmitted
-- Only the individual cells that have changed will be sent, or unique_ids that are completely new
, identify_change as (
select distinct
    n.unique_id
from source_tbl_data n
{% if table_exists %}
    left join existing_tbl_data o on n.unique_id = o.unique_id and n.key = o.key
where ifnull(n.value::string, '|') != ifnull(o.value::string, '|')
{% endif %}
)

select std.* from source_tbl_obj std
inner join identify_change ic on ic.unique_id = std.unique_id
