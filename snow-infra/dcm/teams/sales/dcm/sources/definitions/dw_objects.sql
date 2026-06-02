-- =============================================================================
-- Demo DW objects (consumption layer)
-- =============================================================================
-- Three object types DCM manages natively:
--   1. Dimensional table   — DIM.CUSTOMERS
--   2. Fact table          — FACT.ORDERS
--   3. Dynamic table (OBT) — refreshes from prep views automatically
--
-- INITIALIZE = ON_SCHEDULE skips synchronous first refresh during deploy →
-- much faster plan/apply cycles. Initial refresh runs in scripts/03.
-- =============================================================================

{% set prep_db = db_name('PREP') %}
{% set dw_db   = db_name('DW')   %}

DEFINE TABLE {{ dw_db }}.DIM.CUSTOMERS (
    customer_sk     NUMBER AUTOINCREMENT START 1 INCREMENT 1,
    customer_id     NUMBER,
    customer_name   VARCHAR,
    email           VARCHAR,
    region          VARCHAR,
    signup_date     DATE,
    is_active       BOOLEAN,
    valid_from      TIMESTAMP_NTZ,
    valid_to        TIMESTAMP_NTZ,
    is_current      BOOLEAN
)
COMMENT = 'Customer dimension (SCD-2 ready)';

DEFINE TABLE {{ dw_db }}.FACT.ORDERS (
    order_id        NUMBER,
    customer_sk     NUMBER,
    order_date      DATE,
    item_count      NUMBER,
    order_total_usd NUMBER(10, 2),
    status          VARCHAR
)
CLUSTER BY (order_date)
COMMENT = 'Order facts, clustered by date';

-- One Big Table — dynamic table pre-joining customers + orders.
-- TARGET_LAG = 'DOWNSTREAM' refreshes on read instead of polling.
-- DCM resolves the dependency on the prep views automatically.
DEFINE DYNAMIC TABLE {{ dw_db }}.OBT.CUSTOMER_ORDERS
    WAREHOUSE  = {{ wh_name('DBT') }}
    TARGET_LAG = 'DOWNSTREAM'
    INITIALIZE = ON_SCHEDULE
AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.region,
    o.order_id,
    o.order_date,
    o.item_count,
    o.order_total_usd,
    o.status
FROM {{ prep_db }}.STAGING.STG_CUSTOMERS c
LEFT JOIN {{ prep_db }}.STAGING.STG_ORDERS o
    ON c.customer_id = o.customer_id;
