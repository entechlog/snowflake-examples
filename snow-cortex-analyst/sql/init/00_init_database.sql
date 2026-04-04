-- =============================================================================
-- Snowflake Object Setup for Cortex Analyst Demo
-- Run this if you are NOT using the Terraform setup from snow-infra
-- =============================================================================

-- Set variables at the beginning of the script
-- Modify these values as needed for your environment
SET ENV_CODE = 'DEV';        -- Options: DEV, STG, PRD
SET PROJ_CODE = 'ENTECHLOG'; -- Your project code

-- Construct database and warehouse names using the variables
SET RAW_DB_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_RAW_DB';
SET DW_DB_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_DW_DB';
SET DBT_WH_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_DBT_WH_XS';
SET CORTEX_WH_NAME = $ENV_CODE || '_' || $PROJ_CODE || '_CORTEX_WH_XS';
SET SCHEMA_SEED = $RAW_DB_NAME || '.SEED';
SET SCHEMA_OBT = $DW_DB_NAME || '.OBT';
SET SCHEMA_SEMANTIC = $DW_DB_NAME || '.SEMANTIC';

USE ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- Databases
-- ---------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS IDENTIFIER($RAW_DB_NAME)
  COMMENT = 'Raw data for ' || $PROJ_CODE || ' (' || $ENV_CODE || ')';

CREATE DATABASE IF NOT EXISTS IDENTIFIER($DW_DB_NAME)
  COMMENT = 'Data warehouse for ' || $PROJ_CODE || ' (' || $ENV_CODE || ')';

-- ---------------------------------------------------------------------------
-- Schemas
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS IDENTIFIER($SCHEMA_SEED)
  COMMENT = 'Seed data loaded by dbt';

CREATE SCHEMA IF NOT EXISTS IDENTIFIER($SCHEMA_OBT)
  COMMENT = 'One Big Table layer - pre-aggregated views';

CREATE SCHEMA IF NOT EXISTS IDENTIFIER($SCHEMA_SEMANTIC)
  COMMENT = 'Semantic views for Cortex Analyst';

-- ---------------------------------------------------------------------------
-- Warehouses
-- ---------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($DBT_WH_NAME)
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'dbt execution warehouse (' || $ENV_CODE || ')';

CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($CORTEX_WH_NAME)
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Cortex Analyst agent warehouse (' || $ENV_CODE || ')';
