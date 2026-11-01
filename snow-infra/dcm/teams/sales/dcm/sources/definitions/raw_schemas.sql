-- =============================================================================
-- RAW schemas — source layer (landed data, no transformations)
-- =============================================================================

{% set raw_db = db_name(team_name, 'RAW') %}

DEFINE SCHEMA {{ raw_db }}.SEED
    COMMENT = 'Small reference tables seeded by dbt';
