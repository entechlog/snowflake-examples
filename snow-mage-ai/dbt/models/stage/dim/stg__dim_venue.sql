{{ config(
    alias = 'venue',
    materialized = 'view',
    tags = ["stage", "dim"]
) }}

WITH venue_data AS (
    SELECT
        match_data:info:venue AS venue_name
    FROM {{ source('cricsheet', 'all_match_data') }}
),
union_with_defaults AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['venue_name']) }} AS venue_id,
        venue_name::VARCHAR(256) AS venue_name
    FROM venue_data

    UNION ALL

    SELECT '0' AS venue_id,
           'Unknown'::VARCHAR(256) AS venue_name

    UNION ALL

    SELECT '1' AS venue_id,
           'Not Applicable'::VARCHAR(256) AS venue_name

    UNION ALL

    SELECT '2' AS venue_id,
           'All'::VARCHAR(256) AS venue_name
),
deduplicated AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY venue_name ORDER BY venue_id) AS rn
        FROM union_with_defaults
    )
    WHERE rn = 1
)

SELECT venue_id, venue_name
FROM deduplicated