{{
    config(
        alias="cricinfo_player_metrics",
        materialized="table",
        tags=["stage", "fact"],
    )
}}

with
    source as (
        select
            player_id as player_cricinfo_key,
            player_code as player_cricsheet_key,
            player_name,
            -- Batting Metrics for ODI
            TRY_TO_NUMBER(odi_summary:batting:balls_faced::varchar) as odi_batting_balls_faced,
            TRY_TO_DECIMAL(odi_summary:batting:batting_average::varchar, 10, 2) as odi_batting_average,
            TRY_TO_DECIMAL(odi_summary:batting:batting_strike_rate::varchar, 10, 2) as odi_batting_strike_rate,
            TRY_TO_NUMBER(odi_summary:batting:boundary_fours::varchar) as odi_batting_boundary_fours,
            TRY_TO_NUMBER(odi_summary:batting:boundary_sixes::varchar) as odi_batting_boundary_sixes,
            TRY_TO_NUMBER(odi_summary:batting:ducks_scored::varchar) as odi_batting_ducks_scored,
            odi_summary:batting:highest_innings_score as odi_batting_highest_score,
            TRY_TO_NUMBER(odi_summary:batting:hundreds_scored::varchar) as odi_batting_hundreds_scored,
            TRY_TO_NUMBER(odi_summary:batting:innings_batted::varchar) as odi_batting_innings_batted,
            TRY_TO_NUMBER(odi_summary:batting:matches_played::varchar) as odi_batting_matches_played,
            TRY_TO_NUMBER(odi_summary:batting:not_outs::varchar) as odi_batting_not_outs,
            odi_summary:batting:playing_span as odi_batting_playing_span,
            TRY_TO_NUMBER(odi_summary:batting:runs_scored::varchar) as odi_batting_runs_scored,
            TRY_TO_NUMBER(odi_summary:batting:scores_between_50_and_99::varchar) as odi_batting_scores_50_99,

            -- Bowling Metrics for ODI
            odi_summary:bowling:best_bowling_in_a_match as odi_bowling_best_in_a_match,
            odi_summary:bowling:best_bowling_in_an_innings as odi_bowling_best_in_an_inning,
            TRY_TO_DECIMAL(odi_summary:bowling:bowling_average::varchar, 10, 2) as odi_bowling_average,
            TRY_TO_DECIMAL(odi_summary:bowling:bowling_strike_rate::varchar, 10, 2) as odi_bowling_strike_rate,
            TRY_TO_DECIMAL(odi_summary:bowling:economy_rate::varchar, 10, 2) as odi_bowling_economy_rate,
            TRY_TO_NUMBER(odi_summary:bowling:five_wickets_in_an_inns::varchar) as odi_bowling_five_wickets,
            TRY_TO_NUMBER(odi_summary:bowling:innings_bowled_in::varchar) as odi_bowling_innings_bowled,
            TRY_TO_NUMBER(odi_summary:bowling:maidens_earned::varchar) as odi_bowling_maidens_earned,
            TRY_TO_NUMBER(odi_summary:bowling:matches_played::varchar) as odi_bowling_matches_played,
            TRY_TO_DECIMAL(odi_summary:bowling:overs_bowled::varchar, 10, 2) as odi_bowling_overs_bowled,
            odi_summary:bowling:playing_span as odi_bowling_playing_span,
            TRY_TO_NUMBER(odi_summary:bowling:runs_conceded::varchar) as odi_bowling_runs_conceded,
            TRY_TO_NUMBER(odi_summary:bowling:ten_wickets_in_a_match::varchar) as odi_bowling_ten_wickets,
            TRY_TO_NUMBER(odi_summary:bowling:wickets_taken::varchar) as odi_bowling_wickets_taken,

            -- Fielding Metrics for ODI
            TRY_TO_NUMBER(odi_summary:fielding:catches_as_a_fielder::varchar) as odi_fielding_catches_as_fielder,
            TRY_TO_NUMBER(odi_summary:fielding:catches_as_a_keeper::varchar) as odi_fielding_catches_as_keeper,
            TRY_TO_NUMBER(odi_summary:fielding:catches_taken::varchar) as odi_fielding_catches_taken,
            TRY_TO_DECIMAL(odi_summary:fielding:dismissals_per_innings::varchar, 10, 2) as odi_fielding_dismissals_per_inning,
            TRY_TO_NUMBER(odi_summary:fielding:fielding_dismissals_made::varchar) as odi_fielding_dismissals_made,
            TRY_TO_NUMBER(odi_summary:fielding:innings_fielded::varchar) as odi_fielding_innings_fielded,
            TRY_TO_NUMBER(odi_summary:fielding:matches_played::varchar) as odi_fielding_matches_played,
            odi_summary:fielding:max_dismissals_in_an_inns as odi_fielding_max_dismissals,
            odi_summary:fielding:playing_span as odi_fielding_playing_span,
            TRY_TO_NUMBER(odi_summary:fielding:stumpings_made::varchar) as odi_fielding_stumpings_made,

            -- Batting Metrics for T20
            TRY_TO_NUMBER(t20_summary:batting:balls_faced::varchar) as t20_batting_balls_faced,
            TRY_TO_DECIMAL(t20_summary:batting:batting_average::varchar, 10, 2) as t20_batting_average,
            TRY_TO_DECIMAL(t20_summary:batting:batting_strike_rate::varchar, 10, 2) as t20_batting_strike_rate,
            TRY_TO_NUMBER(t20_summary:batting:boundary_fours::varchar) as t20_batting_boundary_fours,
            TRY_TO_NUMBER(t20_summary:batting:boundary_sixes::varchar) as t20_batting_boundary_sixes,
            TRY_TO_NUMBER(t20_summary:batting:ducks_scored::varchar) as t20_batting_ducks_scored,
            t20_summary:batting:highest_innings_score as t20_batting_highest_score,
            TRY_TO_NUMBER(t20_summary:batting:hundreds_scored::varchar) as t20_batting_hundreds_scored,
            TRY_TO_NUMBER(t20_summary:batting:innings_batted::varchar) as t20_batting_innings_batted,
            TRY_TO_NUMBER(t20_summary:batting:matches_played::varchar) as t20_batting_matches_played,
            TRY_TO_NUMBER(t20_summary:batting:not_outs::varchar) as t20_batting_not_outs,
            t20_summary:batting:playing_span as t20_batting_playing_span,
            TRY_TO_NUMBER(t20_summary:batting:runs_scored::varchar) as t20_batting_runs_scored,
            TRY_TO_NUMBER(t20_summary:batting:scores_between_50_and_99::varchar) as t20_batting_scores_50_99,

            -- Bowling Metrics for T20
            t20_summary:bowling:best_bowling_in_a_match as t20_bowling_best_in_a_match,
            t20_summary:bowling:best_bowling_in_an_innings as t20_bowling_best_in_an_inning,
            TRY_TO_DECIMAL(t20_summary:bowling:bowling_average::varchar, 10, 2) as t20_bowling_average,
            TRY_TO_DECIMAL(t20_summary:bowling:bowling_strike_rate::varchar, 10, 2) as t20_bowling_strike_rate,
            TRY_TO_DECIMAL(t20_summary:bowling:economy_rate::varchar, 10, 2) as t20_bowling_economy_rate,
            TRY_TO_NUMBER(t20_summary:bowling:five_wickets_in_an_inns::varchar) as t20_bowling_five_wickets,
            TRY_TO_NUMBER(t20_summary:bowling:innings_bowled_in::varchar) as t20_bowling_innings_bowled,
            TRY_TO_NUMBER(t20_summary:bowling:maidens_earned::varchar) as t20_bowling_maidens_earned,
            TRY_TO_NUMBER(t20_summary:bowling:matches_played::varchar) as t20_bowling_matches_played,
            TRY_TO_DECIMAL(t20_summary:bowling:overs_bowled::varchar, 10, 2) as t20_bowling_overs_bowled,
            t20_summary:bowling:playing_span as t20_bowling_playing_span,
            TRY_TO_NUMBER(t20_summary:bowling:runs_conceded::varchar) as t20_bowling_runs_conceded,
            TRY_TO_NUMBER(t20_summary:bowling:ten_wickets_in_a_match::varchar) as t20_bowling_ten_wickets,
            TRY_TO_NUMBER(t20_summary:bowling:wickets_taken::varchar) as t20_bowling_wickets_taken,

            -- Fielding Metrics for T20
            TRY_TO_NUMBER(t20_summary:fielding:catches_as_a_fielder::varchar) as t20_fielding_catches_as_fielder,
            TRY_TO_NUMBER(t20_summary:fielding:catches_as_a_keeper::varchar) as t20_fielding_catches_as_keeper,
            TRY_TO_NUMBER(t20_summary:fielding:catches_taken::varchar) as t20_fielding_catches_taken,
            TRY_TO_DECIMAL(t20_summary:fielding:dismissals_per_innings::varchar, 10, 2) as t20_fielding_dismissals_per_inning,
            TRY_TO_NUMBER(t20_summary:fielding:fielding_dismissals_made::varchar) as t20_fielding_dismissals_made,
            TRY_TO_NUMBER(t20_summary:fielding:innings_fielded::varchar) as t20_fielding_innings_fielded,
            TRY_TO_NUMBER(t20_summary:fielding:matches_played::varchar) as t20_fielding_matches_played,
            t20_summary:fielding:max_dismissals_in_an_inns as t20_fielding_max_dismissals,
            t20_summary:fielding:playing_span as t20_fielding_playing_span,
            TRY_TO_NUMBER(t20_summary:fielding:stumpings_made::varchar) as t20_fielding_stumpings_made,

            -- Batting Metrics for TEST
             TRY_TO_NUMBER(test_summary:batting:balls_faced::varchar) as test_batting_balls_faced,
            TRY_TO_DECIMAL(test_summary:batting:batting_average::varchar, 10, 2) as test_batting_average,
            TRY_TO_DECIMAL(test_summary:batting:batting_strike_rate::varchar, 10, 2) as test_batting_strike_rate,
            TRY_TO_NUMBER(test_summary:batting:boundary_fours::varchar) as test_batting_boundary_fours,
            TRY_TO_NUMBER(test_summary:batting:boundary_sixes::varchar) as test_batting_boundary_sixes,
            TRY_TO_NUMBER(test_summary:batting:ducks_scored::varchar) as test_batting_ducks_scored,
            test_summary:batting:highest_innings_score as test_batting_highest_score,
            TRY_TO_NUMBER(test_summary:batting:hundreds_scored::varchar) as test_batting_hundreds_scored,
            TRY_TO_NUMBER(test_summary:batting:innings_batted::varchar) as test_batting_innings_batted,
            TRY_TO_NUMBER(test_summary:batting:matches_played::varchar) as test_batting_matches_played,
            TRY_TO_NUMBER(test_summary:batting:not_outs::varchar) as test_batting_not_outs,
            test_summary:batting:playing_span as test_batting_playing_span,
            TRY_TO_NUMBER(test_summary:batting:runs_scored::varchar) as test_batting_runs_scored,
            TRY_TO_NUMBER(test_summary:batting:scores_between_50_and_99::varchar) as test_batting_scores_50_99,

            -- Bowling Metrics for TEST
            test_summary:bowling:best_bowling_in_a_match as test_bowling_best_in_a_match,
            test_summary:bowling:best_bowling_in_an_innings as test_bowling_best_in_an_inning,
            TRY_TO_DECIMAL(test_summary:bowling:bowling_average::varchar, 10, 2) as test_bowling_average,
            TRY_TO_DECIMAL(test_summary:bowling:bowling_strike_rate::varchar, 10, 2) as test_bowling_strike_rate,
            TRY_TO_DECIMAL(test_summary:bowling:economy_rate::varchar, 10, 2) as test_bowling_economy_rate,
            TRY_TO_NUMBER(test_summary:bowling:five_wickets_in_an_inns::varchar) as test_bowling_five_wickets,
            TRY_TO_NUMBER(test_summary:bowling:innings_bowled_in::varchar) as test_bowling_innings_bowled,
            TRY_TO_NUMBER(test_summary:bowling:maidens_earned::varchar) as test_bowling_maidens_earned,
            TRY_TO_NUMBER(test_summary:bowling:matches_played::varchar) as test_bowling_matches_played,
            TRY_TO_DECIMAL(test_summary:bowling:overs_bowled::varchar, 10, 2) as test_bowling_overs_bowled,
            test_summary:bowling:playing_span as test_bowling_playing_span,
            TRY_TO_NUMBER(test_summary:bowling:runs_conceded::varchar) as test_bowling_runs_conceded,
            TRY_TO_NUMBER(test_summary:bowling:ten_wickets_in_a_match::varchar) as test_bowling_ten_wickets,
            TRY_TO_NUMBER(test_summary:bowling:wickets_taken::varchar) as test_bowling_wickets_taken,

            -- Fielding Metrics for TEST
            TRY_TO_NUMBER(test_summary:fielding:catches_as_a_fielder::varchar) as test_fielding_catches_as_fielder,
            TRY_TO_NUMBER(test_summary:fielding:catches_as_a_keeper::varchar) as test_fielding_catches_as_keeper,
            TRY_TO_NUMBER(test_summary:fielding:catches_taken::varchar) as test_fielding_catches_taken,
            TRY_TO_DECIMAL(test_summary:fielding:dismissals_per_innings::varchar, 10, 2) as test_fielding_dismissals_per_inning,
            TRY_TO_NUMBER(test_summary:fielding:fielding_dismissals_made::varchar) as test_fielding_dismissals_made,
            TRY_TO_NUMBER(test_summary:fielding:innings_fielded::varchar) as test_fielding_innings_fielded,
            TRY_TO_NUMBER(test_summary:fielding:matches_played::varchar) as test_fielding_matches_played,
            test_summary:fielding:max_dismissals_in_an_inns as test_fielding_max_dismissals,
            test_summary:fielding:playing_span as test_fielding_playing_span,
            TRY_TO_NUMBER(test_summary:fielding:stumpings_made::varchar) as test_fielding_stumpings_made

        from {{ ref("all_player_metrics") }}
    )

select *
from source
