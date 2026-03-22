-- =============================================================================
-- Roles and Grants for Cortex Analyst Demo
--
-- Replace variables before running:
--   ${ENV_CODE}     : dev, stg, prd
--   ${PROJ_CODE} : entechlog (or your project code)
-- =============================================================================

USE ROLE SECURITYADMIN;

-- ---------------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------------

-- Service role for dbt (creates objects)
CREATE ROLE IF NOT EXISTS ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE
  COMMENT = 'dbt service role for ${PROJ_CODE} (${ENV_CODE})';

-- End-user role for Cortex Analyst consumers
CREATE ROLE IF NOT EXISTS ${PROJ_CODE}_CORTEX_ROLE
  COMMENT = 'Cortex Analyst consumer role for ${PROJ_CODE} (${ENV_CODE})';

-- Role hierarchy: both inherit from SYSADMIN
GRANT ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE TO ROLE SYSADMIN;
GRANT ROLE ${PROJ_CODE}_CORTEX_ROLE TO ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- Grants: dbt service role
-- ---------------------------------------------------------------------------
GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJ_CODE}_RAW_DB
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJ_CODE}_DW_DB
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT USAGE, CREATE TABLE
  ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_RAW_DB.SEED
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT USAGE, CREATE TABLE, CREATE VIEW
  ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SEMANTIC VIEW
  ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.SEMANTIC
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT USAGE ON WAREHOUSE ${ENV_CODE}_${PROJ_CODE}_DBT_WH_XS
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT USAGE ON WAREHOUSE ${ENV_CODE}_${PROJ_CODE}_CORTEX_WH_XS
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

-- Agent creation privilege (required for dbt run-operation create_cortex_agents)
GRANT CREATE AGENT ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.SEMANTIC
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

-- Future grants so new tables/views are accessible
GRANT SELECT ON FUTURE TABLES IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_RAW_DB.SEED
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

GRANT SELECT ON FUTURE TABLES IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  TO ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE;

-- ---------------------------------------------------------------------------
-- Grants: AI user role (read-only + agent usage)
-- ---------------------------------------------------------------------------
GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJ_CODE}_DW_DB
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT USAGE ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.SEMANTIC
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT SELECT ON FUTURE SEMANTIC VIEWS IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.SEMANTIC
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.SEMANTIC
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT USAGE ON WAREHOUSE ${ENV_CODE}_${PROJ_CODE}_CORTEX_WH_XS
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

-- OBT access (semantic views query OBT views underneath)
GRANT USAGE ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_DW_DB.OBT
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

-- Seed access (OBT views query seed tables underneath)
GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJ_CODE}_RAW_DB
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT USAGE ON SCHEMA ${ENV_CODE}_${PROJ_CODE}_RAW_DB.SEED
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_RAW_DB.SEED
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

GRANT SELECT ON FUTURE TABLES IN SCHEMA ${ENV_CODE}_${PROJ_CODE}_RAW_DB.SEED
  TO ROLE ${PROJ_CODE}_CORTEX_ROLE;

-- Note: USAGE ON AGENT is granted by the dbt macro (create_cortex_agents)
-- after the agent is created. No manual grant needed here.

-- ---------------------------------------------------------------------------
-- Grant dbt role to your user (adjust as needed)
-- ---------------------------------------------------------------------------
-- GRANT ROLE ${ENV_CODE}_SVC_${PROJ_CODE}_SNOW_DBT_ROLE TO USER <your_user>;
-- GRANT ROLE ${PROJ_CODE}_CORTEX_ROLE TO USER <your_user>;
