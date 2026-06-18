-- =============================================================================
-- Team-owned databases (RAW / PREP / DW)
-- =============================================================================
-- Team creates and owns these. Platform only creates the {ENV}_SALES_DCM_DB
-- (where this DCM project lives) and grants CREATE DATABASE to the team role.
-- The team layer takes it from here.
-- =============================================================================

DEFINE DATABASE {{ db_name(team_name, 'RAW') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team_name }} — source/landing layer ({{ env_code }})';

DEFINE DATABASE {{ db_name(team_name, 'PREP') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team_name }} — staging/standardization layer ({{ env_code }})';

DEFINE DATABASE {{ db_name(team_name, 'DW') }}
    DATA_RETENTION_TIME_IN_DAYS = {{ data_retention_days }}
    COMMENT = '{{ team_name }} — consumption/DW layer ({{ env_code }})';
