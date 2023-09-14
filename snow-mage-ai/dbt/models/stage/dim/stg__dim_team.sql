{{ config(
    alias = 'team',
    materialized = 'view',
    tags = ["stage", "dim"]
) }}

WITH team_data AS (
    SELECT value AS team_name,
           match_data:info:team_type AS team_type
    FROM {{ source('cricsheet', 'all_match_data') }},
    LATERAL FLATTEN(input => match_data:info:teams)
),
union_with_defaults AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['team_name']) }} AS team_id,
        team_name::VARCHAR(256) AS team_name,
        team_type::VARCHAR(50) AS team_type
    FROM team_data

    UNION ALL

    SELECT '0' AS team_id,
           'Unknown'::VARCHAR(256) AS team_name,
           'Unknown'::VARCHAR(50) AS team_type

    UNION ALL

    SELECT '1' AS team_id,
           'Not Applicable'::VARCHAR(256) AS team_name,
           'Not Applicable'::VARCHAR(50) AS team_type

    UNION ALL

    SELECT '2' AS team_id,
           'All'::VARCHAR(256) AS team_name,
           'All'::VARCHAR(50) AS team_type
),
deduplicated AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY team_name ORDER BY team_id, team_type DESC) AS rn
    FROM union_with_defaults
    WHERE team_id NOT IN ('0', '1', '2')
)

SELECT team_id, team_name, team_type
FROM deduplicated
WHERE rn = 1
