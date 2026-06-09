-- =============================================================================
-- Platform DCM Project Objects (one per env)
-- =============================================================================
-- Run as SVC_PLATFORM_DCM_ROLE (or via snow CLI with the platform
-- connection). Creates the central registry that holds the PLATFORM project
-- object for each env. Re-runnable.
-- =============================================================================

USE ROLE SVC_PLATFORM_DCM_ROLE;
USE WAREHOUSE SVC_PLATFORM_DCM_WH_XS;

CREATE DATABASE IF NOT EXISTS DEV_PLATFORM_DCM_DB;
CREATE SCHEMA   IF NOT EXISTS DEV_PLATFORM_DCM_DB.PROJECTS;
CREATE DCM PROJECT IF NOT EXISTS DEV_PLATFORM_DCM_DB.PROJECTS.INFRA;

CREATE DATABASE IF NOT EXISTS STG_PLATFORM_DCM_DB;
CREATE SCHEMA   IF NOT EXISTS STG_PLATFORM_DCM_DB.PROJECTS;
CREATE DCM PROJECT IF NOT EXISTS STG_PLATFORM_DCM_DB.PROJECTS.INFRA;

CREATE DATABASE IF NOT EXISTS PRD_PLATFORM_DCM_DB;
CREATE SCHEMA   IF NOT EXISTS PRD_PLATFORM_DCM_DB.PROJECTS;
CREATE DCM PROJECT IF NOT EXISTS PRD_PLATFORM_DCM_DB.PROJECTS.INFRA;
