#!/usr/bin/env bash
# Generate a Mesh link token and print it to stdout for use in the Flutter example app.
# Requires MESH_CLIENT_ID, MESH_CLIENT_SECRET in .env.local at the repo root.
#
# Usage: ./scripts/get-link-token.sh [--network base|solana]
#   --network  Target network for the toAddress (default: base)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env.local"

# Parse arguments
NETWORK="base"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --network|-n)
      NETWORK="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 [--network base|solana]"
      exit 1
      ;;
  esac
done

# Network → address + networkId mapping
case "$NETWORK" in
  base)
    TO_ADDRESS="0xB56f4a0dE3D554E0e6BD30f9F190Ad4E21581c95"
    NETWORK_ID="aa883b03-120d-477c-a588-37c2afd3ca71"
    ;;
  solana)
    TO_ADDRESS="5rp8NpCgtQG87rFLV9e4ycEFE1ZHEUEdzeJebLChEcEX"
    NETWORK_ID="0291810a-5947-424d-9a59-e88bb33e999d"
    ;;
  *)
    echo "Error: Unknown network '$NETWORK'. Supported: base, solana"
    exit 1
    ;;
esac

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found."
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

MESH_API_URL="${MESH_API_URL:-https://integration-api.meshconnect.com}"
USER_ID="${MESH_TEST_USER_ID:-test-user-$(whoami)}"

echo "Network:   $NETWORK" >&2
echo "userId:    $USER_ID" >&2
echo "Generating link token..." >&2

RESPONSE=$(curl -s -X POST "$MESH_API_URL/api/v1/linktoken" \
  -H "Content-Type: application/json" \
  -H "X-Client-Id: $MESH_CLIENT_ID" \
  -H "X-Client-Secret: $MESH_CLIENT_SECRET" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"transferOptions\": {
      \"toAddresses\": [
        {
          \"symbol\": \"USDC\",
          \"address\": \"$TO_ADDRESS\",
          \"networkId\": \"$NETWORK_ID\"
        }
      ]
    }
  }")

LINK_TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content',{}).get('linkToken',''))" 2>/dev/null || true)

if [[ -z "$LINK_TOKEN" ]]; then
  echo "Error: Failed to get link token." >&2
  echo "API response: $RESPONSE" >&2
  exit 1
fi

echo "" >&2
echo "Link token:" >&2
echo "$LINK_TOKEN"
