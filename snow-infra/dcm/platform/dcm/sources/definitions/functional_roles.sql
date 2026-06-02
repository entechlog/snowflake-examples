-- =============================================================================
-- Functional Roles (FRs) — per-team job functions, account-level (no env)
-- =============================================================================
-- FRs are the grant target for human users. They compose Access Roles
-- (DBLAYER_RO_AR / DBLAYER_RW_AR) per environment. The same FR spans all
-- envs — env-specific access shifts via the ARs granted in each env target.
--
-- The FR objects themselves are created only in the DEV platform target
-- (deploy_account_user_roles flag) because they're account-level. STG/PRD
-- platform targets only ADD grants of their env's ARs to the FR.
-- =============================================================================

{% for team in teams %}

{# Define roles once, in DEV target only #}
{% if deploy_account_user_roles %}
DEFINE ROLE {{ fr_name(team.name, 'DE') }}
    COMMENT = '{{ team.name }} — Data Engineers (write in DEV, read elsewhere)';
DEFINE ROLE {{ fr_name(team.name, 'DA') }}
    COMMENT = '{{ team.name }} — Data Analysts (read on DW)';
DEFINE ROLE {{ fr_name(team.name, 'CORTEX') }}
    COMMENT = '{{ team.name }} — Cortex Analyst consumers (read on RAW + DW)';
DEFINE ROLE {{ fr_name(team.name, 'PIPE_ADMIN') }}
    COMMENT = '{{ team.name }} — Snowpipe administrators (write on RAW)';

-- Roll up under SYSADMIN — required so SYSADMIN can manage objects these FRs touch
GRANT ROLE {{ fr_name(team.name, 'DE') }}         TO ROLE SYSADMIN;
GRANT ROLE {{ fr_name(team.name, 'DA') }}         TO ROLE SYSADMIN;
GRANT ROLE {{ fr_name(team.name, 'CORTEX') }}     TO ROLE SYSADMIN;
GRANT ROLE {{ fr_name(team.name, 'PIPE_ADMIN') }} TO ROLE SYSADMIN;
{% endif %}

-- ─── Grant env-scoped ARs to the FRs (runs in every env target) ──────────────

{# DE: write everywhere in DEV target; read in STG/PRD targets #}
{% if env_code | upper == 'DEV' %}
GRANT ROLE {{ ar_name(team.name, 'RAW',  'RW') }} TO ROLE {{ fr_name(team.name, 'DE') }};
GRANT ROLE {{ ar_name(team.name, 'PREP', 'RW') }} TO ROLE {{ fr_name(team.name, 'DE') }};
GRANT ROLE {{ ar_name(team.name, 'DW',   'RW') }} TO ROLE {{ fr_name(team.name, 'DE') }};
{% else %}
GRANT ROLE {{ ar_name(team.name, 'RAW',  'RO') }} TO ROLE {{ fr_name(team.name, 'DE') }};
GRANT ROLE {{ ar_name(team.name, 'PREP', 'RO') }} TO ROLE {{ fr_name(team.name, 'DE') }};
GRANT ROLE {{ ar_name(team.name, 'DW',   'RO') }} TO ROLE {{ fr_name(team.name, 'DE') }};
{% endif %}

{# DA: read-only on DW only #}
GRANT ROLE {{ ar_name(team.name, 'DW', 'RO') }} TO ROLE {{ fr_name(team.name, 'DA') }};

{# CORTEX: read on RAW (SEED context) and DW (OBT + SEMANTIC) #}
GRANT ROLE {{ ar_name(team.name, 'RAW', 'RO') }} TO ROLE {{ fr_name(team.name, 'CORTEX') }};
GRANT ROLE {{ ar_name(team.name, 'DW',  'RO') }} TO ROLE {{ fr_name(team.name, 'CORTEX') }};

{# PIPE_ADMIN: write on RAW (stages, pipes, streams) #}
GRANT ROLE {{ ar_name(team.name, 'RAW', 'RW') }} TO ROLE {{ fr_name(team.name, 'PIPE_ADMIN') }};

{% endfor %}
