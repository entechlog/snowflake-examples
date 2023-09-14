{{ config(
    alias = 'player',
    materialized = 'view',
    tags = ["stage", "dim"]
) }}

WITH player_registry AS (
    SELECT
        key AS player_name,
        value AS player_code
    FROM (
        SELECT
            PARSE_JSON(match_data:info:registry:people) AS player_data
        FROM {{ source('cricsheet', 'all_match_data') }}
    )
    CROSS JOIN LATERAL FLATTEN(input => player_data) AS flattened_data(key, value)
),
union_with_defaults AS (
    SELECT  {{ dbt_utils.generate_surrogate_key(['player_code']) }} AS player_id,
           player_code::VARCHAR(256) AS player_code,
           player_name::VARCHAR(256) AS player_name
    FROM player_registry

    UNION ALL

    SELECT '0' AS player_id,
           'Unknown'::VARCHAR(256) AS player_code,
           'Unknown'::VARCHAR(256) AS player_name

    UNION ALL

    SELECT '1' AS player_id,
           'Not Applicable'::VARCHAR(256) AS player_code,
           'Not Applicable'::VARCHAR(256) AS player_name

    UNION ALL

    SELECT '2' AS player_id,
           'All'::VARCHAR(256) AS player_code,
           'All'::VARCHAR(256) AS player_name
),
deduplicated AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY player_code ORDER BY player_id, player_name DESC) AS rn
        FROM union_with_defaults
    )
    WHERE rn = 1
)

SELECT player_id, player_code, player_name
FROM deduplicated