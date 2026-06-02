-- =============================================================================
-- DW schemas — modeled / consumption layer
-- =============================================================================
-- Database is platform-owned. Team creates these schemas.
-- NOTE: the DCM schema (DW_DB.DCM) is created by PLATFORM, not by this team
-- project — it's where this project's own state lives.
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
