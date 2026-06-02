-- =============================================================================
-- Service-Functional Roles (SVC_FRs) — per-tool, per-env service identities
-- =============================================================================
-- One SVC_FR per integration tool, per env. Same shape as FRs but for
-- headless service accounts (dbt, Kafka, Superset, etc.). Env-scoped so
-- credentials and access don't bleed across environments.
--
-- Service users themselves are created out-of-band (key-pair / OAuth);
-- this layer only manages the role + its AR memberships.
-- =============================================================================

{% for team in teams %}

DEFINE ROLE {{ svc_fr_name(team.name, 'DBT') }}
    COMMENT = '{{ team.name }} dbt service role ({{ env_code }})';
DEFINE ROLE {{ svc_fr_name(team.name, 'KAFKA') }}
    COMMENT = '{{ team.name }} Kafka Connect service role ({{ env_code }})';
DEFINE ROLE {{ svc_fr_name(team.name, 'SUPERSET') }}
    COMMENT = '{{ team.name }} Superset BI service role ({{ env_code }})';

GRANT ROLE {{ svc_fr_name(team.name, 'DBT') }}      TO ROLE SYSADMIN;
GRANT ROLE {{ svc_fr_name(team.name, 'KAFKA') }}    TO ROLE SYSADMIN;
GRANT ROLE {{ svc_fr_name(team.name, 'SUPERSET') }} TO ROLE SYSADMIN;

-- ─── AR memberships per tool ────────────────────────────────────────────────

{# dbt: reads RAW, writes PREP + DW (the workhorse) #}
GRANT ROLE {{ ar_name(team.name, 'RAW',  'RO') }} TO ROLE {{ svc_fr_name(team.name, 'DBT') }};
GRANT ROLE {{ ar_name(team.name, 'PREP', 'RW') }} TO ROLE {{ svc_fr_name(team.name, 'DBT') }};
GRANT ROLE {{ ar_name(team.name, 'DW',   'RW') }} TO ROLE {{ svc_fr_name(team.name, 'DBT') }};

{# Kafka: writes only to RAW (lands events) #}
GRANT ROLE {{ ar_name(team.name, 'RAW', 'RW') }} TO ROLE {{ svc_fr_name(team.name, 'KAFKA') }};

{# Superset: reads only on DW (BI consumption) #}
GRANT ROLE {{ ar_name(team.name, 'DW', 'RO') }} TO ROLE {{ svc_fr_name(team.name, 'SUPERSET') }};

{% endfor %}
