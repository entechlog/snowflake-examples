{{
    config(
        alias="official", materialized="table", transient=false, tags=["dw", "dim"]
    )
}}

select {{ dbt_utils.star(ref("prep__dim_official")) }}
from {{ ref("prep__dim_official") }}
