{{ config(
    alias = 'fact_match',
    materialized = 'view',
    tags = ["stage", "fact"]
) }}

WITH standardize_data AS (
    SELECT
        match_data:info:dates[0]::DATE AS match_date,
        match_data:info:match_type::VARCHAR(256) AS match_type,
        match_data:info:match_type_number::INT AS match_type_number,
        match_data:info:gender::VARCHAR(256) AS gender,
        match_data:info:event:name::VARCHAR(256) AS match_name,
        match_data:info:season::VARCHAR(256) AS season,
        match_data:info:event:match_number::VARCHAR(256) AS match_number,
        match_data:info:team_type::VARCHAR(256) AS team_type,
        match_data:info:teams[0]::VARCHAR(256) AS team_1,
        match_data:info:teams[1]::VARCHAR(256) AS team_2,
        match_data:info:venue::VARCHAR(256) AS venue,
        match_data:info:toss:decision::VARCHAR(256) AS toss_decision,
        match_data:info:toss:winner::VARCHAR(256) AS toss_winner,
        match_data:info:outcome:winner::VARCHAR(256) AS match_winner,
        match_data:info:outcome:by:innings::INT AS winning_innings,
        match_data:info:outcome:by:runs::INT AS winning_margin,
        match_data:info:outcome:by:wickets::INT AS winning_wickets,
         match_data:info:player_of_match[0]::VARCHAR(256) AS player_of_match,
        match_data:innings AS innings_data,
        match_data:info:registry:people AS player_registry
    FROM {{ source('cricsheet', 'all_match_data') }}
),

deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY match_date, match_type, match_type_number, gender ORDER BY match_date, match_type, match_type_number, gender) AS row_num
  FROM standardize_data
)

SELECT *
FROM deduplicated
WHERE row_num = 1
