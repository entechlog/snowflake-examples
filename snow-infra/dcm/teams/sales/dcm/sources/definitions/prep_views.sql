-- =============================================================================
-- Demo PREP views (staging layer — cleaned mirrors of RAW)
-- =============================================================================
-- dbt typically owns this layer, but DCM can pre-define when the pipeline
-- shape is known and stable. Shown here to demonstrate dependency ordering —
-- DCM resolves the order automatically across files.
-- =============================================================================

{% set raw_db  = db_name('RAW')  %}
{% set prep_db = db_name('PREP') %}

DEFINE VIEW {{ prep_db }}.STAGING.STG_CUSTOMERS AS
SELECT
    customer_id,
    INITCAP(customer_name) AS customer_name,
    LOWER(email)           AS email,
    signup_date,
    UPPER(region)          AS region,
    is_active
FROM {{ raw_db }}.SEED.CUSTOMERS;

DEFINE VIEW {{ prep_db }}.STAGING.STG_ORDERS AS
SELECT
    order_id,
    customer_id,
    order_date,
    item_count,
    order_total_usd,
    UPPER(status) AS status
FROM {{ raw_db }}.SEED.ORDERS
WHERE order_id IS NOT NULL;
