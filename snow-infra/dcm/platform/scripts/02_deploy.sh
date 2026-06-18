#!/usr/bin/env bash
# Deploy the PLATFORM layer for an env. Pass env + alias:
#   ./02_deploy.sh DEV "initial platform deploy"
set -euo pipefail
ENV_CODE="${1:-DEV}"
ALIAS="${2:-deploy-$(date +%Y%m%d-%H%M%S)}"
TARGET="DCM_PLATFORM_${ENV_CODE}"
CONN="${SNOWFLAKE_CONNECTION:-dcm-platform-${ENV_CODE,,}}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/../../scripts/sync_macros.sh"

# Pre-step: ensure each team's service USER exists (DCM doesn't support USER).
# Runs only on deploy, not plan — keeps plan strictly read-only.
ENV_CODE="${ENV_CODE}" SNOWFLAKE_CONNECTION="${CONN}" \
    "$SCRIPT_DIR/_ensure_team_users.sh"

cd "$SCRIPT_DIR/../dcm"
echo "==> Platform deploy: ${TARGET} | alias: ${ALIAS} | connection: ${CONN}"
snow dcm deploy --target "${TARGET}" --alias "${ALIAS}" --connection "${CONN}"

# Post-step: attach team roles (created by DCM apply) to team users
# (created by the pre-step). GRANT … TO USER lives outside DCM so plan
# doesn't need to reference the user.
ENV_CODE="${ENV_CODE}" SNOWFLAKE_CONNECTION="${CONN}" \
    "$SCRIPT_DIR/_attach_team_roles.sh"
