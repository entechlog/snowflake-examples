-- =============================================================================
-- Cleanup: PURGE all objects deployed by the DCM project for one env
-- =============================================================================
-- DCM PURGE drops every object the project created, in correct dependency
-- order. After this you can drop the DCM project object itself or re-deploy.
--
-- Cleanup stays in scripts/ (NOT post_scripts/) because it should be
-- run intentionally — never automatically as part of a deploy.
-- =============================================================================

SET ENV_CODE  = 'DEV';        -- DEV, STG, PRD — run once per env to clean up
SET PROJ_CODE = 'SALES';

SET PROJECT_FQN = 'DCM_REGISTRY.PROJECTS.' || $ENV_CODE || '_' || $PROJ_CODE || '_PROJECT';

USE ROLE SVC_SALES_SNOW_DCM_ROLE;
USE WAREHOUSE SVC_SALES_SNOW_DCM_WH_XS;

-- Drops every object DCM is tracking (DBs, schemas, tables, views, roles, WHs)
EXECUTE DCM PROJECT IDENTIFIER($PROJECT_FQN) PURGE;

-- Optional: drop the project itself (loses deployment history)
-- DROP DCM PROJECT IF EXISTS IDENTIFIER($PROJECT_FQN);

-- To remove the DCM bootstrap (service role + registry), run bootstrap/99_teardown.sql
