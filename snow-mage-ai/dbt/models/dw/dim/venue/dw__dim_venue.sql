
{{ config(
    alias = 'venue',
    materialized = 'table',
    transient = false,
    tags = ["dw", "dim"]
) }}

SELECT
    {{ dbt_utils.star(ref('stg__dim_venue')) }}
FROM {{ ref('stg__dim_venue') }}