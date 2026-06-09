-- =============================================================================
-- Platform DCM Service Role & User Bootstrap
-- =============================================================================
-- Run ONCE as ACCOUNTADMIN. Creates the deployer for the PLATFORM layer —
-- the role with full account-level powers that owns the foundational objects
-- (account roles, team databases, per-team DCM scaffolding).
--
-- Per-team DCM service roles (e.g., SVC_SALES_DCM_ROLE) are NOT created
-- here — they're declared declaratively in the platform DCM project itself
-- (see platform/dcm/sources/definitions/team_dcm_scaffolding.sql).
-- =============================================================================

USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS SVC_PLATFORM_DCM_ROLE
  COMMENT = 'Platform-level DCM deployer (manages account roles + team DB scaffolding)';

CREATE USER IF NOT EXISTS SVC_PLATFORM_DCM_USER
  DEFAULT_ROLE      = SVC_PLATFORM_DCM_ROLE
  DEFAULT_WAREHOUSE = SVC_PLATFORM_DCM_WH_XS
  TYPE              = SERVICE
  COMMENT           = 'Service account for platform DCM plan/deploy';

GRANT ROLE SVC_PLATFORM_DCM_ROLE TO USER SVC_PLATFORM_DCM_USER;
GRANT ROLE SVC_PLATFORM_DCM_ROLE TO ROLE SYSADMIN;
GRANT ROLE SVC_PLATFORM_DCM_ROLE TO ROLE SECURITYADMIN;

-- ---------------------------------------------------------------------------
-- Account-level privileges (full platform powers)
-- ---------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

GRANT CREATE DATABASE              ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT CREATE WAREHOUSE             ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT CREATE ROLE                  ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT CREATE USER                  ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT MANAGE GRANTS                ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT EXECUTE TASK                 ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT EXECUTE MANAGED TASK         ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT EXECUTE DATA METRIC FUNCTION ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT APPLY MASKING POLICY         ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT APPLY ROW ACCESS POLICY      ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT APPLY TAG                    ON ACCOUNT TO ROLE SVC_PLATFORM_DCM_ROLE;

GRANT APPLICATION ROLE SNOWFLAKE.DATA_QUALITY_MONITORING_VIEWER TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT APPLICATION ROLE SNOWFLAKE.DATA_QUALITY_MONITORING_ADMIN  TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.DATA_METRIC_USER                  TO ROLE SVC_PLATFORM_DCM_ROLE;

-- ---------------------------------------------------------------------------
-- Platform warehouse
-- ---------------------------------------------------------------------------
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS SVC_PLATFORM_DCM_WH_XS
  WAREHOUSE_SIZE                      = 'XSMALL'
  AUTO_SUSPEND                        = 30
  AUTO_RESUME                         = TRUE
  INITIALLY_SUSPENDED                 = TRUE
  ENABLE_QUERY_ACCELERATION           = FALSE
  QUERY_ACCELERATION_MAX_SCALE_FACTOR = 8
  COMMENT                             = 'Warehouse for platform DCM plan/deploy';

GRANT USAGE, OPERATE ON WAREHOUSE SVC_PLATFORM_DCM_WH_XS
  TO ROLE SVC_PLATFORM_DCM_ROLE;

-- ---------------------------------------------------------------------------
-- Print account_identifier for manifest.yml (ORG-ACCOUNT format)
-- ---------------------------------------------------------------------------
SELECT CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME() AS account_identifier;

-- After this script:
--   1. Run platform/bootstrap/00_generate_platform_rsa_key.sh in snow-tools
--   2. Paste the printed ALTER USER ... SET RSA_PUBLIC_KEY = '...' here
--   3. Run platform/bootstrap/02_create_platform_project_objects.sql
