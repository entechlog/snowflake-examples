-- =============================================================================
-- Platform DCM Project Objects (one per env)
-- =============================================================================
-- Run as SVC_PLATFORM_SNOW_DCM_ROLE (or via snow CLI with the platform
-- connection). Creates the central registry that holds the PLATFORM project
-- object for each env. Re-runnable.
-- =============================================================================

USE ROLE SVC_PLATFORM_SNOW_DCM_ROLE;
USE WAREHOUSE SVC_PLATFORM_SNOW_DCM_WH_XS;

CREATE DATABASE IF NOT EXISTS DCM_REGISTRY
  COMMENT = 'Central registry for platform-level DCM projects';
CREATE SCHEMA IF NOT EXISTS DCM_REGISTRY.PROJECTS
  COMMENT = 'Holds DCM PROJECT objects for the platform layer';

CREATE DCM PROJECT IF NOT EXISTS DCM_REGISTRY.PROJECTS.DEV_PLATFORM_PROJECT
  COMMENT = 'Platform DCM project (DEV)';
CREATE DCM PROJECT IF NOT EXISTS DCM_REGISTRY.PROJECTS.STG_PLATFORM_PROJECT
  COMMENT = 'Platform DCM project (STG)';
CREATE DCM PROJECT IF NOT EXISTS DCM_REGISTRY.PROJECTS.PRD_PLATFORM_PROJECT
  COMMENT = 'Platform DCM project (PRD)';

SHOW DCM PROJECTS IN SCHEMA DCM_REGISTRY.PROJECTS;
