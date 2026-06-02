-- =============================================================================
-- RAW schemas — source layer (landed data, no transformations)
-- =============================================================================
-- DATABASE is platform-owned (see platform/dcm/sources/definitions/
-- team_databases.sql). This file only creates the schemas inside, which the
-- team owns post-ownership-transfer.
--
-- Schemas:
--   SEED        — small reference data committed alongside dbt
--   YELLOW_TAXI — NYC TLC sample dataset
--   KAFKA       — streamed events
--   UTIL        — pipes, stages, helpers
-- =============================================================================

{% set raw_db = db_name('RAW') %}

DEFINE SCHEMA {{ raw_db }}.SEED
    COMMENT = 'Small reference tables seeded by dbt';

DEFINE SCHEMA {{ raw_db }}.YELLOW_TAXI
    COMMENT = 'NYC TLC yellow-taxi sample data';

DEFINE SCHEMA {{ raw_db }}.KAFKA
    COMMENT = 'Events landed by Kafka Connect';

DEFINE SCHEMA {{ raw_db }}.UTIL
    COMMENT = 'Stages, file formats, and pipes';
