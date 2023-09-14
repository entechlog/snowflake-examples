{{ config(
    alias = 'team',
    materialized = 'table',
    transient = false,
    tags = ["dw", "dim"]
) }}

SELECT
    {{ dbt_utils.star(ref('stg__dim_team')) }}
FROM {{ ref('stg__dim_team') }}
