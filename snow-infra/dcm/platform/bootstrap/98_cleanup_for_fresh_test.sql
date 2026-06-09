-- =============================================================================
-- Cleanup before a fresh DCM demo deploy
-- =============================================================================
-- Run as ACCOUNTADMIN in Snowsight. Drops every object that previous demo runs
-- created so the next plan/deploy starts from a known empty state.
-- Keeps Phase 0 bootstrap intact: SVC_PLATFORM_DCM_USER, SVC_SALES_DCM_USER,
-- SVC_PLATFORM_DCM_WH_XS, and their registered RSA keys.
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------------------
-- Team data + DCM DBs (per env)
-- ---------------------------------------------------------------------------
DROP DATABASE IF EXISTS DEV_SALES_RAW_DB;
DROP DATABASE IF EXISTS DEV_SALES_PREP_DB;
DROP DATABASE IF EXISTS DEV_SALES_DW_DB;
DROP DATABASE IF EXISTS DEV_SALES_DCM_DB;
DROP DATABASE IF EXISTS STG_SALES_RAW_DB;
DROP DATABASE IF EXISTS STG_SALES_PREP_DB;
DROP DATABASE IF EXISTS STG_SALES_DW_DB;
DROP DATABASE IF EXISTS STG_SALES_DCM_DB;
DROP DATABASE IF EXISTS PRD_SALES_RAW_DB;
DROP DATABASE IF EXISTS PRD_SALES_PREP_DB;
DROP DATABASE IF EXISTS PRD_SALES_DW_DB;
DROP DATABASE IF EXISTS PRD_SALES_DCM_DB;

-- ---------------------------------------------------------------------------
-- Platform DCM DBs (per env)
-- ---------------------------------------------------------------------------
DROP DATABASE IF EXISTS DEV_PLATFORM_DCM_DB;
DROP DATABASE IF EXISTS STG_PLATFORM_DCM_DB;
DROP DATABASE IF EXISTS PRD_PLATFORM_DCM_DB;

-- ---------------------------------------------------------------------------
-- Team warehouses (per env: DBT + CORTEX) + shared ALL_QUERY WH
-- ---------------------------------------------------------------------------
DROP WAREHOUSE IF EXISTS DEV_SALES_DBT_WH_XS;
DROP WAREHOUSE IF EXISTS DEV_SALES_CORTEX_WH_XS;
DROP WAREHOUSE IF EXISTS STG_SALES_DBT_WH_XS;
DROP WAREHOUSE IF EXISTS STG_SALES_CORTEX_WH_XS;
DROP WAREHOUSE IF EXISTS PRD_SALES_DBT_WH_XS;
DROP WAREHOUSE IF EXISTS PRD_SALES_CORTEX_WH_XS;
DROP WAREHOUSE IF EXISTS ALL_SALES_QUERY_WH_XS;

USE ROLE SECURITYADMIN;

-- ---------------------------------------------------------------------------
-- Functional roles (no env)
-- ---------------------------------------------------------------------------
DROP ROLE IF EXISTS SALES_DE_FR;
DROP ROLE IF EXISTS SALES_DA_FR;
DROP ROLE IF EXISTS SALES_CORTEX_FR;
DROP ROLE IF EXISTS SALES_PIPE_ADMIN_FR;

-- ---------------------------------------------------------------------------
-- Service-FRs (per env)
-- ---------------------------------------------------------------------------
DROP ROLE IF EXISTS DEV_SALES_DBT_SVC_FR;
DROP ROLE IF EXISTS DEV_SALES_KAFKA_SVC_FR;
DROP ROLE IF EXISTS DEV_SALES_SUPERSET_SVC_FR;
DROP ROLE IF EXISTS STG_SALES_DBT_SVC_FR;
DROP ROLE IF EXISTS STG_SALES_KAFKA_SVC_FR;
DROP ROLE IF EXISTS STG_SALES_SUPERSET_SVC_FR;
DROP ROLE IF EXISTS PRD_SALES_DBT_SVC_FR;
DROP ROLE IF EXISTS PRD_SALES_KAFKA_SVC_FR;
DROP ROLE IF EXISTS PRD_SALES_SUPERSET_SVC_FR;

-- ---------------------------------------------------------------------------
-- Access Roles: RO + RW per data DB, per env (DCM_DB has no ARs)
-- ---------------------------------------------------------------------------
DROP ROLE IF EXISTS DEV_SALES_RAW_RO_AR;
DROP ROLE IF EXISTS DEV_SALES_RAW_RW_AR;
DROP ROLE IF EXISTS DEV_SALES_PREP_RO_AR;
DROP ROLE IF EXISTS DEV_SALES_PREP_RW_AR;
DROP ROLE IF EXISTS DEV_SALES_DW_RO_AR;
DROP ROLE IF EXISTS DEV_SALES_DW_RW_AR;
DROP ROLE IF EXISTS STG_SALES_RAW_RO_AR;
DROP ROLE IF EXISTS STG_SALES_RAW_RW_AR;
DROP ROLE IF EXISTS STG_SALES_PREP_RO_AR;
DROP ROLE IF EXISTS STG_SALES_PREP_RW_AR;
DROP ROLE IF EXISTS STG_SALES_DW_RO_AR;
DROP ROLE IF EXISTS STG_SALES_DW_RW_AR;
DROP ROLE IF EXISTS PRD_SALES_RAW_RO_AR;
DROP ROLE IF EXISTS PRD_SALES_RAW_RW_AR;
DROP ROLE IF EXISTS PRD_SALES_PREP_RO_AR;
DROP ROLE IF EXISTS PRD_SALES_PREP_RW_AR;
DROP ROLE IF EXISTS PRD_SALES_DW_RO_AR;
DROP ROLE IF EXISTS PRD_SALES_DW_RW_AR;

-- ---------------------------------------------------------------------------
-- Team DCM role (USER stays — its RSA key is registered and reused)
-- ---------------------------------------------------------------------------
DROP ROLE IF EXISTS SVC_SALES_DCM_ROLE;
