#!/usr/bin/env bash
# =============================================================================
# Generate an RSA key pair for SVC_SALES_DCM_USER (or any service user)
# =============================================================================
# Idempotent:
#   - If the key file already exists, skip generation and reprint the ALTER USER
#     (so you can re-register the existing key if needed).
#   - Pass --force to overwrite the existing key (you'll need to re-register).
#   - Pass --register-via <conn> to auto-run the ALTER USER via snow CLI
#     instead of just printing it.
#
# Run inside the snow-tools container:
#   ./teams/sales/bootstrap/00_generate_rsa_key.sh
#   ./teams/sales/bootstrap/00_generate_rsa_key.sh --register-via dcm-platform-dev
#   ./teams/sales/bootstrap/00_generate_rsa_key.sh --force --register-via dcm-platform-dev
#
# Defaults (override via env vars):
#   KEY_DIR              $SNOWFLAKE_HOME/keys
#   KEY_NAME             svc_sales_dcm
#   SF_USER              SVC_SALES_DCM_USER
#   ENCRYPT_PASSPHRASE   unset = unencrypted PKCS8 (recommended for service accts)
# =============================================================================
set -euo pipefail

KEY_DIR="${KEY_DIR:-${SNOWFLAKE_HOME:-$HOME/.snowflake}/keys}"
KEY_NAME="${KEY_NAME:-svc_sales_dcm}"
SF_USER="${SF_USER:-SVC_SALES_DCM_USER}"
ENCRYPT_PASSPHRASE="${ENCRYPT_PASSPHRASE:-}"
FORCE="false"
REGISTER_CONN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)         FORCE="true"; shift ;;
        --register-via)  REGISTER_CONN="$2"; shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

OUT_FILE="$(mktemp)"
trap 'rm -f "$OUT_FILE"' EXIT

python - "$KEY_DIR" "$KEY_NAME" "$SF_USER" "$ENCRYPT_PASSPHRASE" "$FORCE" "$OUT_FILE" <<'PY'
import os, sys
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization

key_dir, key_name, sf_user, passphrase, force, out_file = sys.argv[1:7]
force = force == "true"

os.makedirs(key_dir, exist_ok=True)
try: os.chmod(key_dir, 0o700)
except PermissionError: pass

priv_path = os.path.join(key_dir, key_name + ".p8")
pub_path  = os.path.join(key_dir, key_name + ".pub")
existed = os.path.exists(priv_path)

if existed and not force:
    print(f"==> {priv_path} already exists — skipping generation.")
    print(f"    Pass --force to regenerate (you'll need to re-register the new public key).")
    with open(pub_path) as f:
        pub_text = f.read()
else:
    if existed:
        print(f"==> --force given; overwriting {priv_path}")
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    enc = serialization.BestAvailableEncryption(passphrase.encode()) if passphrase else serialization.NoEncryption()
    priv_bytes = key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, enc)
    pub_bytes  = key.public_key().public_bytes(serialization.Encoding.PEM, serialization.PublicFormat.SubjectPublicKeyInfo)
    with open(priv_path, "wb") as f: f.write(priv_bytes)
    try: os.chmod(priv_path, 0o600)
    except PermissionError: pass
    with open(pub_path, "wb") as f: f.write(pub_bytes)
    pub_text = pub_bytes.decode()
    print(f"==> Wrote {priv_path}")
    print(f"==> Wrote {pub_path}")

pub_body = "".join(l for l in pub_text.splitlines() if not l.startswith("-----"))
with open(out_file, "w") as f:
    f.write(pub_body)

print()
print(f"User:       {sf_user}")
print(f"Private:    {priv_path}")
print(f"Public:     {pub_path}")
PY

PUB_BODY="$(cat "$OUT_FILE")"

if [[ -n "$REGISTER_CONN" ]]; then
    echo "==> Registering public key on ${SF_USER} via connection ${REGISTER_CONN}"
    snow sql --connection "$REGISTER_CONN" -q \
        "ALTER USER ${SF_USER} SET RSA_PUBLIC_KEY = '${PUB_BODY}';"
    echo "==> Key registered. Verify with: snow sql --connection ${REGISTER_CONN} -q \"DESC USER ${SF_USER};\""
else
    echo
    echo "To register (or re-register) the key, paste in Snowsight as ACCOUNTADMIN"
    echo "(or re-run this script with --register-via <connection>):"
    echo
    echo "ALTER USER ${SF_USER} SET RSA_PUBLIC_KEY = '${PUB_BODY}';"
    echo
fi
