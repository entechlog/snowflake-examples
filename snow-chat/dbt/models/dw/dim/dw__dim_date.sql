{{ config(
  alias='date',
  materialized='table',
  transient=false,
  tags=['dw', 'dim']
) }}

SELECT
  date_id,
  date,
  year,
  month,
  day,
  day_name,
  month_name,
  day_of_week,
  day_of_year,
  is_weekend,
  is_holiday
FROM {{ ref('stg__dim_date') }}
