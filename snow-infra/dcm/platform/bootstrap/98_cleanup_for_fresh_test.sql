-- =============================================================================
-- Cleanup before a fresh DCM demo deploy
-- =============================================================================
-- WHEN TO RUN: before re-running platform deploy on a previously-deployed
-- account. Drops every demo-created object so the next plan/deploy starts
-- from a known empty state. Keeps Phase 0 bootstrap intact:
--   - SVC_PLATFORM_DCM_USER + SVC_SALES_DCM_USER (registered RSA keys preserved)
--   - SVC_PLATFORM_DCM_ROLE
--   - SVC_PLATFORM_DCM_WH_XS
--
-- HOW TO RUN: Snowsight, paste as ACCOUNTADMIN.
--
-- AFTER THIS: resume from Step 4 of README Getting Started (recreate platform
-- DCM project objects, then platform deploy). Steps 1-3 stay valid.
--
-- For a full teardown (drop Phase 0 too), use 99_teardown.sql instead.
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------------------
-- Team DBs (now team-owned; team creates RAW/PREP/DW, platform creates DCM_DB)
-- ---------------------------------------------------------------------------
DROP DATABASE IF EXISTS DEV_SALES_RAW_DB;
DROP DATABASE IF EXISTS DEV_SALES_PREP_DB;
DROP DATABASE IF EXISTS DEV_SALES_DW_DB;
DROP DATABASE IF EXISTS DEV_SALES_DCM_DB;
DROP DATABASE IF EXISTS STG_SALES_RAW_DB;
DROP DATABASE IF EXISTS STG_SALES_PREP_DB;
DROP DATABASE IF EXISTS STG_SALES_DW_DB;
DROP DATABASE IF EXISTS STG_SALES_DCM_DB;
DROP DATABASE IF EXISTS PRD_SALES_RAW_DB;
DROP DATABASE IF EXISTS PRD_SALES_PREP_DB;
DROP DATABASE IF EXISTS PRD_SALES_DW_DB;
DROP DATABASE IF EXISTS PRD_SALES_DCM_DB;

-- ---------------------------------------------------------------------------
-- Platform DCM DBs (per env)
-- ---------------------------------------------------------------------------
DROP DATABASE IF EXISTS DEV_PLATFORM_DCM_DB;
DROP DATABASE IF EXISTS STG_PLATFORM_DCM_DB;
DROP DATABASE IF EXISTS PRD_PLATFORM_DCM_DB;

-- ---------------------------------------------------------------------------
-- Team DCM warehouses (one per env, team-scoped for cost attribution)
-- ---------------------------------------------------------------------------
DROP WAREHOUSE IF EXISTS SVC_SALES_DCM_WH_XS;

USE ROLE SECURITYADMIN;

-- ---------------------------------------------------------------------------
-- Team DCM role (USER stays — its RSA key is registered and reused)
-- ---------------------------------------------------------------------------
DROP ROLE IF EXISTS SVC_SALES_DCM_ROLE;
