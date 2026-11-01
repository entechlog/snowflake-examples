#!/usr/bin/env bash
# =============================================================================
# Sync canonical macros from shared/macros/ into every project's sources/macros/
# =============================================================================
# Run this any time you edit shared/macros/*.sql. CI also runs it before plan
# and deploy as a safety net so a stale copy never ships.
#
# Why this script exists: DCM requires macros to live INSIDE each project's
# sources/macros/ directory. With multiple projects (platform + per-team),
# that would mean N copies that drift. Keeping one canonical copy in shared/
# and syncing avoids the drift entirely.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DCM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED="$DCM_ROOT/shared/macros"

# Every DCM project that needs the macros — platform + each teams/<name>/dcm
TARGETS=("$DCM_ROOT/platform/dcm/sources/macros")
for team_dcm in "$DCM_ROOT"/teams/*/dcm; do
    [[ -f "$team_dcm/manifest.yml" ]] && TARGETS+=("$team_dcm/sources/macros")
done

if [[ ! -d "$SHARED" ]]; then
    echo "ERROR: $SHARED does not exist" >&2
    exit 1
fi

for dest in "${TARGETS[@]}"; do
    mkdir -p "$dest"
    for src in "$SHARED"/*.sql; do
        [[ -f "$src" ]] || continue
        cp "$src" "$dest/"
        echo "synced $(basename "$src") -> $dest/"
    done
done

echo "done."
