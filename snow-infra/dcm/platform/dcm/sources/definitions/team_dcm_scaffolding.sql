-- =============================================================================
-- Per-team DCM scaffolding
-- =============================================================================
-- Creates the team's DCM deployer role, the DCM state schema inside their PREP
-- database, ownership transfers, and the user-to-role attachment.
--
-- DCM state schema lives in PREP_DB (the regenerable intermediate layer), NOT
-- in DW_DB. DW is the user-facing consumption layer; an accidental DCM purge
-- or ownership issue there would put end-user data at risk. PREP can be
-- rebuilt from RAW, so it's the safer home for the DCM PROJECT object.
--
-- The team's DCM PROJECT object itself is created out-of-band - DCM doesn't
-- support declaring a DCM PROJECT inside another DCM project. See the README
-- "Create team DCM project" step for the one-time snow CLI command.
--
-- With the AR/FR/SVC_FR pattern in place, the team DCM role no longer needs
-- MANAGE GRANTS on account - all bulk/future grants live on the platform-owned
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

-- 2. OWNERSHIP transfers — 3 DBs → team's DCM role
--    Team creates the DCM schema + DCM PROJECT out-of-band (see README
--    "Create team DCM project" step). Done out-of-band because:
--    (a) DCM can't declare a DCM PROJECT inside another DCM project, and
--    (b) the DCM schema, if platform-created, would conflict with PREP's
--        RW_AR FUTURE grants on schema ownership transfer.
--    Team owns PREP DB after transfer, so team can create the DCM schema
--    inside it cleanly (no FUTURE-grant conflict on a team-owned schema).
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'RAW') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'PREP') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'DW') }}
    TO ROLE {{ team_dcm_role(team.name) }};

-- 4. Platform-warehouse USAGE for the team's plan/deploy ops
GRANT USAGE ON WAREHOUSE SVC_PLATFORM_SNOW_DCM_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};

-- 5. Attach the team's pre-existing service user
--    (created out-of-band so its RSA key survives role reshuffles)
GRANT ROLE {{ team_dcm_role(team.name) }} TO USER {{ team_dcm_user(team.name) }};

{% endfor %}
