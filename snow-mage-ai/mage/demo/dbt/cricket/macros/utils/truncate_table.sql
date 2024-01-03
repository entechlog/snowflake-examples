{% macro truncate_table(database, schema, table) %}

{%- set relation = adapter.get_relation(this.database, this.schema, this.table) -%}

{%- if relation is not none -%}
	{%- call statement('truncate_table', fetch_result=False, auto_begin=True) -%}
	truncate table {{ this }}
	{%- endcall -%}
{%- endif -%}

{% endmacro %}