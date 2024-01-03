{% macro filter_data(src_column_key, src_column_val=NULL, src_operator='=') %}

    {% if var("run_type") == 'daily' %}

         where {{src_column_key}} {{src_operator}} {{src_column_val}}

    {% elif var("run_type") == 'full-refresh' %}

    {% elif var("run_type") == 'backfill' %}

        {%- set src_is_date =  'False' -%}
        {% if 'DATE(' in src_column_key|upper %}
            {%- set src_is_date =  'True' -%}
        {% endif %}
        where {{ src_column_key }} between '{{ var("backfill_start_date") }}' and '{{ var("backfill_end_date") }}'

    {% else %}

        where {{src_column_key}} {{src_operator}} {{src_column_val}}

    {% endif %}

{% endmacro %}