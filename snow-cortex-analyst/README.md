# Snow Cortex Analyst

Two end-to-end approaches for building Snowflake Cortex Analyst agents with semantic views — from seed data to production deployment.

**The key takeaway: clean models with precise descriptions, correct metric classifications, and verified queries produce accurate agents. Invest in your semantic layer.**

## Approaches

| | dbt (`dbt/`) | Cortex Code (`coco/`) |
|---|---|---|
| **Semantic views** | DDL (SQL) via `dbt_semantic_view` package | YAML via `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML` |
| **Agents** | Custom `cortex_agent` materialization | `CREATE AGENT` from YAML via `deploy.py` |
| **Verified queries** | `meta` in .yml + `run-operation` | Native in YAML spec |
| **Idempotency** | `ALTER AGENT` when spec unchanged | `ALTER AGENT` when spec unchanged |
| **Bidirectional sync** | No (code is truth) | Yes (`--pull` exports UI edits to YAML) |
| **Development** | Edit SQL + macros | Cortex Code CLI generates YAML interactively |
| **CI/CD** | `dbt run` | `python deploy.py` |
| **Dataset** | Sales (orders + customers) | Marketing (campaigns) |
| **Best for** | Teams already using dbt | Teams preferring YAML-first tooling |

Both share the same seed data and OBT layer (created by `dbt/`).

## Prerequisites

- Snowflake Enterprise edition (required for Cortex Analyst agents)
- dbt-core with dbt-snowflake adapter ([snow-tools](../snow-tools) container)
- Snowflake objects via `sql/init/` scripts or [snow-infra](../snow-infra) Terraform

## Quick Start

### 1. Create Snowflake objects

```sql
-- Run in Snowsight (variables are now set at the top of each file)
-- Modify ENV_CODE and PROJ_CODE values in the SET statements if needed
-- sql/init/00_init_database.sql
-- sql/init/01_init_roles_grants.sql
```

Or use the [snow-infra](../snow-infra) Terraform setup.

### 2. Set environment

```bash
export ENV_CODE=dev
export PROJ_CODE=entechlog
export SNOWFLAKE_ACCOUNT=<your_account>
export SNOWFLAKE_USER=<your_user>
export SNOWFLAKE_PASSWORD=<your_password>
export SNOWFLAKE_ROLE=DEV_SVC_ENTECHLOG_SNOW_DBT_ROLE
export SNOWFLAKE_WAREHOUSE=DEV_ENTECHLOG_DBT_WH_XS
```

### 3. Seed data + OBT layer

```bash
cd dbt
dbt deps && dbt seed && dbt run
```

### 4. Choose your approach

**dbt approach** — deploys sales semantic views + sales agent:
```bash
# Already done in step 3 — dbt run creates OBT + semantic views + agent
dbt run-operation deploy_verified_queries
```
See [dbt/ details](#dbt-approach) below.

**CoCo approach** — deploys marketing semantic view + marketing agent:
```bash
cd ../coco/scripts
./deploy.sh
```
See [coco/ details](coco/README.md).

## dbt Approach

### Agents as dbt models

Agents use the custom `cortex_agent` materialization — one file per agent in `models/agents/`:

```sql
{{ config(
    materialized = 'cortex_agent',
    instructions = 'sales_agent',
    semantic_views = ['order_stats_1d', 'customer_stats_1d'],
    warehouse = 'CORTEX_WH_XS',
    grant_to_roles = ['ENTECHLOG_CORTEX_ROLE'],
) }}
```

- **Idempotent:** Compares spec via `DESCRIBE AGENT` — only `ALTER AGENT` when changed, preserving chat history
- **Selective:** `dbt run --select sales_agent`
- **Instructions:** Structured macros in `macros/cortex/instructions/`

### Verified queries

Defined in semantic view `.yml` files under `meta.verified_queries`:

```yaml
meta:
  verified_queries:
    - name: revenue_by_category
      question: "What is the total revenue by product category?"
      sql: "SELECT ... FROM __order_stats_1d ..."
      use_as_onboarding_question: true
```

### Utility operations

```bash
dbt run-operation list_cortex_agents
dbt run-operation drop_cortex_agent --args '{name: dev_sales_agent}'
dbt run-operation drop_semantic_view --args '{name: [order_stats_1d, customer_stats_1d]}'
dbt run-operation deploy_verified_queries
dbt run-operation deploy_verified_queries --args '{name: order_stats_1d}'
```

## Multi-Environment

| Environment | Database | dbt Agent | CoCo Agent | Warehouse |
|---|---|---|---|---|
| dev | `DEV_ENTECHLOG_DW_DB` | `dev_sales_agent` | `marketing_agent` | `DEV_ENTECHLOG_CORTEX_WH_XS` |
| stg | `STG_ENTECHLOG_DW_DB` | `stg_sales_agent` | `marketing_agent` | `STG_ENTECHLOG_CORTEX_WH_XS` |
| prd | `PRD_ENTECHLOG_DW_DB` | `prd_sales_agent` | `marketing_agent` | `PRD_ENTECHLOG_CORTEX_WH_XS` |

CoCo agents don't include env prefix — the database provides isolation. Display name shows `(DEV)` / `(PRD)`.

## CI/CD

| Approach | Workflow | Trigger |
|---|---|---|
| dbt | `.github/workflows/dbt-semantic.yml` | Push to `develop` (dev) or `main` (prd) on `dbt/**` |
| CoCo | `.github/workflows/coco-semantic.yml` | Push to `develop` (dev) or `main` (prd) on `coco/**` |

Both support `workflow_dispatch` for manual runs. ADO migration notes in each workflow's header comments.

## Cleanup

```sql
-- Run sql/init/99_cleanup.sql in Snowsight
-- Replace ${ENV_CODE}=DEV and ${PROJ_CODE}=ENTECHLOG
```
