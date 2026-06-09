-- =============================================================================
-- Purge PLATFORM project for one env (drops account roles + team DBs + team
-- DCM scaffolding it created). Run AFTER all teams have purged their own
-- projects, otherwise team objects become orphaned.
-- =============================================================================
SET ENV_CODE = 'DEV';     -- DEV, STG, PRD
SET PROJECT_FQN = $ENV_CODE || '_PLATFORM_DCM_DB.PROJECTS.INFRA';

USE ROLE SVC_PLATFORM_DCM_ROLE;
USE WAREHOUSE SVC_PLATFORM_DCM_WH_XS;

EXECUTE DCM PROJECT IDENTIFIER($PROJECT_FQN) PURGE;
