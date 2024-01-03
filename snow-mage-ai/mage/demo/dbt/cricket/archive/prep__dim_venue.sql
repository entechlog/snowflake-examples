{{ config(alias="venue", materialized="view", tags=["stage", "dim"]) }}

with
    venue_data as (
        select match_data:info:venue as venue_name from {{ ref("all_match_data") }}
    ),
    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["venue_name"]) }} as venue_id,
            venue_name::varchar(256) as venue_name
        from venue_data

        union all

        select '0' as venue_id, 'Unknown'::varchar(256) as venue_name

        union all

        select '1' as venue_id, 'Not Applicable'::varchar(256) as venue_name

        union all

        select '2' as venue_id, 'All'::varchar(256) as venue_name
    ),
    deduplicated as (
        select *
        from
            (
                select
                    *,
                    row_number() over (partition by venue_name order by venue_id) as rn
                from union_with_defaults
            )
        where rn = 1
    )

select venue_id, venue_name
from deduplicated
