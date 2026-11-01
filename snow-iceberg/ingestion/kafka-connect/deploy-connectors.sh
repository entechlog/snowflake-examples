#!/bin/bash
# =============================================================================
# Deploy Kafka Connect connectors
# =============================================================================

set -e

CONNECT_URL=${CONNECT_URL:-http://localhost:8083}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file
if [ -f "$SCRIPT_DIR/../../.env" ]; then
  echo "Loading environment from .env file..."
  export $(grep -v '^#' "$SCRIPT_DIR/../../.env" | xargs)
fi

# Validate required environment variables
if [ -z "$S3_BUCKET_NAME" ]; then
  echo "ERROR: S3_BUCKET_NAME is not set. Please set it in .env file."
  exit 1
fi

echo "Using S3_BUCKET_NAME: $S3_BUCKET_NAME"
echo "Using AWS_REGION: ${AWS_REGION:-us-east-1}"

echo ""
echo "Waiting for Kafka Connect to be ready..."
until curl -s -f "$CONNECT_URL/connectors" > /dev/null 2>&1; do
  echo "Kafka Connect not ready, waiting..."
  sleep 5
done
echo "Kafka Connect is ready!"

echo ""
echo "Deploying connectors..."

# Deploy datagen source
echo "Deploying datagen-customers..."
curl -s -X POST "$CONNECT_URL/connectors" \
  -H "Content-Type: application/json" \
  -d @"$SCRIPT_DIR/connectors/datagen-customers.json" | jq .

echo ""

# Deploy iceberg sink (with environment variable substitution)
echo "Deploying iceberg-sink-customers..."
envsubst < "$SCRIPT_DIR/connectors/iceberg-sink-customers.json" | \
  curl -s -X POST "$CONNECT_URL/connectors" \
    -H "Content-Type: application/json" \
    -d @- | jq .

echo ""
echo "Connectors deployed. Checking status..."
sleep 5

echo ""
echo "Connector list:"
curl -s "$CONNECT_URL/connectors" | jq .

echo ""
echo "Connector statuses:"
for connector in $(curl -s "$CONNECT_URL/connectors" | jq -r '.[]'); do
  echo "--- $connector ---"
  curl -s "$CONNECT_URL/connectors/$connector/status" | jq .
done

echo ""
echo "Done!"
