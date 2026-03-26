-- =============================================================================
-- Cleanup: Remove all demo objects
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
SET AGENT_NAME = $ENV_CODE || '_sales_agent';

USE ROLE SYSADMIN;

-- Drop agents first (if they exist)
DROP CORTEX AGENT IF EXISTS IDENTIFIER($DW_DB_NAME || '.SEMANTIC.' || $AGENT_NAME);

-- Drop semantic views
DROP SEMANTIC VIEW IF EXISTS IDENTIFIER($DW_DB_NAME || '.SEMANTIC.order_stats_1d');
DROP SEMANTIC VIEW IF EXISTS IDENTIFIER($DW_DB_NAME || '.SEMANTIC.customer_stats_1d');

-- Drop OBT views
DROP VIEW IF EXISTS IDENTIFIER($DW_DB_NAME || '.OBT.order_stats_1d');
DROP VIEW IF EXISTS IDENTIFIER($DW_DB_NAME || '.OBT.customer_stats_1d');

-- Drop seed tables
DROP TABLE IF EXISTS IDENTIFIER($RAW_DB_NAME || '.SEED.order_stats_1d');
DROP TABLE IF EXISTS IDENTIFIER($RAW_DB_NAME || '.SEED.customer_stats_1d');

-- Drop schemas
DROP SCHEMA IF EXISTS IDENTIFIER($DW_DB_NAME || '.SEMANTIC');
DROP SCHEMA IF EXISTS IDENTIFIER($DW_DB_NAME || '.OBT');
DROP SCHEMA IF EXISTS IDENTIFIER($RAW_DB_NAME || '.SEED');

-- Drop warehouses
DROP WAREHOUSE IF EXISTS IDENTIFIER($CORTEX_WH_NAME);
DROP WAREHOUSE IF EXISTS IDENTIFIER($DBT_WH_NAME);

-- Drop database
DROP DATABASE IF EXISTS IDENTIFIER($DW_DB_NAME);

-- Drop roles
USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS IDENTIFIER($CORTEX_ROLE_NAME);
DROP ROLE IF EXISTS IDENTIFIER($DBT_ROLE_NAME);
