-- =============================================================================
-- Per-team DCM scaffolding
-- =============================================================================
-- Creates the team's DCM deployer role, the DCM state schema inside their DW
-- database, ownership transfers, and the user→role attachment.
--
-- The team's DCM PROJECT object itself is created out-of-band — DCM doesn't
-- support declaring a DCM PROJECT inside another DCM project. See the README
-- "Create team DCM project" step for the one-time snow CLI command.
--
-- With the AR/FR/SVC_FR pattern in place, the team DCM role no longer needs
-- MANAGE GRANTS on account — all bulk/future grants live on the platform-owned
-- ARs, never on the team role.
-- =============================================================================

{% for team in teams %}

-- 1. Team DCM deployer role (account-level, no env — one per team across envs)
{% if deploy_account_user_roles %}
DEFINE ROLE {{ team_dcm_role(team.name) }}
    COMMENT = '{{ team.name }} DCM deployer (owns the team DBs)';

GRANT ROLE {{ team_dcm_role(team.name) }} TO ROLE SVC_PLATFORM_SNOW_DCM_ROLE;
GRANT ROLE {{ team_dcm_role(team.name) }} TO ROLE SYSADMIN;
{% endif %}

-- 2. DCM state schema inside the team's DW DB
DEFINE SCHEMA {{ db_name(team.name, 'DW') }}.DCM
    COMMENT = '{{ team.name }} DCM state (holds the team DCM PROJECT object)';

-- 3. OWNERSHIP transfers — DBs + DCM schema → team's DCM role
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'RAW') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'PREP') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'DW') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON SCHEMA {{ db_name(team.name, 'DW') }}.DCM
    TO ROLE {{ team_dcm_role(team.name) }};

-- 4. Platform-warehouse USAGE for the team's plan/deploy ops
GRANT USAGE ON WAREHOUSE SVC_PLATFORM_SNOW_DCM_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};

-- 5. Attach the team's pre-existing service user
--    (created out-of-band so its RSA key survives role reshuffles)
GRANT ROLE {{ team_dcm_role(team.name) }} TO USER {{ team_dcm_user(team.name) }};

{% endfor %}
