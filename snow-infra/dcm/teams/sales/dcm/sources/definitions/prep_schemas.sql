-- =============================================================================
-- PREP schemas — staging / standardization layer
-- =============================================================================
-- Database is platform-owned. Team only creates these schemas.
-- PREP mirrors DW's DIM/FACT shape so the
-- same modeling concepts live in both layers - PREP is the conformed staging
-- ground, DW is the consumer-facing final form.
-- =============================================================================

{% set prep_db = db_name(team_name, 'PREP') %}

DEFINE SCHEMA {{ prep_db }}.DIM
    COMMENT = 'Conformed dimension staging (pre-DW DIM)';

DEFINE SCHEMA {{ prep_db }}.FACT
    COMMENT = 'Conformed fact staging (pre-DW FACT)';
