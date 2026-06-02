#!/usr/bin/env bash
# Deploy the PLATFORM layer for an env. Pass env + alias:
#   ./02_deploy.sh DEV "initial platform deploy"
set -euo pipefail
ENV_CODE="${1:-DEV}"
ALIAS="${2:-deploy-$(date +%Y%m%d-%H%M%S)}"
TARGET="DCM_PLATFORM_${ENV_CODE}"
CONN="${SNOWFLAKE_CONNECTION:-dcm-platform-${ENV_CODE,,}}"
cd "$(dirname "$0")/../dcm"
echo "==> Platform deploy: ${TARGET} | alias: ${ALIAS} | connection: ${CONN}"
snow dcm deploy --target "${TARGET}" --alias "${ALIAS}" --connection "${CONN}"
