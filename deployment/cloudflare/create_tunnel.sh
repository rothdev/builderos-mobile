#!/bin/bash
set -e

# Load environment
source /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/cloudflare/.env

# Generate tunnel secret
SECRET=$(openssl rand -base64 32)

# Create tunnel via API
RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/cfd_tunnel" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"name\":\"builderos-mobile\",\"tunnel_secret\":\"${SECRET}\"}")

echo "$RESPONSE" | jq .

# Extract tunnel ID and save credentials
TUNNEL_ID=$(echo "$RESPONSE" | jq -r '.result.id')

if [ "$TUNNEL_ID" != "null" ] && [ -n "$TUNNEL_ID" ]; then
    echo ""
    echo "✅ Tunnel created successfully!"
    echo "Tunnel ID: $TUNNEL_ID"

    # Save credentials
    mkdir -p ~/.cloudflared
    echo "{\"AccountTag\":\"${CLOUDFLARE_ACCOUNT_ID}\",\"TunnelSecret\":\"${SECRET}\",\"TunnelID\":\"${TUNNEL_ID}\"}" > ~/.cloudflared/${TUNNEL_ID}.json
    chmod 600 ~/.cloudflared/${TUNNEL_ID}.json

    echo "✅ Credentials saved to ~/.cloudflared/${TUNNEL_ID}.json"
else
    echo "❌ Failed to create tunnel"
    exit 1
fi
