-- Create role and user
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS TST_ENTECHLOG_STREAMLIT_ROLE;
CREATE USER IF NOT EXISTS TST_ENTECHLOG_STREAMLIT_USER DEFAULT_ROLE = TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT ROLE TST_ENTECHLOG_STREAMLIT_ROLE TO USER TST_ENTECHLOG_STREAMLIT_USER;

ALTER USER TST_ENTECHLOG_STREAMLIT_USER SET PASSWORD = '<password>';

-- Create warehouse
USE ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE TST_ENTECHLOG_STREAMLIT_WH_XS
WITH 
WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 60 
AUTO_RESUME = TRUE 
MIN_CLUSTER_COUNT = 1 
MAX_CLUSTER_COUNT = 1
SCALING_POLICY = 'ECONOMY' 
COMMENT = 'Warehouse for streamlit';

--GRANT required access to the role
GRANT USAGE ON WAREHOUSE TST_ENTECHLOG_STREAMLIT_WH_XS TO ROLE TST_ENTECHLOG_STREAMLIT_ROLE;

-- Get account ID
SELECT CURRENT_ACCOUNT();

-- Premissions related to dim and fact table access
-- Run this after creating the dim and fact in Snowflake
GRANT USAGE ON DATABASE TST_ENTECHLOG_DW_DB TO TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT USAGE ON SCHEMA TST_ENTECHLOG_DW_DB.DIM TO TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT USAGE ON SCHEMA TST_ENTECHLOG_DW_DB.FACT TO TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA TST_ENTECHLOG_DW_DB.DIM TO TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA TST_ENTECHLOG_DW_DB.FACT TO TST_ENTECHLOG_STREAMLIT_ROLE;

-- Premissions related to raw table access
-- Run this after creating the dim and fact in Snowflake
-- Use only for any manual data validation
GRANT USAGE ON DATABASE TST_ENTECHLOG_RAW_DB TO TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT USAGE ON SCHEMA TST_ENTECHLOG_RAW_DB.YELLOW_TAXI TO TST_ENTECHLOG_STREAMLIT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA TST_ENTECHLOG_RAW_DB.YELLOW_TAXI TO TST_ENTECHLOG_STREAMLIT_ROLE;
