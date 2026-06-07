-- =============================================================================
-- DW schemas — modeled / consumption layer
-- =============================================================================
-- Database is platform-owned. Team creates these schemas.
-- NOTE: the DCM state schema (PREP_DB.DCM) is created by the team out-of-band
-- alongside the DCM PROJECT object - see README "Create team DCM project" step.
-- It's deliberately not declared here because DCM can't define the schema
-- that contains its own project, and the platform layer doesn't create it
-- either (FUTURE-grant conflict on ownership transfer).
-- =============================================================================

{% set dw_db = db_name('DW') %}

DEFINE SCHEMA {{ dw_db }}.DIM
    COMMENT = 'Dimensional tables';

DEFINE SCHEMA {{ dw_db }}.FACT
    COMMENT = 'Fact tables';

DEFINE SCHEMA {{ dw_db }}.OBT
    COMMENT = 'One Big Tables for BI / AI consumption';

DEFINE SCHEMA {{ dw_db }}.SEMANTIC
    COMMENT = 'Semantic views for Cortex Analyst';

DEFINE SCHEMA {{ dw_db }}.COMPLIANCE
    COMMENT = 'PII and compliance-controlled data';

DEFINE SCHEMA {{ dw_db }}.UTIL
    COMMENT = 'Query helpers and lookups';
