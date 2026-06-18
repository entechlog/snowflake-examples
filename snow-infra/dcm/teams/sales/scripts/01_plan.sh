#!/usr/bin/env bash
# =============================================================================
# Plan (dry-run) — preview changes for an environment
# =============================================================================
# Usage:
#   ./01_plan.sh                # defaults to DCM_DEV
#   ./01_plan.sh DCM_STG
#   ./01_plan.sh DCM_PRD
#
# Run inside the snow-tools container. Requires:
#   - Snow CLI v3.16.0+
#   - SNOWFLAKE_HOME pointing at a dir with config.toml that defines a
#     connection named "dcm-<env>" (or override with SNOWFLAKE_CONNECTION).
#
# Plan output is written to dcm/out/plan.json by --save-output.
# =============================================================================
set -euo pipefail

TARGET="${1:-DCM_SALES_DEV}"
# DCM_SALES_DEV -> dcm-sales-dev to match config.toml connection names
CONN="${SNOWFLAKE_CONNECTION:-dcm-${TARGET#DCM_}}"
CONN="${CONN,,}"
CONN="${CONN//_/-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/../../../scripts/sync_macros.sh"

cd "$SCRIPT_DIR/../dcm"

echo "==> Planning target: ${TARGET} (connection: ${CONN})"
snow dcm plan \
    --target "${TARGET}" \
    --connection "${CONN}" \
    --save-output

echo ""
echo "==> Plan saved to ./out/plan.json"
echo "==> Review with: jq '.changeset[] | {type, object_id: .object_id.fqn}' ./out/plan.json"
echo "==> Then deploy: ./scripts/02_deploy.sh ${TARGET} \"<alias>\""
