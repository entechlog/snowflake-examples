{{
  config(
    alias = 'marketing_campaign_stats_1d',
    tags  = ['obt', 'marketing', 'daily']
  )
}}

SELECT
    campaign_date,
    channel,
    region,
    impressions,
    clicks,
    spend,
    conversions,
    conversion_revenue,
    conversion_revenue - spend AS net_campaign_value
FROM {{ source('seed', 'marketing_campaign_stats_1d') }}
