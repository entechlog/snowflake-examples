{{
  config(
    alias = 'order_stats_1d',
    materialized = 'semantic_view',
    tags = ['semantic', 'orders', 'daily']
  )
}}

{#
  Semantic View: Daily Order Statistics

  1:1 mapping to the OBT layer table.
  Uses FACTS (not METRICS) since the OBT is already at 1-day grain.
  Rich COMMENT metadata guides Cortex Analyst on correct aggregation.
#}

TABLES(
  order_stats_1d AS {{ ref('obt__order_stats_1d') }}
    COMMENT = 'Daily order statistics at product_category + region grain. Each row represents one day of sales for a specific product category in a specific region.'
)

FACTS(
  order_stats_1d.revenue AS revenue
    WITH SYNONYMS ('sales', 'gross sales', 'total sales')
    COMMENT = 'Gross revenue in USD. CUMULATIVE METRIC: SUM() is valid both across dimensions (categories, regions) and across time (days).',

  order_stats_1d.quantity AS quantity
    WITH SYNONYMS ('units sold', 'items sold')
    COMMENT = 'Number of items sold. CUMULATIVE METRIC: SUM() is valid across dimensions and time.',

  order_stats_1d.discount_amount AS discount_amount
    WITH SYNONYMS ('discounts', 'promotions')
    COMMENT = 'Total discount amount in USD. CUMULATIVE METRIC: SUM() across dimensions and time.',

  order_stats_1d.order_count AS order_count
    WITH SYNONYMS ('number of orders', 'total orders')
    COMMENT = 'Count of distinct orders. CUMULATIVE METRIC: SUM() across dimensions and time.',

  order_stats_1d.refund_amount AS refund_amount
    WITH SYNONYMS ('returns', 'refunds')
    COMMENT = 'Total refund amount in USD. CUMULATIVE METRIC: SUM() across dimensions and time.',

  order_stats_1d.net_revenue AS net_revenue
    WITH SYNONYMS ('net sales', 'net income')
    COMMENT = 'Net revenue after discounts and refunds (revenue - discount_amount - refund_amount). CUMULATIVE METRIC: SUM() across dimensions and time.'
)

DIMENSIONS(
  order_stats_1d.order_date AS order_date
    COMMENT = 'Calendar date of the order. Query MAX(order_date) to find latest available data.',

  order_stats_1d.product_category AS product_category
    COMMENT = 'Product category name. Values: Electronics, Clothing, Home & Garden, Sports.',

  order_stats_1d.region AS region
    COMMENT = 'Geographic sales region. Values: Northeast, Southeast, Midwest, West.'
)

COMMENT = 'Semantic view for daily order statistics by product category and region'
