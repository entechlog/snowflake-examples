{{ config(alias="player", materialized="table", transient=false, tags=["dw", "dim"]) }}

select {{ dbt_utils.star(ref("prep__dim_player"), except=["RN"]) }}
from {{ ref("prep__dim_player") }}
