-- =============================================================================
-- Platform DCM Bootstrap Teardown
-- =============================================================================
-- DESTRUCTIVE. Run as ACCOUNTADMIN. Only after all DCM PROJECTS in DCM_REGISTRY
-- have been purged (use scripts/04_purge.sql first).
-- =============================================================================

USE ROLE ACCOUNTADMIN;
DROP DATABASE  IF EXISTS DCM_REGISTRY;
DROP WAREHOUSE IF EXISTS SVC_PLATFORM_SNOW_DCM_WH_XS;

USE ROLE SECURITYADMIN;
DROP USER IF EXISTS SVC_PLATFORM_SNOW_DCM_USER;
DROP ROLE IF EXISTS SVC_PLATFORM_SNOW_DCM_ROLE;
