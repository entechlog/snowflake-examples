{{ config(
    alias = 'official',
    materialized = 'table',
    transient = false,
    tags = ["dw", "dim"]
) }}

SELECT
    {{ dbt_utils.star(ref('stg__dim_official')) }}
FROM {{ ref('stg__dim_official') }}
