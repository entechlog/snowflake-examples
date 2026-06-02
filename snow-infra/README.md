# Snowflake Account Infrastructure

Reference setups for managing Snowflake account-level objects (databases, schemas, tables, warehouses, roles, grants) as code. Two equivalent approaches are provided side-by-side so teams can compare and choose:

| Approach | Folder | When to pick it |
|---|---|---|
| **DCM Projects** (recommended) | [`dcm/`](dcm/) | Net-new infra; Snowflake-native; declarative SQL with Jinja templating; state lives in Snowflake |
| **Terraform** (incumbent) | [`terraform/`](terraform/) | Existing TF-based shops; multi-cloud orgs; mature provider ecosystem |

Both cover the same scope: a full `source → prep → dw` chain (`RAW_DB`, `PREP_DB`, `DW_DB`), warehouses, service roles, user roles, and the complete grants matrix — with multi-env support (DEV / STG / PRD) and CI/CD.

## Common conventions

| Object | Pattern | TF example (`ENTECHLOG`) | DCM example (`SALES`) |
|---|---|---|---|
| Project code | `PROJ_CODE` env var | `entechlog` | `SALES` |
| User role | `{PROJ}_{ROLE}_ROLE` (no env — single SF account) | `ENTECHLOG_DE_ROLE` | `SALES_DE_ROLE` |
| Service role | `{ENV}_SVC_{PROJ}_SNOW_{TOOL}_ROLE` (per env) | `DEV_SVC_ENTECHLOG_SNOW_DBT_ROLE` | `DEV_SVC_SALES_SNOW_DBT_ROLE` |
| Database | `{ENV}_{PROJ}_{LAYER}_DB` | `DEV_ENTECHLOG_DW_DB` | `DEV_SALES_DW_DB` |
| Warehouse | `{ENV}_{PROJ}_{TOOL}_WH_{SIZE}` | `DEV_ENTECHLOG_DBT_WH_XS` | `DEV_SALES_DBT_WH_XS` |
| DBT layer chain | `RAW` (source) → `PREP` (staging) → `DW` (dim/fact/obt/semantic) | — | — |

The two demos use different `PROJ_CODE` values so they coexist in the same Snowflake account without OWNERSHIP conflicts. Swap `proj_code` in `dcm/dcm/manifest.yml` to migrate to your real domain code.

## Terraform setup

See [`terraform/`](terraform/). Quickstart:

```bash
cd terraform
terraform login
terraform workspace new snowflake-dev
terraform init
terraform plan
terraform apply
```

Workspaces map to envs: `snowflake-dev`, `snowflake-stg`, `snowflake-prd`.

## DCM Projects setup

See [`dcm/`](dcm/). Quickstart:

```bash
cd dcm
# 1. Bootstrap (once, as ACCOUNTADMIN)
snow sql -f bootstrap/01_create_dcm_service_role.sql
snow sql -f bootstrap/02_create_dcm_project_objects.sql   # repeat per env

# 2. Plan + deploy
./scripts/01_plan.sh DCM_DEV
./scripts/02_deploy.sh DCM_DEV "initial deploy"
```

## References

- [Snowflake DCM Projects overview](https://docs.snowflake.com/en/user-guide/dcm-projects/dcm-projects-overview)
- [Snowflake object naming conventions](https://www.entechlog.com/blog/data/snowflake-object-naming-conventions/)
- [Snowflake access control privileges](https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html)
