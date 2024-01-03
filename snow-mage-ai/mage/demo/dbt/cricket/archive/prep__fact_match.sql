{{ config(alias="match", materialized="view", tags=["stage", "fact"]) }}

with
    standardize_data as (
        select
            match_data:info:dates[0]::date as match_date,
            match_data:info:match_type::varchar(256) as match_type,
            match_data:info:match_type_number::int as match_type_number,
            match_data:info:gender::varchar(256) as gender,
            match_data:info:event:name::varchar(256) as event_name,
            match_data:info:season::varchar(256) as season,
            match_data:info:event:match_number::varchar(256) as match_number,
            match_data:info:team_type::varchar(256) as team_type,
            match_data:info:teams[0]::varchar(256) as team_1,
            match_data:info:teams[1]::varchar(256) as team_2,
            match_data:info:venue::varchar(256) as venue,
            match_data:info:toss:decision::varchar(256) as toss_decision,
            match_data:info:toss:winner::varchar(256) as toss_winner,
            match_data:info:outcome:winner::varchar(256) as match_winner,
            match_data:info:outcome:by:innings::int as winning_innings,
            match_data:info:outcome:by:runs::int as winning_margin,
            match_data:info:outcome:by:wickets::int as winning_wickets,
            match_data:info:player_of_match[0]::varchar(256) as player_of_match,
            match_data:innings as innings_data,
            match_data:info:registry:people as player_registry
        from {{ ref("all_match_data") }}
    ),

    deduplicated as (
        select
            *,
            row_number() over (
                partition by match_date, match_type, match_type_number, gender
                order by match_date, match_type, match_type_number, gender
            ) as row_num
        from standardize_data
    )

select *
from deduplicated
where row_num = 1
