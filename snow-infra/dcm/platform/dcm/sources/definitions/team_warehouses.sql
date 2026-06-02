-- =============================================================================
-- Per-team warehouses (created by platform, used by FRs/SVC_FRs)
-- =============================================================================
-- Platform creates the warehouses, grants USAGE to the appropriate FRs and
-- SVC_FRs, then transfers OWNERSHIP to the team's DCM role for future
-- ALTERs (resize, change auto-suspend, etc.).
--
-- ENABLE_QUERY_ACCELERATION set explicitly to avoid drift from
-- account-level defaults.
-- =============================================================================

{% for team in teams %}

-- ─── dbt warehouse (transformations) ────────────────────────────────────────
DEFINE WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_DBT_WH_XS
    WAREHOUSE_SIZE                      = 'XSMALL'
    AUTO_SUSPEND                        = 30
    AUTO_RESUME                         = TRUE
    INITIALLY_SUSPENDED                 = TRUE
    ENABLE_QUERY_ACCELERATION           = FALSE
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 8
    COMMENT                             = '{{ team.name }} dbt transformations ({{ env_code }})';

GRANT USAGE, MONITOR ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_DBT_WH_XS
    TO ROLE {{ svc_fr_name(team.name, 'DBT') }};
GRANT USAGE          ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_DBT_WH_XS
    TO ROLE {{ svc_fr_name(team.name, 'KAFKA') }};
GRANT USAGE          ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_DBT_WH_XS
    TO ROLE {{ svc_fr_name(team.name, 'SUPERSET') }};

-- ─── Cortex Analyst warehouse ───────────────────────────────────────────────
DEFINE WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_CORTEX_WH_XS
    WAREHOUSE_SIZE                      = 'XSMALL'
    AUTO_SUSPEND                        = 30
    AUTO_RESUME                         = TRUE
    INITIALLY_SUSPENDED                 = TRUE
    ENABLE_QUERY_ACCELERATION           = FALSE
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 8
    COMMENT                             = '{{ team.name }} Cortex Analyst agent execution ({{ env_code }})';

GRANT USAGE ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_CORTEX_WH_XS
    TO ROLE {{ svc_fr_name(team.name, 'DBT') }};

-- ─── Ad-hoc query warehouse (shared across envs, DEV target manages) ────────
{% if deploy_account_user_roles %}
DEFINE WAREHOUSE ALL_{{ team.name | upper }}_QUERY_WH_XS
    WAREHOUSE_SIZE                      = 'XSMALL'
    AUTO_SUSPEND                        = 30
    AUTO_RESUME                         = TRUE
    INITIALLY_SUSPENDED                 = TRUE
    ENABLE_QUERY_ACCELERATION           = FALSE
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 8
    COMMENT                             = '{{ team.name }} ad-hoc analyst queries (shared across envs)';

GRANT OWNERSHIP ON WAREHOUSE ALL_{{ team.name | upper }}_QUERY_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};
{% endif %}

-- Grant query-WH USAGE to user FRs — runs in every env target so all envs
-- have access (the WH itself is shared, defined only in DEV target).
GRANT USAGE ON WAREHOUSE ALL_{{ team.name | upper }}_QUERY_WH_XS
    TO ROLE {{ fr_name(team.name, 'DA') }};
GRANT USAGE ON WAREHOUSE ALL_{{ team.name | upper }}_QUERY_WH_XS
    TO ROLE {{ fr_name(team.name, 'DE') }};

-- ─── Cortex WH usage to CORTEX FR ───────────────────────────────────────────
GRANT USAGE ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_CORTEX_WH_XS
    TO ROLE {{ fr_name(team.name, 'CORTEX') }};

-- ─── Transfer team-scoped WH ownership to the team's DCM role ───────────────
GRANT OWNERSHIP ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_DBT_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON WAREHOUSE {{ env_code | upper }}_{{ team.name | upper }}_CORTEX_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};

{% endfor %}
