#!/usr/bin/env bash
# Plan the PLATFORM layer for an env.
#   ./01_plan.sh        # defaults to DEV
#   ./01_plan.sh STG
#   ./01_plan.sh PRD
set -euo pipefail
ENV_CODE="${1:-DEV}"
TARGET="DCM_PLATFORM_${ENV_CODE}"
CONN="${SNOWFLAKE_CONNECTION:-dcm-platform-${ENV_CODE,,}}"
cd "$(dirname "$0")/../dcm"
echo "==> Platform plan: ${TARGET} (connection: ${CONN})"
snow dcm plan --target "${TARGET}" --connection "${CONN}" --save-output
echo "==> Plan saved to ./out/plan.json"
