-- =============================================================================
-- Access Roles (ARs) — one RO + one RW per team DB, per env
-- =============================================================================
-- The AR layer holds the actual privileges via FUTURE grants. Functional and
-- service-functional roles never touch objects directly — they're granted
-- these ARs and inherit access.
--
-- ARs are env-scoped because the databases they target are env-scoped.
-- They're owned by the PLATFORM role (which legitimately has MANAGE GRANTS),
-- so the FUTURE-grant calls succeed without giving team roles broad perms.
--
-- Adding a new schema or table in the team layer? Nothing here changes —
-- FUTURE grants pick up new objects automatically on the team's next deploy.
-- =============================================================================

{% for team in teams %}
{% for layer in ['RAW', 'PREP', 'DW'] %}

{% set db = db_name(team.name, layer) %}
{% set ro_ar = ar_name(team.name, layer, 'RO') %}
{% set rw_ar = ar_name(team.name, layer, 'RW') %}

-- ─── {{ db }} ───────────────────────────────────────────────────────────────

DEFINE ROLE {{ ro_ar }}
    COMMENT = 'Read-only access on {{ db }}';
DEFINE ROLE {{ rw_ar }}
    COMMENT = 'Read-write access on {{ db }}';

GRANT ROLE {{ ro_ar }} TO ROLE SYSADMIN;
GRANT ROLE {{ rw_ar }} TO ROLE SYSADMIN;

-- RO_AR: USAGE on DB + read on every current and future object
GRANT USAGE ON DATABASE {{ db }} TO ROLE {{ ro_ar }};

GRANT USAGE   ON ALL SCHEMAS    IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT USAGE   ON FUTURE SCHEMAS IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT MONITOR ON ALL SCHEMAS    IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT MONITOR ON FUTURE SCHEMAS IN DATABASE {{ db }} TO ROLE {{ ro_ar }};

GRANT SELECT ON ALL TABLES              IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON FUTURE TABLES           IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON ALL VIEWS               IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON FUTURE VIEWS            IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON ALL DYNAMIC TABLES      IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON FUTURE DYNAMIC TABLES   IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON ALL EXTERNAL TABLES     IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON FUTURE EXTERNAL TABLES  IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON ALL MATERIALIZED VIEWS  IN DATABASE {{ db }} TO ROLE {{ ro_ar }};
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN DATABASE {{ db }} TO ROLE {{ ro_ar }};

-- RW_AR: everything RO has + write on data + create-everything on schemas
GRANT USAGE ON DATABASE {{ db }} TO ROLE {{ rw_ar }};

GRANT USAGE, MONITOR, MODIFY ON ALL SCHEMAS    IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT USAGE, MONITOR, MODIFY ON FUTURE SCHEMAS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};

GRANT CREATE TABLE,
      CREATE VIEW,
      CREATE DYNAMIC TABLE,
      CREATE EXTERNAL TABLE,
      CREATE MATERIALIZED VIEW,
      CREATE STAGE,
      CREATE FILE FORMAT,
      CREATE STREAM,
      CREATE TASK,
      CREATE PROCEDURE,
      CREATE FUNCTION,
      CREATE SEQUENCE,
      CREATE PIPE,
      CREATE SEMANTIC VIEW,
      CREATE AGENT,
      CREATE TAG,
      CREATE MASKING POLICY,
      CREATE ROW ACCESS POLICY
    ON ALL SCHEMAS    IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT CREATE TABLE,
      CREATE VIEW,
      CREATE DYNAMIC TABLE,
      CREATE EXTERNAL TABLE,
      CREATE MATERIALIZED VIEW,
      CREATE STAGE,
      CREATE FILE FORMAT,
      CREATE STREAM,
      CREATE TASK,
      CREATE PROCEDURE,
      CREATE FUNCTION,
      CREATE SEQUENCE,
      CREATE PIPE,
      CREATE SEMANTIC VIEW,
      CREATE AGENT,
      CREATE TAG,
      CREATE MASKING POLICY,
      CREATE ROW ACCESS POLICY
    ON FUTURE SCHEMAS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES
    ON ALL TABLES IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES
    ON FUTURE TABLES IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, REFERENCES ON ALL    VIEWS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, REFERENCES ON FUTURE VIEWS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, OPERATE ON ALL    DYNAMIC TABLES IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, OPERATE ON FUTURE DYNAMIC TABLES IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, REFERENCES ON ALL    MATERIALIZED VIEWS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT SELECT, REFERENCES ON FUTURE MATERIALIZED VIEWS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};

GRANT OPERATE, MONITOR ON ALL    TASKS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};
GRANT OPERATE, MONITOR ON FUTURE TASKS IN DATABASE {{ db }} TO ROLE {{ rw_ar }};

{% endfor %}
{% endfor %}
