#!/usr/bin/env bash
# =============================================================================
# Deploy — apply changes to an environment
# =============================================================================
# Usage:
#   ./02_deploy.sh                       # defaults to DCM_DEV, alias = deploy-<timestamp>
#   ./02_deploy.sh DCM_STG "stg release 2026-06-01"
#   ./02_deploy.sh DCM_PRD "prd release v1.2.0"
#
# Run inside the snow-tools container. Requires SNOWFLAKE_HOME + a connection
# named "dcm-<env>" (or override with SNOWFLAKE_CONNECTION).
#
# The alias is recorded in the DCM project history — make it meaningful.
# Post-deploy post_scripts/*.sql do NOT run from this wrapper; either run
# them via `snow sql -f` afterwards, or use the official Snowflake-Labs
# dcm-deploy GitHub Action which auto-runs the post-scripts directory.
# =============================================================================
set -euo pipefail

TARGET="${1:-DCM_DEV}"
ALIAS="${2:-deploy-$(date +%Y%m%d-%H%M%S)}"
CONN="${SNOWFLAKE_CONNECTION:-dcm-${TARGET#DCM_}}"
CONN="${CONN,,}"

cd "$(dirname "$0")/../dcm"

echo "==> Deploying target: ${TARGET}"
echo "==> Alias: ${ALIAS}"
echo "==> Connection: ${CONN}"

snow dcm deploy \
    --target "${TARGET}" \
    --alias "${ALIAS}" \
    --connection "${CONN}"

echo ""
echo "==> Deployment recorded. Review history:"
echo "    snow dcm list-deployments ${TARGET#DCM_}_SALES_PREP_DB.DCM.INFRA --connection ${CONN}"
