#!/usr/bin/env bash
# =============================================================================
# Generate RSA key pair for SVC_PLATFORM_SNOW_DCM_USER
# =============================================================================
# Identical to teams/sales/bootstrap/00_generate_rsa_key.sh but defaults to
# the PLATFORM user/key name. See that file for the full explanation.
#
# Run inside snow-tools container:
#   docker exec -it snow-tools bash -lc \
#     'cd /C/.../snow-infra/dcm && \
#      KEY_DIR=/C/Users/nadesansiva/.snowflake/keys ./platform/bootstrap/00_generate_platform_rsa_key.sh'
# =============================================================================
set -euo pipefail

KEY_DIR="${KEY_DIR:-$HOME/.snowflake/keys}"
KEY_NAME="${KEY_NAME:-svc_platform_dcm}"
SF_USER="${SF_USER:-SVC_PLATFORM_SNOW_DCM_USER}"
ENCRYPT_PASSPHRASE="${ENCRYPT_PASSPHRASE:-}"

python - "$KEY_DIR" "$KEY_NAME" "$SF_USER" "$ENCRYPT_PASSPHRASE" <<'PY'
import os, sys
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization

key_dir, key_name, sf_user, passphrase = sys.argv[1:5]
os.makedirs(key_dir, exist_ok=True)
priv_path = os.path.join(key_dir, key_name + ".p8")
pub_path  = os.path.join(key_dir, key_name + ".pub")
if os.path.exists(priv_path):
    print(f"ERROR: {priv_path} already exists.", file=sys.stderr); sys.exit(1)

key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
enc = serialization.BestAvailableEncryption(passphrase.encode()) if passphrase else serialization.NoEncryption()
priv_bytes = key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, enc)
pub_bytes = key.public_key().public_bytes(serialization.Encoding.PEM, serialization.PublicFormat.SubjectPublicKeyInfo)

with open(priv_path, "wb") as f: f.write(priv_bytes)
try: os.chmod(priv_path, 0o600)
except PermissionError: pass
with open(pub_path, "wb") as f: f.write(pub_bytes)

pub_body = "".join(l for l in pub_bytes.decode().splitlines() if not l.startswith("-----"))

print(); print("=" * 70); print("Keys generated"); print("=" * 70)
print(f"  Private: {priv_path}"); print(f"  Public:  {pub_path}")
print(); print("=" * 70); print("STEP 1 — Run in Snowsight as ACCOUNTADMIN"); print("=" * 70); print()
print("USE ROLE ACCOUNTADMIN;")
print(f"ALTER USER {sf_user} SET RSA_PUBLIC_KEY = '{pub_body}';")
print(); print("=" * 70); print("STEP 2 — Verify"); print("=" * 70); print()
print(f"DESC USER {sf_user};   -- expect RSA_PUBLIC_KEY_FP set")
print(); print("=" * 70); print("STEP 3 — Snow CLI config (config.toml)"); print("=" * 70); print()
print(f'  authenticator    = "SNOWFLAKE_JWT"')
print(f'  private_key_path = "{priv_path}"')
print()
PY
