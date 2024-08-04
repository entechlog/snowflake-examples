{{ config(alias="player", materialized="view", tags=["stage", "dim"]) }}

with
    source as (
        select DISTINCT identifier, namekey_cricinfo_2 AS namekey_cricinfo, name
        from {{ ref("all_player_data") }}
    ),

    get_player_details as (
        select
            src.namekey_cricinfo,
            src.identifier,
            src.name,
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
        from source src
        left join
            {{ ref("all_player_details") }} apd on src.namekey_cricinfo = apd.player_id
    ),

    union_with_defaults as (
        select
            {{ dbt_utils.generate_surrogate_key(["namekey_cricinfo"]) }} as player_id,
            namekey_cricinfo::varchar(256) as player_cricinfo_key,
            identifier::varchar(256) as player_cricsheet_key,
            name::varchar(256) as player_name,
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
            'Unknown'::varchar(256) as player_cricinfo_key,
            'Unknown'::varchar(256) as player_cricsheet_key,
            'Unknown'::varchar(256) as player_name,
            'Unknown'::varchar(256) as date_of_birth,
            'Unknown'::varchar(256) as birth_location,
            'Unknown'::varchar(256) as batting_style,
            'Unknown'::varchar(256) as bowling_style,
            'Unknown'::varchar(256) as playing_role,
            null::variant as teams

    ),

    deduplicated as (
        select *
        from
            (
                select
                    *,
                    row_number() over (
                        partition by player_id order by player_cricinfo_key desc
                    ) as rn
                from union_with_defaults
            )
        where rn = 1
    )

select *
from deduplicated