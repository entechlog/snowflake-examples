-- =============================================================================
-- Team databases (one triplet per team: RAW / PREP / DW)
-- =============================================================================
-- Platform creates EMPTY DB shells. The team's own DCM project (see
-- teams/<name>/dcm/) then creates schemas, tables, views inside.
--
-- DATA_RETENTION_TIME_IN_DAYS is set at the DB level — schemas/tables created
-- by the team inherit unless they override.
-- =============================================================================

{% for team in teams %}

DEFINE DATABASE {{ db_name(team.name, 'RAW') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team.name }} — source/landing layer ({{ env_code }})';

DEFINE DATABASE {{ db_name(team.name, 'PREP') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team.name }} — staging/standardization layer ({{ env_code }})';

DEFINE DATABASE {{ db_name(team.name, 'DW') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team.name }} — consumption/DW layer ({{ env_code }})';

DEFINE DATABASE {{ db_name(team.name, 'DCM') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team.name }} — DCM state ({{ env_code }})';

{% endfor %}
