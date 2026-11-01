{{
  config(
    alias = 'customer_stats_1d',
    materialized = 'semantic_view',
    tags = ['semantic', 'customers', 'daily']
  )
}}

{#
  Semantic View: Daily Customer Statistics

  1:1 mapping to the OBT layer table.
  Uses FACTS (not METRICS) since the OBT is already at 1-day grain.
#}

TABLES(
  customer_stats_1d AS {{ ref('obt__customer_stats_1d') }}
    COMMENT = 'Daily customer statistics at customer_segment + region grain. Each row represents one day of customer activity for a specific segment in a specific region.'
)

FACTS(
  customer_stats_1d.total_spend AS total_spend
    WITH SYNONYMS ('customer spend', 'revenue by segment')
    COMMENT = 'Total customer spend in USD. CUMULATIVE METRIC: SUM() across dimensions and time.',

  customer_stats_1d.order_count AS order_count
    WITH SYNONYMS ('number of orders', 'transactions')
    COMMENT = 'Count of orders placed. CUMULATIVE METRIC: SUM() across dimensions and time.',

  customer_stats_1d.new_customers AS new_customers
    WITH SYNONYMS ('customer acquisition', 'new signups')
    COMMENT = 'Count of new customers acquired. CUMULATIVE METRIC: SUM() across dimensions and time.',

  customer_stats_1d.returning_customers AS returning_customers
    WITH SYNONYMS ('repeat customers', 'retained customers')
    COMMENT = 'Count of returning customers who placed orders. CUMULATIVE METRIC: SUM() across dimensions and time.',

  customer_stats_1d.churn_count AS churn_count
    WITH SYNONYMS ('lost customers', 'customer attrition')
    COMMENT = 'Count of churned customers. CUMULATIVE METRIC: SUM() across dimensions and time.',

  customer_stats_1d.total_active_customers AS total_active_customers
    WITH SYNONYMS ('active users', 'active customer base')
    COMMENT = 'Total active customers (new + returning). CUMULATIVE METRIC: SUM() across dimensions and time.'
)

DIMENSIONS(
  customer_stats_1d.stats_date AS stats_date
    COMMENT = 'Calendar date for customer statistics. Query MAX(stats_date) to find latest available data.',

  customer_stats_1d.customer_segment AS customer_segment
    COMMENT = 'Customer segment classification. Values: Enterprise, Mid-Market, Small Business.',

  customer_stats_1d.region AS region
    COMMENT = 'Geographic region. Values: Northeast, Southeast, Midwest, West.'
)

COMMENT = 'Semantic view for daily customer statistics by segment and region'
;
