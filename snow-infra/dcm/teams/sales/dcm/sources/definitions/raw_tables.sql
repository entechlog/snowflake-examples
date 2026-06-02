-- =============================================================================
-- Demo RAW tables (source layer)
-- =============================================================================
-- Two reference tables in RAW.SEED. CHANGE_TRACKING = TRUE so downstream
-- dynamic tables can incrementally refresh. Populated by scripts/03_post_deploy.sql.
-- =============================================================================

{% set raw_db = db_name('RAW') %}

DEFINE TABLE {{ raw_db }}.SEED.CUSTOMERS (
    customer_id     NUMBER,
    customer_name   VARCHAR,
    email           VARCHAR,
    signup_date     DATE,
    region          VARCHAR,
    is_active       BOOLEAN
)
CHANGE_TRACKING = TRUE
COMMENT = 'Customer reference data (seeded)';

DEFINE TABLE {{ raw_db }}.SEED.ORDERS (
    order_id        NUMBER,
    customer_id     NUMBER,
    order_date      DATE,
    item_count      NUMBER,
    order_total_usd NUMBER(10, 2),
    status          VARCHAR
)
CHANGE_TRACKING = TRUE
COMMENT = 'Order events (seeded)';
