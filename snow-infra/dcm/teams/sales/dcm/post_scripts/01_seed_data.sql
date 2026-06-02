-- =============================================================================
-- Post-deploy: seed sample data + refresh dynamic tables
-- =============================================================================
-- Lives in dcm/post_scripts/ so the official
-- Snowflake-Labs/snowflake_dcm_projects/actions/dcm-deploy action runs it
-- automatically after every deploy (post-scripts-path: "post_scripts").
--
-- For local runs, call explicitly:
--   snow sql -f dcm/post_scripts/01_seed_data.sql --connection dcm-dev
--
-- Re-runnable: INSERT statements would duplicate rows on second run — the
-- TRUNCATE up front keeps it idempotent.
-- =============================================================================

SET ENV_CODE  = 'DEV';        -- DEV, STG, PRD — pick to match deploy target
SET TEAM_NAME = 'SALES';

SET RAW_DB        = $ENV_CODE || '_' || $TEAM_NAME || '_RAW_DB';
SET DW_DB         = $ENV_CODE || '_' || $TEAM_NAME || '_DW_DB';
-- Hybrid pattern: team project lives inside team's DW DB
SET PROJECT_FQN   = $DW_DB || '.DCM.' || $ENV_CODE || '_' || $TEAM_NAME || '_PROJECT';
SET CUSTOMERS_FQN = $RAW_DB || '.SEED.CUSTOMERS';
SET ORDERS_FQN    = $RAW_DB || '.SEED.ORDERS';
SET OBT_FQN       = $DW_DB  || '.OBT.CUSTOMER_ORDERS';

USE ROLE SVC_SALES_SNOW_DCM_ROLE;
USE WAREHOUSE SVC_PLATFORM_SNOW_DCM_WH_XS;

-- ---------------------------------------------------------------------------
-- Idempotency — clear seed tables before re-loading
-- ---------------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS IDENTIFIER($CUSTOMERS_FQN);
TRUNCATE TABLE IF EXISTS IDENTIFIER($ORDERS_FQN);

-- ---------------------------------------------------------------------------
-- Seed customers
-- ---------------------------------------------------------------------------
INSERT INTO IDENTIFIER($CUSTOMERS_FQN)
    (customer_id, customer_name, email, signup_date, region, is_active)
VALUES
    (1, 'alice cooper',  'alice@example.com',  '2024-01-15', 'us-east', TRUE),
    (2, 'bob martinez',  'bob@example.com',    '2024-02-03', 'us-west', TRUE),
    (3, 'carol davis',   'carol@example.com',  '2024-02-20', 'eu-west', TRUE),
    (4, 'dan ellis',     'dan@example.com',    '2024-03-10', 'us-east', FALSE);

-- ---------------------------------------------------------------------------
-- Seed orders
-- ---------------------------------------------------------------------------
INSERT INTO IDENTIFIER($ORDERS_FQN)
    (order_id, customer_id, order_date, item_count, order_total_usd, status)
VALUES
    (1001, 1, '2026-05-01', 3, 149.50, 'shipped'),
    (1002, 2, '2026-05-02', 1,  29.99, 'shipped'),
    (1003, 1, '2026-05-15', 5, 274.00, 'pending'),
    (1004, 3, '2026-05-20', 2,  88.00, 'shipped'),
    (1005, 2, '2026-05-28', 4, 210.00, 'cancelled');

-- ---------------------------------------------------------------------------
-- Refresh dynamic tables defined with INITIALIZE = ON_SCHEDULE
-- ---------------------------------------------------------------------------
EXECUTE DCM PROJECT IDENTIFIER($PROJECT_FQN) REFRESH ALL;

-- ---------------------------------------------------------------------------
-- Verify
-- ---------------------------------------------------------------------------
SELECT * FROM IDENTIFIER($OBT_FQN) ORDER BY order_date;
