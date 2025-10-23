#!/bin/bash
# Get current Cloudflare tunnel URL from logs

LOG_FILE="/Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/cloudflare/cloudflared.error.log"

echo "🔍 Checking Cloudflare tunnel logs..."
URL=$(tail -50 "$LOG_FILE" | grep -o 'https://[^[:space:]]*trycloudflare.com' | tail -1)

if [ -z "$URL" ]; then
    echo "❌ No tunnel URL found in logs"
    echo "   Make sure cloudflared is running: launchctl list | grep cloudflared"
    exit 1
fi

echo "✅ Current tunnel URL:"
echo ""
echo "   $URL"
echo ""
echo "📝 To update iOS app:"
echo "   1. Edit: src/Services/APIConfig.swift"
echo "   2. Line 10: static var tunnelURL = \"$URL\""
echo "   3. Rebuild app in Xcode (Cmd+R)"
echo ""

# Test connection
echo "🧪 Testing connection..."
STATUS=$(curl -s "$URL/api/status" -w "%{http_code}" -o /dev/null)

if [ "$STATUS" = "200" ]; then
    echo "✅ Tunnel is working! API accessible"
else
    echo "⚠️  Tunnel returned HTTP $STATUS (may still be initializing)"
fi
