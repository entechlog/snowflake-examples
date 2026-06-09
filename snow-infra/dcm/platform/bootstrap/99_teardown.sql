-- =============================================================================
-- Platform DCM Bootstrap Teardown
-- =============================================================================
-- DESTRUCTIVE. Run as ACCOUNTADMIN. Only after all platform DCM PROJECTs have
-- been purged (use scripts/04_purge.sql first, per env).
-- =============================================================================

USE ROLE ACCOUNTADMIN;
DROP DATABASE  IF EXISTS DEV_PLATFORM_DCM_DB;
DROP DATABASE  IF EXISTS STG_PLATFORM_DCM_DB;
DROP DATABASE  IF EXISTS PRD_PLATFORM_DCM_DB;
DROP WAREHOUSE IF EXISTS SVC_PLATFORM_DCM_WH_XS;

USE ROLE SECURITYADMIN;
DROP USER IF EXISTS SVC_PLATFORM_DCM_USER;
DROP ROLE IF EXISTS SVC_PLATFORM_DCM_ROLE;
