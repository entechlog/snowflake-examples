-- =============================================================================
-- Full teardown — wipes the account to empty
-- =============================================================================
-- DESTRUCTIVE. Use 98_cleanup_for_fresh_test.sql for normal repeat-test
-- cycles. This is for "decommission this account" / "start completely over".
--
-- WHEN TO RUN: only when you want to drop Phase 0 identities too. Almost
-- never needed during demos — 98 is what you want for repeat test cycles.
--
-- HOW TO RUN:
--   1. Snowsight: paste 98_cleanup_for_fresh_test.sql as ACCOUNTADMIN first
--      (drops team DBs/role/WH before the platform-side drops below).
--   2. Snowsight: paste this file as ACCOUNTADMIN.
--   3. On the host, delete the on-disk RSA keys (see README Cleanup §3.b).
--
-- AFTER THIS: re-run README Getting Started from Step 1.
-- =============================================================================

USE ROLE ACCOUNTADMIN;
DROP DATABASE  IF EXISTS DEV_PLATFORM_DCM_DB;
DROP DATABASE  IF EXISTS STG_PLATFORM_DCM_DB;
DROP DATABASE  IF EXISTS PRD_PLATFORM_DCM_DB;
DROP WAREHOUSE IF EXISTS SVC_PLATFORM_DCM_WH_XS;

USE ROLE SECURITYADMIN;
DROP USER IF EXISTS SVC_PLATFORM_DCM_USER;
DROP ROLE IF EXISTS SVC_PLATFORM_DCM_ROLE;

-- Team service users (created out-of-band per team in README Step 4)
DROP USER IF EXISTS SVC_SALES_DCM_USER;
