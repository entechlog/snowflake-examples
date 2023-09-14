{{ config(
    alias = 'official',
    materialized = 'view',
    tags = ["stage", "dim"]
) }}

WITH official_registry AS (
    SELECT
        value AS official_name,
        'match_referees' AS official_role
    FROM (
        SELECT
            PARSE_JSON(match_data:info:officials) AS official_data
        FROM {{ source('cricsheet', 'all_match_data') }}
    ),
    LATERAL FLATTEN(input => official_data:match_referees) AS flattened_data

    UNION ALL

    SELECT
        value AS official_name,
        'reserve_umpires' AS official_role
    FROM (
        SELECT
            PARSE_JSON(match_data:info:officials) AS official_data
        FROM {{ source('cricsheet', 'all_match_data') }}
    ),
    LATERAL FLATTEN(input => official_data:reserve_umpires) AS flattened_data

    UNION ALL

    SELECT
        value AS official_name,
        'tv_umpires' AS official_role
    FROM (
        SELECT
            PARSE_JSON(match_data:info:officials) AS official_data
        FROM {{ source('cricsheet', 'all_match_data') }}
    ),
    LATERAL FLATTEN(input => official_data:tv_umpires) AS flattened_data

    UNION ALL

    SELECT
        value AS official_name,
        'umpires' AS official_role
    FROM (
        SELECT
            PARSE_JSON(match_data:info:officials) AS official_data
        FROM {{ source('cricsheet', 'all_match_data') }}
    ),
    LATERAL FLATTEN(input => official_data:umpires) AS flattened_data
),
union_with_defaults AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['official_role', 'official_name']) }} AS official_id,
        official_name::VARCHAR(256) AS official_name,
        official_role::VARCHAR(256) AS official_role
    FROM official_registry

    UNION ALL

    SELECT
        '0' AS official_id,
        'Unknown'::VARCHAR(256) AS official_name,
        'Unknown'::VARCHAR(256) AS official_role

    UNION ALL

    SELECT
        '1' AS official_id,
        'Not Applicable'::VARCHAR(256) AS official_name,
        'Not Applicable'::VARCHAR(256) AS official_role

    UNION ALL

    SELECT
        '2' AS official_id,
        'All'::VARCHAR(256) AS official_name,
        'All'::VARCHAR(256) AS official_role
),
deduplicated AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY official_role, official_name ORDER BY official_id) AS rn
        FROM union_with_defaults
    )
    WHERE rn = 1
)

SELECT official_id, official_name, official_role
FROM deduplicated
