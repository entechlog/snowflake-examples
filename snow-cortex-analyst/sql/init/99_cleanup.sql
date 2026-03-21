-- =============================================================================
-- Cleanup: Remove all demo objects
--
-- Replace variables before running:
--   ${ENV_CODE}     : dev, stg, prd
--   ${PROJECT_CODE} : entechlog (or your project code)
-- =============================================================================

USE ROLE SYSADMIN;

-- Drop agents first (if they exist)
DROP CORTEX AGENT IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC.${ENV_CODE}_sales_agent;

-- Drop semantic views
DROP SEMANTIC VIEW IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC.order_stats_1d;
DROP SEMANTIC VIEW IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC.customer_stats_1d;

-- Drop OBT views
DROP VIEW IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.OBT.order_stats_1d;
DROP VIEW IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.OBT.customer_stats_1d;

-- Drop seed tables
DROP TABLE IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_RAW_DB.SEED.order_stats_1d;
DROP TABLE IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_RAW_DB.SEED.customer_stats_1d;

-- Drop schemas
DROP SCHEMA IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC;
DROP SCHEMA IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB.OBT;
DROP SCHEMA IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_RAW_DB.SEED;

-- Drop warehouses
DROP WAREHOUSE IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_CORTEX_WH_XS;
DROP WAREHOUSE IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DBT_WH_XS;

-- Drop database
DROP DATABASE IF EXISTS ${ENV_CODE}_${PROJECT_CODE}_DW_DB;

-- Drop roles
USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS ${PROJECT_CODE}_CORTEX_USER_ROLE;
DROP ROLE IF EXISTS ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;
