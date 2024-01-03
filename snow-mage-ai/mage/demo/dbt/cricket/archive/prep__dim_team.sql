{{ config(alias="team", materialized="view", tags=["stage", "dim"]) }}

with
    team_data as (
        select value as team_name, match_data:info:team_type as team_type
        from
            {{ ref("all_match_data") }}, lateral flatten(input => match_data:info:teams)
    ),
    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["team_name"]) }} as team_id,
            team_name::varchar(256) as team_name,
            team_type::varchar(50) as team_type
        from team_data

        union all

        select
            '0' as team_id,
            'Unknown'::varchar(256) as team_name,
            'Unknown'::varchar(50) as team_type

        union all

        select
            '1' as team_id,
            'Not Applicable'::varchar(256) as team_name,
            'Not Applicable'::varchar(50) as team_type

        union all

        select
            '2' as team_id,
            'All'::varchar(256) as team_name,
            'All'::varchar(50) as team_type
    ),
    deduplicated as (
        select
            *,
            row_number() over (
                partition by team_name order by team_id, team_type desc
            ) as rn
        from union_with_defaults
        where team_id not in ('0', '1', '2')
    )

select team_id, team_name, team_type
from deduplicated
where rn = 1
