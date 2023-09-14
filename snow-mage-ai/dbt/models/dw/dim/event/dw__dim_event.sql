{{ config(
    alias = 'event',
    materialized = 'table',
    transient = false,
    tags = ["dw", "dim"]
) }}

SELECT
    {{ dbt_utils.star(ref('stg__dim_event')) }}
FROM {{ ref('stg__dim_event') }}