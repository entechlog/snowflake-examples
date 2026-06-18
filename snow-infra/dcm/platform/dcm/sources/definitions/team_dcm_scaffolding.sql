-- =============================================================================
-- Per-team perimeter — the declarative part of platform deploy
-- =============================================================================
-- Creates each team's DCM deployer role with scoped account-level privileges,
-- a dedicated DCM warehouse for their ops (cost attribution + isolation),
-- and the DCM_DB shell where their DCM PROJECT lives. Ownership of both the
-- DB and the WH is transferred to the team role.
--
-- This file intentionally does NOT reference the team USER. DCM doesn't
-- support USER as a declarable entity, and we keep plan strictly read-only.
-- User creation and role-to-user attachment are handled by sibling scripts:
--   platform/scripts/_ensure_team_users.sh   (pre-step of deploy)
--   platform/scripts/_attach_team_roles.sh   (post-step of deploy)
--
-- The team role intentionally has no MANAGE GRANTS. Team owns the DBs/WHs
-- it creates, and object owners can grant on what they own without it.
-- =============================================================================

{% for team in teams %}

-- 1. Team DCM deployer role (account-level, spans envs — one per team)
{% if deploy_account_user_roles %}
DEFINE ROLE {{ team_dcm_role(team.name) }}
    COMMENT = '{{ team.name }} DCM deployer (creates and owns team objects)';

GRANT ROLE {{ team_dcm_role(team.name) }} TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT ROLE {{ team_dcm_role(team.name) }} TO ROLE SYSADMIN;

-- Scoped account-level privileges (no MANAGE GRANTS — owner-grants suffice)
GRANT CREATE DATABASE  ON ACCOUNT TO ROLE {{ team_dcm_role(team.name) }};
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE {{ team_dcm_role(team.name) }};
GRANT CREATE ROLE      ON ACCOUNT TO ROLE {{ team_dcm_role(team.name) }};
{% endif %}

-- 2. Team-scoped DCM warehouse (cross-env — declared once, in DEV target only)
{% if deploy_account_user_roles %}
DEFINE WAREHOUSE SVC_{{ team.name | upper }}_DCM_WH_XS
    WAREHOUSE_SIZE      = 'XSMALL'
    AUTO_SUSPEND        = 30
    AUTO_RESUME         = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = '{{ team.name }} DCM ops warehouse';

GRANT OWNERSHIP ON WAREHOUSE SVC_{{ team.name | upper }}_DCM_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};
{% endif %}

-- 3. Team DCM DB shell — created and owned by platform first, then transferred
DEFINE DATABASE {{ db_name(team.name, 'DCM') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team.name }} DCM state ({{ env_code }})';

GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'DCM') }}
    TO ROLE {{ team_dcm_role(team.name) }};

{% endfor %}
