# Cortex Code (CoCo) - Semantic Views + Agents

An alternative approach to building Snowflake Cortex Analyst agents using **Cortex Code CLI** and **YAML specifications** instead of dbt.

## What This Demo Teaches

This is not just a demo to copy-paste. The goal is to show **how to think about building semantic layers** so you can apply it to your own data:

1. **Clean models produce accurate agents.** A semantic view with precise descriptions, correct metric classifications, and verified queries will answer questions correctly. Vague descriptions lead to hallucinated answers.

2. **Rate metrics must be computed, not stored.** Never store averages or rates in your OBT. Store the additive components (revenue, order_count) and define metrics that compute the ratio. This prevents the agent from incorrectly summing averages.

3. **Verified queries are your test suite.** They teach the agent the correct SQL patterns for common questions. Without them, the agent guesses. With them, it learns.

4. **Synonyms bridge business and technical language.** Users say "sales", your column is "revenue". Synonyms make this mapping explicit.

5. **Skills inject domain knowledge into the CLI.** The `.cortex/skills/` file teaches Cortex Code your data conventions so it generates correct YAML the first time.

## Architecture

```
semantic_views/*.yaml  →  deploy.py  →  SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML
agents/*.yaml          →  deploy.py  →  CREATE / ALTER AGENT (idempotent)
Snowflake UI edits     →  deploy.py --pull  →  YAML files (normalized)
```

YAML files are the **single source of truth**. The deploy script handles the full lifecycle: deploy, pull, dry-run, and status checks. No hardcoded SQL.

**Assumes OBT tables pre-exist** (created by the `dbt/` project via `dbt seed && dbt run`).

## Prerequisites

- Snowflake Enterprise edition
- OBT tables populated (`dbt/` project)
- Python 3.8+ with `pyyaml` and `snowflake-connector-python`
- Cortex Code CLI (for interactive YAML generation)

## Quick Start

### Option A: Interactive (Cortex Code CLI)

```bash
# Install Cortex Code CLI
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh

# Launch with your connection
cortex -c <your_connection>

# Generate semantic view interactively
> Write a Semantic View named order_stats_1d for Cortex Analyst
  based on DEV_ENTECHLOG_DW_DB.OBT.ORDER_STATS_1D.
  Use the semantic-view optimization skill.

# Or use batch prompts
cortex -f prompts/01_create_semantic_view.txt
cortex -f prompts/02_create_agent.txt
cortex -f prompts/03_validate.txt
```

### Option B: Scripted (CI/CD)

```bash
export ENV_CODE=dev
export PROJ_CODE=entechlog
export SNOWFLAKE_ACCOUNT=<your_account>
export SNOWFLAKE_USER=<your_user>
export SNOWFLAKE_PASSWORD=<your_password>

cd coco/scripts

# Deploy all semantic views and agents
./deploy.sh

# Deploy specific objects
./deploy.sh --views marketing_campaign_stats_1d
./deploy.sh --agents marketing_agent
./deploy.sh --views view1 view2 --agents agent1 agent2
```

## Deploy Script Reference

`deploy.py` supports four modes, all with optional `--views` and `--agents` filters:

### Deploy (default)

Deploys semantic views first (two-phase: views before agents, since agents reference views).

```bash
python deploy.py                                    # Deploy all
python deploy.py --views marketing_campaign_stats_1d # Deploy one view
python deploy.py --agents marketing_agent            # Deploy one agent
python deploy.py --schema ANALYTICS                  # Target a different schema
```

### Dry-run

Generates and prints the SQL that would be executed, without connecting to Snowflake. Use in CI/CD pipelines to review generated SQL in pull requests.

```bash
python deploy.py --dry-run
python deploy.py --dry-run --agents marketing_agent
```

### Pull

Exports deployed Snowflake definitions back to local YAML files. Enables **bidirectional sync** - edit in Snowflake UI, then pull changes back to Git.

```bash
python deploy.py --pull                              # Pull all views and agents
python deploy.py --pull --views marketing_campaign_stats_1d  # Pull one view
python deploy.py --pull --agents marketing_agent     # Pull one agent
```

Pulled YAML is **normalized** to match hand-written conventions:
- Names lowercased (`MARKETING_CAMPAIGN_STATS_1D` → `marketing_campaign_stats_1d`)
- Data types simplified (`VARCHAR(16777216)` → `VARCHAR`, `NUMBER(38,0)` → `NUMBER`)
- Default `access_modifier: public_access` stripped
- Section order preserved (`time_dimensions`, `dimensions`, `facts`, `metrics`)
- Agent instructions use block style (`|`) instead of inline `\n` escapes
- Environment values re-parameterized (`DEV` → `${ENV_CODE}`, `ENTECHLOG` → `${PROJ_CODE}`)

