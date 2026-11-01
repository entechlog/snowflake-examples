-- =============================================================================
-- Demo PREP views (conformed staging — cleaned mirrors of RAW)
-- =============================================================================
-- Cleaned 1:1 mirrors of RAW lands here for downstream DW modeling. dbt
-- typically owns this layer; DCM can pre-define when the pipeline shape is
-- known and stable. Shown here to demonstrate dependency ordering - DCM
-- resolves the order automatically across files.
--
-- Naming: views are singular per repo standard (CUSTOMER not CUSTOMERS).
-- Prefix STG_ marks them as cleaned staging vs RAW source. They sit in
-- PREP.DIM and PREP.FACT to mirror DW's modeling shape.
-- =============================================================================

{% set raw_db  = db_name(team_name, 'RAW')  %}
{% set prep_db = db_name(team_name, 'PREP') %}

DEFINE VIEW {{ prep_db }}.DIM.STG_CUSTOMER AS
SELECT
    customer_id,
    INITCAP(customer_name) AS customer_name,
    LOWER(email)           AS email,
    signup_date,
    UPPER(region)          AS region,
    is_active
FROM {{ raw_db }}.SEED.CUSTOMER;

DEFINE VIEW {{ prep_db }}.FACT.STG_SALES_ORDER AS
SELECT
    sales_order_id,
    customer_id,
    order_date,
    item_count,
    order_total_usd,
    UPPER(status) AS status
FROM {{ raw_db }}.SEED.SALES_ORDER
WHERE sales_order_id IS NOT NULL;
