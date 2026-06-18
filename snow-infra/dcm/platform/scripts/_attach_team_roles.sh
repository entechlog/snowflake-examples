#!/usr/bin/env bash
# =============================================================================
# Grant each team's DCM role to its service user (post-step of platform deploy)
# =============================================================================
# Runs AFTER snow dcm deploy creates the team roles. By the time this runs,
# both the user (created by _ensure_team_users.sh pre-step) and the role
# (created by DCM apply) exist. Idempotent — re-running is a no-op.
#
# Kept out of the DCM project file so plan stays read-only (GRANT … TO USER
# requires the user to exist, which would force user creation into plan).
#
# Invoked by platform/scripts/02_deploy.sh — not meant to be called directly.
#
# Override the team list with TEAMS env var:
#   TEAMS="SALES MARKETING" ENV_CODE=DEV ./_attach_team_roles.sh
# =============================================================================
set -euo pipefail

: "${ENV_CODE:?ENV_CODE required (DEV/STG/PRD)}"
CONN="${SNOWFLAKE_CONNECTION:-dcm-platform-${ENV_CODE,,}}"
TEAMS="${TEAMS:-SALES}"

for team in $TEAMS; do
  TEAM_UPPER="${team^^}"
  ROLE="SVC_${TEAM_UPPER}_DCM_ROLE"
  USER="SVC_${TEAM_UPPER}_DCM_USER"
  echo "==> Granting ${ROLE} to ${USER}"
  snow sql --connection "$CONN" -q "
    GRANT ROLE ${ROLE} TO USER ${USER};
  "
done
