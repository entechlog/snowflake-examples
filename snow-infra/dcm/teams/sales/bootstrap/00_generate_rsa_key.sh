#!/usr/bin/env bash
# =============================================================================
# Generate an RSA key pair for SVC_SALES_SNOW_DCM_USER (or any service user)
# =============================================================================
# Run this INSIDE the snow-tools container:
#
#   docker exec -it snow-tools bash
#   cd /C/Users/nadesansiva/VisualStudioCode/snowflake-examples/snow-infra/dcm
#   ./bootstrap/00_generate_rsa_key.sh
#
# Why a script (not raw openssl): the snow-tools image already ships the
# `cryptography` Python library (via snowflake-connector-python). Using Python
# avoids needing `openssl` in the base image and works identically across OSes.
#
# Output:
#   - <KEY_DIR>/<KEY_NAME>.p8   private key (chmod 600), referenced by snow CLI
#   - <KEY_DIR>/<KEY_NAME>.pub  public key
#   - prints an ALTER USER statement to paste into Snowsight as ACCOUNTADMIN
#
# Defaults (override via env vars):
#   KEY_DIR              ~/.snowflake/keys (ephemeral inside container)
#   KEY_NAME             svc_sales_dcm
#   SF_USER              SVC_SALES_SNOW_DCM_USER
#   ENCRYPT_PASSPHRASE   unset = unencrypted PKCS8 (recommended for service accts)
#
# For persistence across container rebuilds, point KEY_DIR at the mounted host
# path, e.g.:
#
#   KEY_DIR=/C/Users/nadesansiva/.snowflake/keys ./bootstrap/00_generate_rsa_key.sh
#
# =============================================================================
set -euo pipefail

KEY_DIR="${KEY_DIR:-$HOME/.snowflake/keys}"
KEY_NAME="${KEY_NAME:-svc_sales_dcm}"
SF_USER="${SF_USER:-SVC_SALES_SNOW_DCM_USER}"
ENCRYPT_PASSPHRASE="${ENCRYPT_PASSPHRASE:-}"

python - "$KEY_DIR" "$KEY_NAME" "$SF_USER" "$ENCRYPT_PASSPHRASE" <<'PY'
import os, sys, stat
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization

key_dir, key_name, sf_user, passphrase = sys.argv[1:5]

os.makedirs(key_dir, exist_ok=True)
try:
    os.chmod(key_dir, 0o700)
except PermissionError:
    pass  # bind-mounted host paths on Windows may not honor chmod

priv_path = os.path.join(key_dir, key_name + ".p8")
pub_path  = os.path.join(key_dir, key_name + ".pub")

if os.path.exists(priv_path):
    print(f"ERROR: {priv_path} already exists.", file=sys.stderr)
    print(f"       Move/delete it first, or set KEY_NAME=<other-name>.", file=sys.stderr)
    sys.exit(1)

# Generate the key
key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

# Private key — PKCS8 PEM
if passphrase:
    enc = serialization.BestAvailableEncryption(passphrase.encode())
else:
    enc = serialization.NoEncryption()

priv_bytes = key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=enc,
)

pub_bytes = key.public_key().public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
)

with open(priv_path, "wb") as f:
    f.write(priv_bytes)
try:
    os.chmod(priv_path, 0o600)
except PermissionError:
    pass

with open(pub_path, "wb") as f:
    f.write(pub_bytes)

# Strip BEGIN/END for the ALTER USER body
pub_body = "".join(
    line for line in pub_bytes.decode().splitlines()
    if not line.startswith("-----")
)

print()
print("=" * 70)
print("Keys generated")
print("=" * 70)
print(f"  Private (PKCS8 {'encrypted' if passphrase else 'unencrypted'}): {priv_path}")
print(f"  Public:                                                        {pub_path}")
print()
print("=" * 70)
print("STEP 1 — Run this in Snowsight as ACCOUNTADMIN")
print("=" * 70)
print()
print(f"USE ROLE ACCOUNTADMIN;")
print(f"ALTER USER {sf_user} SET RSA_PUBLIC_KEY = '{pub_body}';")
print()
print("=" * 70)
print("STEP 2 — Verify the fingerprint")
print("=" * 70)
print()
print(f"DESC USER {sf_user};")
print("    -- Look for the RSA_PUBLIC_KEY_FP property (SHA256:... value)")
print()
print("=" * 70)
print("STEP 3 — Snow CLI config (config.toml inside the container)")
print("=" * 70)
print()
print(f"  authenticator    = \"SNOWFLAKE_JWT\"")
print(f"  private_key_path = \"{priv_path}\"")
if passphrase:
    print(f"  private_key_passphrase = \"<set via SNOWFLAKE_PRIVATE_KEY_PASSPHRASE env var>\"")
print()
PY
