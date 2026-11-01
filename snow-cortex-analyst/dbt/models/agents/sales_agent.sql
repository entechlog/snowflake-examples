-- depends_on: {{ ref('semantic__order_stats_1d') }}
-- depends_on: {{ ref('semantic__customer_stats_1d') }}

{{
  config(
    materialized = 'cortex_agent',
    alias = env_var('ENV_CODE', 'dev') | trim | lower ~ '_sales_agent',
    display_name = 'Sales Agent (' ~ env_var('ENV_CODE', 'dev') | trim | upper ~ ')',
    description = 'Sales analytics agent with order and customer insights',
    instructions = 'sales_agent',
    semantic_views = ['order_stats_1d', 'customer_stats_1d'],
    warehouse = 'CORTEX_WH_XS',
    grant_to_roles = [env_var('PROJ_CODE', 'entechlog') | trim | upper ~ '_CORTEX_ROLE'],
    timeout_seconds = 60,
    token_limit = 16000,
    query_timeout_seconds = 60
  )
}}
