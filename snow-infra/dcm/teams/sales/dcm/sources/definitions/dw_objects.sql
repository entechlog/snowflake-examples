-- =============================================================================
-- Demo DW objects (consumption layer)
-- =============================================================================
-- Three object types DCM manages natively:
--   1. Dimensional table   - DIM.CUSTOMER
--   2. Fact table          - FACT.SALES_ORDER
--   3. Dynamic table (OBT) - refreshes from PREP staging views automatically
--
-- INITIALIZE = ON_SCHEDULE skips synchronous first refresh during deploy
-- (much faster plan/apply cycles). Initial refresh runs in post_scripts/.
--
-- Naming: singular per repo standard. SALES_ORDER instead of ORDER to avoid
-- the SQL reserved word collision.
-- =============================================================================

{% set prep_db = db_name(team_name, 'PREP') %}
{% set dw_db   = db_name(team_name, 'DW')   %}

DEFINE TABLE {{ dw_db }}.DIM.CUSTOMER (
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

DEFINE TABLE {{ dw_db }}.FACT.SALES_ORDER (
    sales_order_id  NUMBER,
    customer_sk     NUMBER,
    order_date      DATE,
    item_count      NUMBER,
    order_total_usd NUMBER(10, 2),
    status          VARCHAR
)
CLUSTER BY (order_date)
COMMENT = 'Sales order facts, clustered by date';

-- One Big Table - dynamic table pre-joining customer + sales orders.
-- TARGET_LAG = 'DOWNSTREAM' refreshes on read instead of polling.
-- DCM resolves the dependency on the prep views automatically.
DEFINE DYNAMIC TABLE {{ dw_db }}.OBT.CUSTOMER_SALES_ORDER
    WAREHOUSE  = SVC_SALES_DCM_WH_XS
    TARGET_LAG = 'DOWNSTREAM'
    INITIALIZE = ON_SCHEDULE
AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.region,
    o.sales_order_id,
    o.order_date,
    o.item_count,
    o.order_total_usd,
    o.status
FROM {{ prep_db }}.DIM.STG_CUSTOMER c
LEFT JOIN {{ prep_db }}.FACT.STG_SALES_ORDER o
    ON c.customer_id = o.customer_id;
