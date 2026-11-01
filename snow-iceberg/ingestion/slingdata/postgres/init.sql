-- =============================================================================
-- Seed data for Slingdata ingestion demo
-- Creates customers and orders tables with synthetic data
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Customers
-- ---------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(80),
    state         VARCHAR(50),
    country       VARCHAR(50) DEFAULT 'US',
    signup_date   DATE NOT NULL,
    status        VARCHAR(20) DEFAULT 'active',
    created_at    TIMESTAMP DEFAULT NOW()
);

INSERT INTO customers (full_name, email, phone, city, state, signup_date, status)
SELECT
    'Customer ' || gs AS full_name,
    'customer' || gs || '@example.com' AS email,
    '555-' || LPAD(gs::TEXT, 4, '0') AS phone,
    (ARRAY['New York','Los Angeles','Chicago','Houston','Phoenix','Philadelphia',
           'San Antonio','San Diego','Dallas','San Jose'])[1 + (gs % 10)] AS city,
    (ARRAY['NY','CA','IL','TX','AZ','PA','TX','CA','TX','CA'])[1 + (gs % 10)] AS state,
    CURRENT_DATE - (gs || ' days')::INTERVAL AS signup_date,
    (ARRAY['active','active','active','inactive','pending'])[1 + (gs % 5)] AS status
FROM generate_series(1, 50) AS gs;

-- ---------------------------------------------------------------------------
-- Orders
-- ---------------------------------------------------------------------------
CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    order_date      DATE NOT NULL,
    total_amount    NUMERIC(10, 2) NOT NULL,
    payment_method  VARCHAR(30) NOT NULL,
    order_status    VARCHAR(20) DEFAULT 'completed',
    created_at      TIMESTAMP DEFAULT NOW()
);

INSERT INTO orders (customer_id, order_date, total_amount, payment_method, order_status)
SELECT
    1 + (gs % 50) AS customer_id,
    CURRENT_DATE - (gs || ' days')::INTERVAL AS order_date,
    ROUND((10 + RANDOM() * 490)::NUMERIC, 2) AS total_amount,
    (ARRAY['credit_card','debit_card','paypal','bank_transfer','apple_pay'])[1 + (gs % 5)] AS payment_method,
    (ARRAY['completed','completed','completed','shipped','processing','cancelled'])[1 + (gs % 6)] AS order_status
FROM generate_series(1, 200) AS gs;
