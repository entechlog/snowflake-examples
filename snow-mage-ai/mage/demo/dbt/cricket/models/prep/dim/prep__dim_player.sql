{{ config(alias="player", materialized="view", tags=["stage", "dim"]) }}

with
    player_registry as (
        select DISTINCT key as player_name, value as src_player_id
        from
            (
                select parse_json(match_data:info:registry:people) as player_data
                from {{ ref("all_match_data") }}
            )
        cross join lateral flatten(input => player_data) as flattened_data(key, value)
    ),

    get_player_details as (
        select
            src.src_player_id,
            apd.player_code,
            src.player_name,
            try_to_date(
                trim(split_part(apd.born, ',', 2))
                || '-'
                || left(trim(split_part(apd.born, ' ', 1)), 3)
                || '-'
                || left(trim(split_part(apd.born, ' ', 2)), 2),
                'YYYY-Mon-DD'
            ) as date_of_birth,
            case
                when
                    trim(split_part(born, ',', 3))
                    || ', '
                    || trim(split_part(born, ',', 4))
                    = ', '
                then null
                else
                    trim(
                        trim(split_part(born, ',', 3))
                        || ', '
                        || trim(split_part(born, ',', 4)),
                        ', '
                    )
            end as birth_location,
            apd.batting_style,
            apd.bowling_style,
            apd.playing_role,
            apd.teams
        from player_registry src
        left join
            {{ ref("all_player_details") }} apd on src.src_player_id = apd.player_code
    ),

    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["src_player_id"]) }} as player_id,
            src_player_id::varchar(256) as src_player_id,
            player_code::varchar(256) as player_code,
            player_name::varchar(256) as player_name,
            date_of_birth::varchar(256) as date_of_birth,
            birth_location::varchar(256) as birth_location,
            batting_style::varchar(256) as batting_style,
            bowling_style::varchar(256) as bowling_style,
            playing_role::varchar(256) as playing_role,
            teams::variant as teams
        from get_player_details

        union all

        select
            '0' as player_id,
            'Unknown'::varchar(256) as src_player_id,
            'Unknown'::varchar(256) as player_code,
            'Unknown'::varchar(256) as player_name,
            'Unknown'::varchar(256) as date_of_birth,
            'Unknown'::varchar(256) as birth_location,
            'Unknown'::varchar(256) as batting_style,
            'Unknown'::varchar(256) as bowling_style,
            'Unknown'::varchar(256) as playing_role,
            null::variant as teams

        union all

        select
            '1' as player_id,
            'Not Applicable'::varchar(256) as src_player_id,
            'Not Applicable'::varchar(256) as player_code,
            'Not Applicable'::varchar(256) as player_name,
            'Not Applicable'::varchar(256) as date_of_birth,
            'Not Applicable'::varchar(256) as birth_location,
            'Not Applicable'::varchar(256) as batting_style,
            'Not Applicable'::varchar(256) as bowling_style,
            'Not Applicable'::varchar(256) as playing_role,
            null::variant as teams

        union all

        select
            '2' as player_id,
            'All'::varchar(256) as src_player_id,
            'All'::varchar(256) as player_code,
            'All'::varchar(256) as player_name,
            'All'::varchar(256) as date_of_birth,
            'All'::varchar(256) as birth_location,
            'All'::varchar(256) as batting_style,
            'All'::varchar(256) as bowling_style,
            'All'::varchar(256) as playing_role,
            null::variant as teams
    ),
    deduplicated as (
        select *
        from
            (
                select
                    *,
                    row_number() over (
                        partition by src_player_id order by player_id, player_name desc
                    ) as rn
                from union_with_defaults
            )
        where rn = 1
    )

select
    player_id,
    src_player_id,
    player_code,
    player_name,
    date_of_birth,
    birth_location,
    batting_style,
    bowling_style,
    playing_role,
    teams
from deduplicated
