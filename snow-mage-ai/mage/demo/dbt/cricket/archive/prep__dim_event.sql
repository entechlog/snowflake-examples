{{ config(alias="event", materialized="view", tags=["stage", "dim"]) }}

with
    event_data as (
        select
            match_data:info:event:name as event_name,
            match_data:info:event:match_number as match_number,
            match_data:info:season as season
        from {{ ref("all_match_data") }}
    ),
    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["event_name", "match_number"]) }}
            as event_id,
            event_name::varchar(256) as event_name,
            match_number::int as match_number,
            season::varchar(256) as season
        from event_data

        union all

        select
            '0' as event_id,
            'Unknown'::varchar(256) as event_name,
            0 as match_number,
            'Unknown'::varchar(256) as season

        union all

        select
            '1' as event_id,
            'Not Applicable'::varchar(256) as event_name,
            0 as match_number,
            'Not Applicable'::varchar(256) as season

        union all

        select
            '2' as event_id,
            'All'::varchar(256) as event_name,
            0 as match_number,
            'All'::varchar(256) as season
    ),
    deduplicated as (
        select *
        from
            (
                select
                    *,
                    row_number() over (
                        partition by event_name, match_number, season order by event_id
                    ) as rn
                from union_with_defaults
            )
        where rn = 1
    )

select event_id, event_name, match_number, season
from deduplicated
