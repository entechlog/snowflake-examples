{{ config(alias="player", materialized="table", transient=false, tags=["dw", "dim"]) }}

select {{ dbt_utils.star(ref("prep__dim_player")) }}
from {{ ref("prep__dim_player") }}
