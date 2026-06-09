-- =============================================================================
-- DW schemas — modeled / consumption layer
-- =============================================================================

{% set dw_db = db_name(team_name, 'DW') %}

DEFINE SCHEMA {{ dw_db }}.DIM
    COMMENT = 'Dimensional tables';

DEFINE SCHEMA {{ dw_db }}.FACT
    COMMENT = 'Fact tables';

DEFINE SCHEMA {{ dw_db }}.OBT
    COMMENT = 'One Big Tables for BI / AI consumption';
