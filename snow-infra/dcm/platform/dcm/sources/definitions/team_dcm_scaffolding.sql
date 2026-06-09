-- =============================================================================
-- Per-team DCM scaffolding
-- =============================================================================
-- Creates the team's DCM deployer role, transfers DB ownership to it, and
-- attaches the team's service user.
--
-- The team's DCM PROJECT object itself is created out-of-band — DCM can't
-- declare a DCM PROJECT inside another DCM project. See the README
-- "Create team DCM project" step.
-- =============================================================================

{% for team in teams %}

{% if deploy_account_user_roles %}
DEFINE ROLE {{ team_dcm_role(team.name) }}
    COMMENT = '{{ team.name }} DCM deployer (owns the team DBs)';

GRANT ROLE {{ team_dcm_role(team.name) }} TO ROLE SVC_PLATFORM_DCM_ROLE;
GRANT ROLE {{ team_dcm_role(team.name) }} TO ROLE SYSADMIN;
{% endif %}

GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'RAW') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'PREP') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'DW') }}
    TO ROLE {{ team_dcm_role(team.name) }};
GRANT OWNERSHIP ON DATABASE {{ db_name(team.name, 'DCM') }}
    TO ROLE {{ team_dcm_role(team.name) }};

GRANT USAGE ON WAREHOUSE SVC_PLATFORM_DCM_WH_XS
    TO ROLE {{ team_dcm_role(team.name) }};

GRANT ROLE {{ team_dcm_role(team.name) }} TO USER {{ team_dcm_user(team.name) }};

{% endfor %}
