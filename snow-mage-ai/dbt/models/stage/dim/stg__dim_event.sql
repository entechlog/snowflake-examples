{{ config(
    alias = 'event',
    materialized = 'view',
    tags = ["stage", "dim"]
) }}

WITH event_data AS (
    SELECT
        match_data:info:event:name AS event_name,
        match_data:info:event:match_number AS match_number,
        match_data:info:season AS season
    FROM {{ source('cricsheet', 'all_match_data') }}
),
union_with_defaults AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['event_name', 'match_number']) }} AS event_id,
        event_name::VARCHAR(256) AS event_name,
        match_number::INT AS match_number,
        season::VARCHAR(256) AS season
    FROM event_data

    UNION ALL

    SELECT '0' AS event_id,
           'Unknown'::VARCHAR(256) AS event_name,
           0 AS match_number,
           'Unknown'::VARCHAR(256) AS season

    UNION ALL

    SELECT '1' AS event_id,
           'Not Applicable'::VARCHAR(256) AS event_name,
           0 AS match_number,
           'Not Applicable'::VARCHAR(256) AS season

    UNION ALL

    SELECT '2' AS event_id,
           'All'::VARCHAR(256) AS event_name,
           0 AS match_number,
           'All'::VARCHAR(256) AS season
),
deduplicated AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY event_name, match_number, season ORDER BY event_id) AS rn
        FROM union_with_defaults
    )
    WHERE rn = 1
)

SELECT event_id, event_name, match_number, season
FROM deduplicated