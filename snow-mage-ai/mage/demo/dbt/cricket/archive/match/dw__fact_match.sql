{{
    config(
        alias="match",
        materialized="incremental",
        transient=false,
        tags=["dw", "fact"],
        on_schema_change="sync_all_columns",
    )
}}

with
    source as (
        select {{ dbt_utils.star(ref("prep__fact_match")) }}
        from {{ ref("prep__fact_match") }}
    )

select
    to_varchar(match_date, 'YYYYMMDD') as date_id,
    {{ dbt_utils.generate_surrogate_key(["event_name", "match_number"]) }} as event_id,
    {{ dbt_utils.generate_surrogate_key(["team_1"]) }} as team_01_team_id,
    {{ dbt_utils.generate_surrogate_key(["team_2"]) }} as team_02_team_id,
    {{ dbt_utils.generate_surrogate_key(["toss_winner"]) }} as toss_winner_team_id,
    {{ dbt_utils.generate_surrogate_key(["match_winner"]) }} as match_winner_team_id,
    {{ dbt_utils.generate_surrogate_key(["venue"]) }} as venue_id,
    {{ dbt_utils.generate_surrogate_key(["player_of_match"]) }}
    as player_of_match_player_id,
    match_type,
    match_type_number,
    gender,
    toss_decision,
    winning_innings,
    winning_margin,
    winning_wickets,
    innings_data,
    player_registry
from source src
