#!/usr/bin/env bash
# =============================================================================
# Deploy and manage Cortex Analyst semantic views and agents from YAML.
#
# Thin wrapper around deploy.py. All flags are passed through.
#
# Usage:
#   ./deploy.sh                                                    # Deploy all
#   ./deploy.sh --dry-run                                          # Print SQL
#   ./deploy.sh --pull                                             # Export → YAML
#   ./deploy.sh --status                                           # Local vs deployed
#   ./deploy.sh --views marketing_campaign_stats_1d                # Single view
#   ./deploy.sh --agents marketing_agent                           # Single agent
#   ./deploy.sh --views view1 view2 --agents agent1               # Multiple
#
# Required: ENV_CODE, PROJ_CODE, SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD
#
# Dependencies: pip install pyyaml snowflake-connector-python
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

python "${SCRIPT_DIR}/deploy.py" "$@"
