{% macro delete_data(del_key, del_value, database, schema, table) %}

{%- set relation = adapter.get_relation(this.database, this.schema, this.table) -%}

{%- if relation is not none -%}
	{%- if var("run_type") == 'full-refresh'-%}
			{%- call statement('truncate table ' ~ table, fetch_result=False, auto_begin=True) -%}
				truncate {{ this }}
			{%- endcall -%}
		{%- elif var("run_type") == 'daily'-%}	
			{%- call statement('delete ' ~ del_value ~ ' records from ' ~ table, fetch_result=False, auto_begin=True) -%}
				delete from {{ this }} where {{del_key}} = '{{del_value}}'
			{%- endcall -%}
		{%- elif var("run_type") == 'backfill'-%}
			{%- call statement('delete ' ~ del_value ~ ' records from ' ~ table ~ ' where '~del_key~ ' between ' ~ start_time ~ ' and ' ~ end_time, fetch_result=False, auto_begin=True) -%}
				delete from {{ this }} where {{del_key}} between '{{ var("backfill_start_date") }}' and '{{ var("backfill_end_date") }}'
			{%- endcall -%}
	{% endif %}
{%- endif -%}

{% endmacro %}