-- =============================================================================
-- PREP schemas — staging / standardization layer
-- =============================================================================
-- Database is platform-owned. Team only creates these schemas.
-- =============================================================================

{% set prep_db = db_name('PREP') %}

DEFINE SCHEMA {{ prep_db }}.STAGING
    COMMENT = 'Cleaned 1:1 mirrors of RAW';

DEFINE SCHEMA {{ prep_db }}.INTERIM
    COMMENT = 'Joined / standardized intermediate models';

DEFINE SCHEMA {{ prep_db }}.UTIL
    COMMENT = 'Helper objects (sequences, lookup tables)';
