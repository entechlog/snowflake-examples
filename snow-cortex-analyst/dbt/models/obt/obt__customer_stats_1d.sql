{{
  config(
    alias = 'customer_stats_1d',
    tags  = ['obt', 'customers', 'daily']
  )
}}

SELECT
    stats_date,
    customer_segment,
    region,
    total_spend,
    order_count,
    new_customers,
    returning_customers,
    churn_count,
    new_customers + returning_customers AS total_active_customers
FROM {{ source('seed', 'customer_stats_1d') }}
