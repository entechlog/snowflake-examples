# Snow Cortex Analyst

End-to-end demo for building **Snowflake Cortex Analyst agents** with semantic views — from seed data to production deployment using dbt.

> A second approach using Cortex Code CLI will be added in a future branch.

## Architecture

```
RAW_DB.SEED (tables)  →  DW_DB.OBT (views)  →  DW_DB.SEMANTIC (semantic views)  →  Agent
     dbt seed              dbt run                dbt run                     dbt run-operation
```

**Key patterns:**
- DDL-based semantic views via [dbt_semantic_view](https://github.com/Snowflake-Labs/dbt_semantic_view) package
- `CREATE OR REPLACE` for idempotent deployment
- Rich `COMMENT` metadata on FACTS/DIMENSIONS guides the agent on correct aggregation
- Single agent spanning two semantic views (multi-tool agent)
- Semantic views use `ref()` for OBT dependency (correct DAG ordering)

## Prerequisites

- **Snowflake Enterprise edition** (required for Cortex Analyst agents)
- **dbt-core** with **dbt-snowflake** adapter (available in [snow-tools](../snow-tools) container)
- Snowflake objects created via `sql/init/` SQL scripts or [snow-infra](../snow-infra) Terraform

## Quick Start

### 1. Create Snowflake objects

Using init SQL (for those without Terraform):
```sql
-- Run in Snowsight, replacing ${ENV_CODE}=DEV and ${PROJECT_CODE}=ENTECHLOG
-- sql/init/00_init_database.sql
-- sql/init/01_init_roles_grants.sql
```

Or use the [snow-infra](../snow-infra) Terraform setup (recommended).

### 2. Set environment variables

```bash
export ENV_CODE=dev
export PROJECT_CODE=entechlog
export SNOWFLAKE_ACCOUNT=<your_account>
export SNOWFLAKE_USER=<your_user>
export SNOWFLAKE_PASSWORD=<your_password>
export SNOWFLAKE_ROLE=DEV_SVC_ENTECHLOG_SNOW_DBT_ROLE
export SNOWFLAKE_WAREHOUSE=DEV_ENTECHLOG_DBT_WH_XS
```

### 3. Install dependencies, seed data, and deploy

```bash
cd dbt
dbt deps
dbt seed
dbt run
dbt run-operation create_cortex_agents
```

### 4. Test the agent

Open Snowflake UI → Cortex Analyst → Select "Sales Agent (DEV)" → Ask:
- "What was the total revenue by product category last month?"
- "Which region has the highest average order value?"
- "Compare Enterprise vs Small Business customer spend by region"

## Dataset

Two OBT tables seeded via `dbt seed` into `RAW_DB.SEED`:

**order_stats_1d** (1,440 rows) — Daily order metrics
- Grain: `order_date` + `product_category` + `region`
- Facts: revenue, quantity, discount_amount, order_count, refund_amount, net_revenue
- 90 days (Oct-Dec 2025), 4 categories, 4 regions

**customer_stats_1d** (1,080 rows) — Daily customer metrics
- Grain: `stats_date` + `customer_segment` + `region`
- Facts: total_spend, order_count, new_customers, returning_customers, churn_count, total_active_customers
- 90 days (Oct-Dec 2025), 3 segments, 4 regions

## Multi-Environment

Uses `ENV_CODE` + `PROJECT_CODE` for environment-aware naming:

| Environment | Database | Agent | Warehouse |
|---|---|---|---|
| dev | `DEV_ENTECHLOG_DW_DB` | `dev_sales_agent` | `DEV_ENTECHLOG_CORTEX_WH_XS` |
| stg | `STG_ENTECHLOG_DW_DB` | `stg_sales_agent` | `STG_ENTECHLOG_CORTEX_WH_XS` |
| prd | `PRD_ENTECHLOG_DW_DB` | `prd_sales_agent` | `PRD_ENTECHLOG_CORTEX_WH_XS` |

## CI/CD

GitHub Actions workflow in `.github/workflows/dbt-semantic.yml`.

Triggers on push to `develop` (→ dev) and `main` (→ prd).

**ADO migration:** See comments in the workflow file for Azure DevOps equivalents.

## Agent Configuration

Agents are defined declaratively in `dbt_project.yml` under `vars.cortex_agents`:

| Parameter | Description | Default |
|---|---|---|
| `name` | Agent name (supports Jinja) | required |
| `semantic_views` | List of semantic view names | required |
| `instructions` | Instruction macro name | none |
| `warehouse` | Execution warehouse | `agent_warehouse_default` |
| `grant_to_roles` | Roles to grant USAGE | `[]` |
| `timeout_seconds` | Orchestration timeout | `60` |
| `token_limit` | Max response tokens | `16000` |
| `enabled` | Create this agent? | `true` |

## Cleanup

```sql
-- Run sql/init/99_cleanup.sql in Snowsight
-- Replace ${ENV_CODE}=DEV and ${PROJECT_CODE}=ENTECHLOG
```
