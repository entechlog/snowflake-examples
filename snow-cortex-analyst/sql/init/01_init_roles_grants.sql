-- =============================================================================
-- Roles and Grants for Cortex Analyst Demo
--
-- Replace variables before running:
--   ${ENV_CODE}     : dev, stg, prd
--   ${PROJECT_CODE} : entechlog (or your project code)
-- =============================================================================

USE ROLE SECURITYADMIN;

-- ---------------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------------

-- Service role for dbt (creates objects)
CREATE ROLE IF NOT EXISTS ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE
  COMMENT = 'dbt service role for ${PROJECT_CODE} (${ENV_CODE})';

-- End-user role for Cortex Analyst consumers
CREATE ROLE IF NOT EXISTS ${PROJECT_CODE}_CORTEX_USER_ROLE
  COMMENT = 'Cortex Analyst consumer role for ${PROJECT_CODE} (${ENV_CODE})';

-- Role hierarchy: both inherit from SYSADMIN
GRANT ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE TO ROLE SYSADMIN;
GRANT ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE TO ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- Grants: dbt service role
-- ---------------------------------------------------------------------------
GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJECT_CODE}_RAW_DB
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJECT_CODE}_DW_DB
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT USAGE, CREATE TABLE
  ON SCHEMA ${ENV_CODE}_${PROJECT_CODE}_RAW_DB.SEED
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT USAGE, CREATE TABLE, CREATE VIEW
  ON SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.OBT
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SEMANTIC VIEW
  ON SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT USAGE ON WAREHOUSE ${ENV_CODE}_${PROJECT_CODE}_DBT_WH_XS
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

-- Agent creation privilege (required for dbt run-operation create_cortex_agents)
GRANT CREATE AGENT ON SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

-- Future grants so new tables/views are accessible
GRANT SELECT ON FUTURE TABLES IN SCHEMA ${ENV_CODE}_${PROJECT_CODE}_RAW_DB.SEED
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.OBT
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

GRANT SELECT ON FUTURE TABLES IN SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.OBT
  TO ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE;

-- ---------------------------------------------------------------------------
-- Grants: AI user role (read-only + agent usage)
-- ---------------------------------------------------------------------------
GRANT USAGE ON DATABASE ${ENV_CODE}_${PROJECT_CODE}_DW_DB
  TO ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE;

GRANT USAGE ON SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC
  TO ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE;

GRANT SELECT ON FUTURE SEMANTIC VIEWS IN SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC
  TO ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE;

GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA ${ENV_CODE}_${PROJECT_CODE}_DW_DB.SEMANTIC
  TO ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE;

GRANT USAGE ON WAREHOUSE ${ENV_CODE}_${PROJECT_CODE}_CORTEX_WH_XS
  TO ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE;

-- Note: USAGE ON AGENT is granted by the dbt macro (create_cortex_agents)
-- after the agent is created. No manual grant needed here.

-- ---------------------------------------------------------------------------
-- Grant dbt role to your user (adjust as needed)
-- ---------------------------------------------------------------------------
-- GRANT ROLE ${ENV_CODE}_SVC_${PROJECT_CODE}_SNOW_DBT_ROLE TO USER <your_user>;
-- GRANT ROLE ${PROJECT_CODE}_CORTEX_USER_ROLE TO USER <your_user>;
