-- =============================================================================
-- Demo RAW tables (source layer)
-- =============================================================================
-- Two reference tables in RAW.SEED, singular names per repo standard.
-- CHANGE_TRACKING = TRUE so downstream dynamic tables incrementally refresh.
-- Populated by post_scripts/01_seed_data.sql.
-- =============================================================================

{% set raw_db = db_name(team_name, 'RAW') %}

DEFINE TABLE {{ raw_db }}.SEED.CUSTOMER (
    customer_id     NUMBER,
    customer_name   VARCHAR,
    email           VARCHAR,
    signup_date     DATE,
    region          VARCHAR,
    is_active       BOOLEAN
)
CHANGE_TRACKING = TRUE
COMMENT = 'Customer reference data (seeded)';

DEFINE TABLE {{ raw_db }}.SEED.SALES_ORDER (
    sales_order_id  NUMBER,
    customer_id     NUMBER,
    order_date      DATE,
    item_count      NUMBER,
    order_total_usd NUMBER(10, 2),
    status          VARCHAR
)
CHANGE_TRACKING = TRUE
COMMENT = 'Order events (seeded). Avoids reserved word ORDER.';
