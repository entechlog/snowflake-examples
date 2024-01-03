{{
    config(
        alias="player_metrics",
        materialized="incremental",
        transient=false,
        tags=["dw", "bi"],
        on_schema_change="sync_all_columns",
    )
}}

select
    dp.player_id,
    {{ dbt_utils.star(ref("dw__dim_player"), except=["player_id"]) }},
    {{ dbt_utils.star(ref("dw__fact_player_metrics"), except=["player_id"]) }}
from {{ ref("dw__dim_player") }} dp
left join {{ ref("dw__fact_player_metrics") }} fpm on dp.player_id = fpm.player_id
