#!/usr/bin/env bash
# =============================================================================
# Idempotently CREATE USER for each team listed in the platform manifest.
# =============================================================================
# DCM doesn't support USER as a declarable entity (see Snowflake docs:
# https://docs.snowflake.com/en/user-guide/dcm-projects/dcm-projects-supported-entities)
# so this lives outside the DCM project and runs as a pre-step of platform
# deploy.
#
# Runs as SVC_PLATFORM_DCM_ROLE (which has CREATE USER ON ACCOUNT). The role
# owns the users it creates, so it can later issue role grants and key ALTERs
# against them without MANAGE GRANTS.
#
# Invoked by platform/scripts/02_deploy.sh — not meant to be called directly.
#
# Override the team list with TEAMS env var:
#   TEAMS="SALES MARKETING FINANCE" ENV_CODE=DEV ./_ensure_team_users.sh
# =============================================================================
set -euo pipefail

: "${ENV_CODE:?ENV_CODE required (DEV/STG/PRD)}"
CONN="${SNOWFLAKE_CONNECTION:-dcm-platform-${ENV_CODE,,}}"
TEAMS="${TEAMS:-SALES}"

for team in $TEAMS; do
  TEAM_UPPER="${team^^}"
  USER="SVC_${TEAM_UPPER}_DCM_USER"
  echo "==> Ensuring ${USER} exists"
  snow sql --connection "$CONN" -q "
    CREATE USER IF NOT EXISTS ${USER}
      TYPE    = SERVICE
      COMMENT = '${TEAM_UPPER} team DCM deployer';
  "
done
