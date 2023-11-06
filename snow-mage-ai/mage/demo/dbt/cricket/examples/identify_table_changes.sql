{% macro identify_table_changes(source_table, target_table) %}

{% set source_columns = adapter.get_columns_in_relation(source_table) %}

{% set source_columns_list = [] %}
{% for col in source_columns %}
  {% if col.name not in ['change_type', 'last_updated_by', 'last_updated_timestamp'] %}
    {% do source_columns_list.append("src." + col.name) %}
  {% endif %}
{% endfor %}

{% set target_columns_list = [] %}
{% for col_name in source_columns_list %}
    {% do target_columns_list.append(col_name.replace("src.", "tgt.")) %}
{% endfor %}

WITH 
-- Prepare the source data for comparison
source AS (
    SELECT *, 
           MD5(ARRAY_TO_STRING(ARRAY_CONSTRUCT({{ source_columns_list|join(', ') }}), ',')) AS row_hash
    FROM {{ source_table }} AS src
),

-- Get the most recent record from the target for each unique_id
latest_target AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY unique_id ORDER BY last_updated_timestamp DESC) AS rnum
    FROM {{ target_table }}
),

-- Filter the latest_target to get target data ready for comparison
target AS (
    SELECT * exclude (change_type, last_updated_by, last_updated_timestamp), 
           MD5(ARRAY_TO_STRING(ARRAY_CONSTRUCT({{ source_columns_list|join(', ') }}), ',')) AS row_hash
    FROM latest_target src
    WHERE rnum = 1
),

-- Identify records in the source that are not in the target (i.e., inserted)
inserts AS (
    SELECT 'insert' AS change_type, '{{ run_started_at }}'::timestamp AS last_updated_timestamp, '{{ this.name }}' AS last_updated_by, {{ source_columns_list|join(', ') }}
    FROM source AS src
    LEFT JOIN target AS tgt
    ON src.unique_id = tgt.unique_id
    WHERE tgt.unique_id IS NULL
),

-- Identify records in the target that are not in the source (i.e., deleted)
deletes AS (
    SELECT 'delete' AS change_type, '{{ run_started_at }}'::timestamp AS last_updated_timestamp, '{{ this.name }}' AS last_updated_by, {{ target_columns_list|join(', ') }}
    FROM target AS tgt
    LEFT JOIN source AS src
    ON tgt.unique_id = src.unique_id
    WHERE src.unique_id IS NULL 
    AND NOT EXISTS (
        SELECT 1 
        FROM latest_target lt 
        WHERE lt.unique_id = tgt.unique_id 
        AND lt.change_type = 'delete'
        AND lt.rnum = 1
    )
),

-- Identify records where the hash has changed (i.e., updated)
updates AS (
    SELECT 'update' AS change_type, '{{ run_started_at }}'::timestamp AS last_updated_timestamp, '{{ this.name }}' AS last_updated_by, {{ source_columns_list|join(', ') }}
    FROM source AS src
    INNER JOIN target AS tgt
    ON src.unique_id = tgt.unique_id
    WHERE src.row_hash <> tgt.row_hash
)

-- Combine the results from the three CTEs above
SELECT * FROM inserts
UNION ALL
SELECT * FROM deletes
UNION ALL
SELECT * FROM updates

{% endmacro %}
