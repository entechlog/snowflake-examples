-- =============================================================================
-- Snowflake Object Setup for Cortex Analyst Demo
-- Run this if you are NOT using the Terraform setup from snow-infra
--
-- Replace variables before running:
--   ${ENV_CODE}     : dev, stg, prd
--   ${PROJ_CODE} : entechlog (or your project code)
--
-- Example: DEV_ENTECHLOG_DW_DB
-- =============================================================================

USE ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- Databases
-- ---------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_RAW_DB
  COMMENT = 'Raw data for ${PROJ_CODE} (${ENV_CODE})';

CREATE DATABASE IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_DW_DB
  COMMENT = 'Data warehouse for ${PROJ_CODE} (${ENV_CODE})';

-- ---------------------------------------------------------------------------
-- Schemas
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_RAW_DB.SEED
  COMMENT = 'Seed data loaded by dbt';

CREATE SCHEMA IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  COMMENT = 'One Big Table layer - pre-aggregated views';

CREATE SCHEMA IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_DW_DB.SEMANTIC
  COMMENT = 'Semantic views for Cortex Analyst';

-- ---------------------------------------------------------------------------
-- Warehouses
-- ---------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_DBT_WH_XS
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'dbt execution warehouse (${ENV_CODE})';

CREATE WAREHOUSE IF NOT EXISTS ${ENV_CODE}_${PROJ_CODE}_CORTEX_WH_XS
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Cortex Analyst agent warehouse (${ENV_CODE})';