**Note:** Snowflake sorts columns alphabetically within sections. On first pull, column order may differ from your hand-written YAML. After that initial normalization, subsequent pulls are stable.

### Status

Compares local YAML files with deployed Snowflake objects. Shows what's synced, what's local-only, and what's deployed-only.

```bash
python deploy.py --status
```

Example output:

```
============================================================
  Status: DEV_ENTECHLOG_DW_DB.SEMANTIC
============================================================

  Semantic Views:
  Name                                     Status
  ---------------------------------------- --------------------
  CUSTOMER_STATS_1D                        DEPLOYED ONLY
  MARKETING_CAMPAIGN_STATS_1D              SYNCED
  ORDER_STATS_1D                           DEPLOYED ONLY

  Agents:
  Name                                     Status
  ---------------------------------------- --------------------
  DEV_SALES_AGENT                          DEPLOYED ONLY
  MARKETING_AGENT                          SYNCED
```

## Bidirectional Workflow

The key advantage of the YAML-first approach: definitions can be edited both locally and in the Snowflake UI, then synced.

```
  Local YAML                    Snowflake
  ──────────                    ─────────
  Edit YAML    ─── deploy ───►  Semantic View / Agent
               ◄── pull ─────  Edit in UI
               
  git diff → review → commit
```

**Typical workflow:**

1. Create or edit YAML locally
2. `python deploy.py --dry-run` - review generated SQL
3. `python deploy.py` - deploy to Snowflake
4. Test in Snowflake Intelligence
5. Someone tweaks a description in the Snowflake UI
6. `python deploy.py --pull --views changed_view` - export the change
7. `git diff` - review what changed
8. Commit to Git

## Applying This to Your Data

When building semantic views for your own models:

### Step 1: Understand your grain
Each semantic view should map 1:1 to a well-defined OBT or fact table. Know what one row represents.

### Step 2: Classify every column
- **time_dimensions** - Date/timestamp columns (get special temporal handling)
- **dimensions** - Categorical attributes (set `is_enum: true` when values are known)
- **facts** - Additive measures that can be SUMmed
- **metrics** - Computed from facts (ratios, averages, rates)

### Step 3: Write descriptions as if explaining to a new analyst
Bad: `"Revenue amount"`
Good: `"Gross revenue in USD. CUMULATIVE: SUM() across dimensions and time."`

### Step 4: Add verified queries
Write 3-5 SQL queries that answer your most common business questions. These are your "unit tests" for the semantic view. Use `__table_name` prefix for logical table references.

### Step 5: Test with real questions
Ask the agent questions you know the answer to. If it gets them wrong, improve descriptions, add synonyms, or add more verified queries.

## Comparison: dbt vs Cortex Code CLI

| Aspect | dbt (`dbt/`) | CoCo (`coco/`) |
|---|---|---|
| **Semantic view format** | DDL (SQL) | YAML |
| **Verified queries** | meta in .yml + run-operation | Native in YAML spec |
| **Agent creation** | Custom materialization | `CREATE AGENT` via deploy script |
| **Development** | Edit SQL + macros | Cortex Code CLI generates YAML interactively |
| **Idempotency** | ALTER AGENT when spec unchanged | ALTER AGENT when spec unchanged |
| **Bidirectional sync** | No (code is truth) | Yes (`--pull` exports UI edits to YAML) |
| **CI/CD** | `dbt run` | `python deploy.py` |
| **Dataset** | Sales (orders + customers) | Marketing (campaigns) |
| **Agent** | `sales_agent` | `marketing_agent` |
| **Best for** | Teams already using dbt | Teams preferring YAML-first, Snowflake-native tooling |

## Multi-Environment

Environment variables handle promotion across environments:

| Variable | Dev | Production |
|---|---|---|
| `ENV_CODE` | dev | prd |
| `PROJ_CODE` | entechlog | entechlog |
| `DATABASE` | `DEV_ENTECHLOG_DW_DB` | `PRD_ENTECHLOG_DW_DB` |
| Agent | `marketing_agent` | `marketing_agent` |
| Display Name | Marketing Agent (DEV) | Marketing Agent (PRD) |

Agent names don't include env prefix - the database provides isolation. Display name shows `(DEV)` / `(PRD)` for clarity in Snowflake Intelligence.

## Cortex Code Skills

The `.cortex/skills/semantic-view-guide.md` file teaches Cortex Code CLI about your data model and conventions. When you run the CLI from this directory, it automatically loads this skill, so prompts like "create a semantic view for marketing_campaign_stats_1d" produce YAML that follows your standards.

Adapt this file for your own data - document your grain, your metrics, your naming conventions.
