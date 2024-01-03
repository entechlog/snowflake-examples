{{ config(alias="event", materialized="table", transient=false, tags=["dw", "dim"]) }}

select {{ dbt_utils.star(ref("prep__dim_event")) }}
from {{ ref("prep__dim_event") }}
