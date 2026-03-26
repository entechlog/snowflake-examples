-- =============================================================================
-- Roles and Grants for Cortex Analyst Demo
-- =============================================================================

-- Set variables at the beginning of the script
-- Modify these values as needed for your environment
SET ENV_CODE = 'DEV';        -- Options: DEV, STG, PRD
SET PROJ_CODE = 'ENTECHLOG'; -- Your project code

-- Construct database, warehouse, and role names using the variables
SET RAW_DB_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_RAW_DB';
SET DW_DB_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_DW_DB';
SET DBT_WH_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_DBT_WH_XS';
SET CORTEX_WH_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_CORTEX_WH_XS';
SET DBT_ROLE_NAME = $ENV_CODE || '_SVC_' || $PROJ_CODE || '_SNOW_DBT_ROLE';
SET CORTEX_ROLE_NAME = $PROJ_CODE || '_CORTEX_ROLE';

USE ROLE SECURITYADMIN;

-- ---------------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------------

-- Service role for dbt (creates objects)
CREATE ROLE IF NOT EXISTS IDENTIFIER($DBT_ROLE_NAME)
  COMMENT = 'dbt service role for ' || $PROJ_CODE || ' (' || $ENV_CODE || ')';

-- End-user role for Cortex Analyst consumers
CREATE ROLE IF NOT EXISTS IDENTIFIER($CORTEX_ROLE_NAME)
  COMMENT = 'Cortex Analyst consumer role for ' || $PROJ_CODE || ' (' || $ENV_CODE || ')';

-- Role hierarchy: both inherit from SYSADMIN
GRANT ROLE IDENTIFIER($DBT_ROLE_NAME) TO ROLE SYSADMIN;
GRANT ROLE IDENTIFIER($CORTEX_ROLE_NAME) TO ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- Grants: dbt service role
-- ---------------------------------------------------------------------------
GRANT USAGE ON DATABASE IDENTIFIER($RAW_DB_NAME)
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT USAGE ON DATABASE IDENTIFIER($DW_DB_NAME)
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT USAGE, CREATE TABLE
  ON SCHEMA IDENTIFIER($RAW_DB_NAME || '.SEED')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT USAGE, CREATE TABLE, CREATE VIEW
  ON SCHEMA IDENTIFIER($DW_DB_NAME || '.OBT')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SEMANTIC VIEW
  ON SCHEMA IDENTIFIER($DW_DB_NAME || '.SEMANTIC')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT USAGE ON WAREHOUSE IDENTIFIER($DBT_WH_NAME)
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT USAGE ON WAREHOUSE IDENTIFIER($CORTEX_WH_NAME)
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

-- Agent creation privilege (required for dbt run-operation create_cortex_agents)
GRANT CREATE AGENT ON SCHEMA IDENTIFIER($DW_DB_NAME || '.SEMANTIC')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

-- Future grants so new tables/views are accessible
GRANT SELECT ON FUTURE TABLES IN SCHEMA IDENTIFIER($RAW_DB_NAME || '.SEED')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT SELECT ON FUTURE VIEWS IN SCHEMA IDENTIFIER($DW_DB_NAME || '.OBT')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

GRANT SELECT ON FUTURE TABLES IN SCHEMA IDENTIFIER($DW_DB_NAME || '.OBT')
  TO ROLE IDENTIFIER($DBT_ROLE_NAME);

-- ---------------------------------------------------------------------------
-- Grants: AI user role (read-only + agent usage)
-- ---------------------------------------------------------------------------
GRANT USAGE ON DATABASE IDENTIFIER($DW_DB_NAME)
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT USAGE ON SCHEMA IDENTIFIER($DW_DB_NAME || '.SEMANTIC')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT SELECT ON FUTURE SEMANTIC VIEWS IN SCHEMA IDENTIFIER($DW_DB_NAME || '.SEMANTIC')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA IDENTIFIER($DW_DB_NAME || '.SEMANTIC')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT USAGE ON WAREHOUSE IDENTIFIER($CORTEX_WH_NAME)
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

-- OBT access (semantic views query OBT views underneath)
GRANT USAGE ON SCHEMA IDENTIFIER($DW_DB_NAME || '.OBT')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT SELECT ON ALL VIEWS IN SCHEMA IDENTIFIER($DW_DB_NAME || '.OBT')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT SELECT ON FUTURE VIEWS IN SCHEMA IDENTIFIER($DW_DB_NAME || '.OBT')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

-- Seed access (OBT views query seed tables underneath)
GRANT USAGE ON DATABASE IDENTIFIER($RAW_DB_NAME)
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT USAGE ON SCHEMA IDENTIFIER($RAW_DB_NAME || '.SEED')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT SELECT ON ALL TABLES IN SCHEMA IDENTIFIER($RAW_DB_NAME || '.SEED')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

GRANT SELECT ON FUTURE TABLES IN SCHEMA IDENTIFIER($RAW_DB_NAME || '.SEED')
  TO ROLE IDENTIFIER($CORTEX_ROLE_NAME);

-- Note: USAGE ON AGENT is granted by the dbt macro (create_cortex_agents)
-- after the agent is created. No manual grant needed here.

-- ---------------------------------------------------------------------------
-- Grant dbt role to your user (adjust as needed)
-- ---------------------------------------------------------------------------
-- GRANT ROLE IDENTIFIER($DBT_ROLE_NAME) TO USER <your_user>;
-- GRANT ROLE IDENTIFIER($CORTEX_ROLE_NAME) TO USER <your_user>;
