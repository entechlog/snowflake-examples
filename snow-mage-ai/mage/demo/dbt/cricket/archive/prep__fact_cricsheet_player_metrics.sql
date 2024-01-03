{{ config(alias="cricsheet_player_metrics", materialized="table", tags=["stage", "fact"]) }}

with
    source as (
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

    flattened_deliveries as (
        select
            data.match_date,
            data.match_type,
            data.event_name,
            data.season,
            data.match_number,
            inn.value:team::varchar,
            del.value:batter::varchar as batter,
            del.value:bowler::varchar as bowler,
            del.value:runs:batter as runs_batter,
            del.value:runs:extras as runs_extras,
            del.value:runs:total as runs_total,
            del.value:wickets as wickets
        from
            source as data,
            lateral flatten(input => data.innings_data) as inn,
            lateral flatten(input => inn.value:overs) as ovr,
            lateral flatten(input => ovr.value:deliveries) as del
    ),

    -- Calculate batting metrics
    batting_metrics_agg as (
        select
            fd.match_date,
            fd.match_type,
            fd.event_name,
            fd.season,
            fd.match_number,
            fd.batter,
            sum(fd.runs_batter) as runs_batter
        from flattened_deliveries as fd
        group by
            fd.match_date,
            fd.match_type,
            fd.event_name,
            fd.season,
            fd.match_number,
            fd.batter
    ),

    batting_metrics as (
        select
            batter,
            match_type,
            sum(case when runs_batter >= 100 then 1 else 0 end) as centuries,
            sum(
                case when runs_batter >= 50 and runs_batter < 100 then 1 else 0 end
            ) as half_centuries,
            avg(
                case when runs_batter > 0 then runs_batter else null end
            ) as batting_average
        from batting_metrics_agg
        group by batter, match_type
    ),

    -- Calculate bowling metrics
    bowling_metrics_agg as (
        select
            fd.match_date,
            fd.match_type,
            fd.event_name,
            fd.season,
            fd.match_number,
            fd.bowler,
            count(case when fd.wickets is not null then fd.batter end) as wickets_taken
        from flattened_deliveries as fd
        group by
            fd.match_date,
            fd.match_type,
            fd.event_name,
            fd.season,
            fd.match_number,
            fd.bowler
    ),

    bowling_metrics as (
        select bowler, match_type, sum(wickets_taken) as wickets_taken
        from bowling_metrics_agg
        group by bowler, match_type
    ),

    -- Calculate catches metrics
    catches_metrics_agg as (
    select
        fd.match_date,
        fd.match_type,
        fd.event_name,
        fd.season,
        fd.match_number,
        case
            when fd.wickets is not null and fd.wickets[0].kind = 'caught'
            then fd.wickets[0].fielders[0].name::varchar
        end as caught_by,
        count(
            case
                when fd.wickets is not null and fd.wickets[0].kind = 'caught'
                then 1
            end
        ) as catches_made
    from flattened_deliveries as fd
    where fd.wickets is not null
    group by
        fd.match_date,
        fd.match_type,
        fd.event_name,
        fd.season,
        fd.match_number,
        caught_by
    ),

    catches_metrics as (
        select caught_by, match_type, sum(catches_made) as catches_made
        from catches_metrics_agg
        group by caught_by, match_type
    )

-- Combine all metrics into the final table
select
    coalesce(b.batter, bo.bowler, c.caught_by) as player,
    coalesce(b.match_type, bo.match_type, c.match_type) as match_type,
    centuries,
    half_centuries,
    batting_average,
    wickets_taken
    catches_made
from batting_metrics as b
full outer join
    bowling_metrics as bo on b.batter = bo.bowler and b.match_type = bo.match_type
full outer join
    catches_metrics as c on b.batter = c.caught_by and b.match_type = c.match_type
