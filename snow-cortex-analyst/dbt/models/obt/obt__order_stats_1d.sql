{{
  config(
    alias = 'order_stats_1d',
    tags  = ['obt', 'orders', 'daily']
  )
}}

SELECT
    order_date,
    product_category,
    region,
    revenue,
    quantity,
    discount_amount,
    order_count,
    refund_amount,
    revenue - discount_amount - refund_amount AS net_revenue
FROM {{ source('seed', 'order_stats_1d') }}
