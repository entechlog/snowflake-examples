# Snow Cortex Analyst

Snowflake Cortex Analyst agents with semantic views — seed data to production using dbt.

> Cortex Code CLI approach will be added in a future branch.

## Architecture

```
RAW_DB.SEED (tables)  →  DW_DB.OBT (views)  →  DW_DB.SEMANTIC (semantic views + agents)
     dbt seed              dbt run                dbt run
```

## Prerequisites

- Snowflake Enterprise edition (required for Cortex Analyst agents)
- dbt-core with dbt-snowflake adapter ([snow-tools](../snow-tools) container)
- Snowflake objects via `sql/init/` scripts or [snow-infra](../snow-infra) Terraform

## Quick Start

```bash
# Set environment
export ENV_CODE=dev
export PROJ_CODE=entechlog
export SNOWFLAKE_ACCOUNT=<your_account>
export SNOWFLAKE_USER=<your_user>
export SNOWFLAKE_PASSWORD=<your_password>
export SNOWFLAKE_ROLE=DEV_SVC_ENTECHLOG_SNOW_DBT_ROLE
export SNOWFLAKE_WAREHOUSE=DEV_ENTECHLOG_DBT_WH_XS

# Deploy
cd dbt
dbt deps
dbt seed
dbt run

# Deploy verified queries (optional, after semantic views exist)
dbt run-operation deploy_verified_queries
dbt run-operation deploy_verified_queries --args '{name: order_stats_1d}'
```

## Multi-Environment

| Environment | Database | Agent | Warehouse |
|---|---|---|---|
| dev | `DEV_ENTECHLOG_DW_DB` | `dev_sales_agent` | `DEV_ENTECHLOG_CORTEX_WH_XS` |
| stg | `STG_ENTECHLOG_DW_DB` | `stg_sales_agent` | `STG_ENTECHLOG_CORTEX_WH_XS` |
| prd | `PRD_ENTECHLOG_DW_DB` | `prd_sales_agent` | `PRD_ENTECHLOG_CORTEX_WH_XS` |

## Agents

Agents are dbt models using the `cortex_agent` materialization (`models/agents/`):

```sql
-- models/agents/sales_agent.sql
{{ config(
    materialized = 'cortex_agent',
    instructions = 'sales_agent',
    semantic_views = ['order_stats_1d', 'customer_stats_1d'],
    warehouse = 'CORTEX_WH_XS',
    grant_to_roles = ['ENTECHLOG_CORTEX_ROLE'],
) }}
```

- **Idempotent:** Compares current spec via `DESCRIBE AGENT` — only `ALTER AGENT` when changed, preserving chat history
- **Selective:** `dbt run --select sales_agent`
- **Instructions:** Structured macros in `macros/cortex/instructions/` (`{name}_orchestration`, `{name}_response`, `{name}_sample_questions`)

## Verified Queries

Defined in semantic view `.yml` files under `meta.verified_queries`:

```yaml
meta:
  verified_queries:
    - name: revenue_by_category
      question: "What is the total revenue by product category?"
      sql: "SELECT ... FROM __order_stats_1d ..."
      use_as_onboarding_question: true
```

Deploy via `dbt run-operation deploy_verified_queries`.

## Utility Operations

```bash
# List agents
dbt run-operation list_cortex_agents

# Drop agent (single or list)
dbt run-operation drop_cortex_agent --args '{name: dev_sales_agent}'
dbt run-operation drop_cortex_agent --args '{name: [dev_sales_agent, dev_support_agent]}'

# Drop semantic view (single or list)
dbt run-operation drop_semantic_view --args '{name: order_stats_1d}'
dbt run-operation drop_semantic_view --args '{name: [order_stats_1d, customer_stats_1d]}'

# Deploy verified queries (all, single, or list)
dbt run-operation deploy_verified_queries
dbt run-operation deploy_verified_queries --args '{name: order_stats_1d}'
dbt run-operation deploy_verified_queries --args '{name: [order_stats_1d, customer_stats_1d]}'
```

## CI/CD

GitHub Actions: `.github/workflows/dbt-semantic.yml` — triggers on push to `develop` (→ dev) and `main` (→ prd).

ADO migration notes in workflow comments.

## Cleanup

```sql
-- Run sql/init/99_cleanup.sql in Snowsight
-- Replace ${ENV_CODE}=DEV and ${PROJ_CODE}=ENTECHLOG
```
