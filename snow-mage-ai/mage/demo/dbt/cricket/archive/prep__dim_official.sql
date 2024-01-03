{{ config(alias="official", materialized="view", tags=["stage", "dim"]) }}

with
    official_registry as (
        select value as official_name, 'match_referees' as official_role
        from
            (
                select parse_json(match_data:info:officials) as official_data
                from {{ ref("all_match_data") }}
            ),
            lateral flatten(input => official_data:match_referees) as flattened_data

        union all

        select value as official_name, 'reserve_umpires' as official_role
        from
            (
                select parse_json(match_data:info:officials) as official_data
                from {{ ref("all_match_data") }}
            ),
            lateral flatten(input => official_data:reserve_umpires) as flattened_data

        union all

        select value as official_name, 'tv_umpires' as official_role
        from
            (
                select parse_json(match_data:info:officials) as official_data
                from {{ ref("all_match_data") }}
            ),
            lateral flatten(input => official_data:tv_umpires) as flattened_data

        union all

        select value as official_name, 'umpires' as official_role
        from
            (
                select parse_json(match_data:info:officials) as official_data
                from {{ ref("all_match_data") }}
            ),
            lateral flatten(input => official_data:umpires) as flattened_data
    ),
    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["official_role", "official_name"]) }}
            as official_id,
            official_name::varchar(256) as official_name,
            official_role::varchar(256) as official_role
        from official_registry

        union all

        select
            '0' as official_id,
            'Unknown'::varchar(256) as official_name,
            'Unknown'::varchar(256) as official_role

        union all

        select
            '1' as official_id,
            'Not Applicable'::varchar(256) as official_name,
            'Not Applicable'::varchar(256) as official_role

        union all

        select
            '2' as official_id,
            'All'::varchar(256) as official_name,
            'All'::varchar(256) as official_role
    ),
    deduplicated as (
        select *
        from
            (
                select
                    *,
                    row_number() over (
                        partition by official_role, official_name order by official_id
                    ) as rn
                from union_with_defaults
            )
        where rn = 1
    )

select official_id, official_name, official_role
from deduplicated
