---
name: semantic-view-guide
description: Guidelines for creating semantic views and agents — adapt the Data Model section for your own tables
---

# Semantic View & Agent Development Guide

<!-- TEMPLATE: This file teaches Cortex Code CLI about YOUR data model.
     Keep the "Critical Rules" section as-is (universal best practices).
     Replace the "Data Model" section below with your own tables. -->

## Why This Matters

The accuracy of a Cortex Analyst agent is directly tied to the quality of the semantic view it reads. A clean model with precise descriptions, correct metric classifications, and verified queries will produce accurate answers. A sloppy model will hallucinate.

**The golden rule: garbage in, garbage out. Invest in your semantic layer.**

## Data Model

### marketing_campaign_stats_1d
- **Location:** `DW_DB.OBT.MARKETING_CAMPAIGN_STATS_1D`
- **Grain:** One row per `campaign_date` + `channel` + `region` per day
- **Dimensions:** campaign_date (DATE), channel (VARCHAR), region (VARCHAR)
- **Facts:** impressions, clicks, spend, conversions, conversion_revenue, net_campaign_value
- **Date range:** Oct 2025 - Dec 2025 (90 days)
- **Channels:** Email, Social Media, Paid Search, Display Ads
- **Regions:** Northeast, Southeast, Midwest, West

## Critical Rules for Semantic View Definitions

### 1. ALL facts are cumulative — SUM() is always valid
Every fact can be safely summed across any dimension or time range. There are no rate metrics stored.

### 2. Derived metrics must be computed, never stored
Marketing has many rate metrics. They must ALL be defined as `metrics` in the YAML, never as `facts`:
- CTR: `SUM(clicks) * 100.0 / NULLIF(SUM(impressions), 0)`
- CPC: `SUM(spend) / NULLIF(SUM(clicks), 0)`
- CVR: `SUM(conversions) * 100.0 / NULLIF(SUM(clicks), 0)`
- CPA: `SUM(spend) / NULLIF(SUM(conversions), 0)`
- ROAS: `SUM(conversion_revenue) / NULLIF(SUM(spend), 0)`

### 3. Description quality determines agent accuracy
Every column description should include:
- What the column measures in business terms
- How it should be aggregated (SUM for cumulative facts)
- For dimensions: list the actual values

### 4. Use synonyms generously
Marketing terms vary by team. Map them:
- spend → "ad spend", "campaign cost", "budget spent"
- conversions → "sales from ads", "campaign conversions"
- clicks → "ad clicks", "click-throughs"

### 5. Verified queries are your test suite
Include 3-5 verified queries that cover common marketing questions. Use `__table_name` prefix for logical table names.

## Environment Variables
- `ENV_CODE` — dev, stg, prd
- `PROJ_CODE` — entechlog
- Database: `{ENV_CODE}_{PROJ_CODE}_DW_DB`
- Warehouse: `{ENV_CODE}_{PROJ_CODE}_CORTEX_WH_XS`
