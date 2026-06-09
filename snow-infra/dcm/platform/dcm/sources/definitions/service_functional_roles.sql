-- =============================================================================
-- Service-Functional Roles (SVC_FRs) — per-tool, per-env service identities
-- =============================================================================
-- One SVC_FR per integration tool, per env. Same shape as FRs but for
-- headless service accounts. Env-scoped so credentials and access don't
-- bleed across environments.
--
-- Service users themselves are created out-of-band (key-pair / OAuth);
-- this layer only manages the role + its AR memberships.
-- =============================================================================

{% for team in teams %}

DEFINE ROLE {{ svc_fr_name(team.name, 'DBT') }}
    COMMENT = '{{ team.name }} dbt service role ({{ env_code }})';

GRANT ROLE {{ svc_fr_name(team.name, 'DBT') }} TO ROLE SYSADMIN;

{# dbt: reads RAW, writes PREP + DW #}
GRANT ROLE {{ ar_name(team.name, 'RAW',  'RO') }} TO ROLE {{ svc_fr_name(team.name, 'DBT') }};
GRANT ROLE {{ ar_name(team.name, 'PREP', 'RW') }} TO ROLE {{ svc_fr_name(team.name, 'DBT') }};
GRANT ROLE {{ ar_name(team.name, 'DW',   'RW') }} TO ROLE {{ svc_fr_name(team.name, 'DBT') }};

{% endfor %}
