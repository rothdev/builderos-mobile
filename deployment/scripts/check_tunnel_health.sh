#!/bin/bash
# Tunnel Health Check Script
# Add to crontab: */5 * * * * ~/path/to/check_tunnel_health.sh >> ~/logs/tunnel-health.log 2>&1

ORACLE_IP="${ORACLE_IP:-PLACEHOLDER}"
API_ENDPOINT="http://$ORACLE_IP:8080/health"
LOG_FILE="${HOME}/logs/tunnel-health.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Check if tunnel is responding
if curl -s -f -m 10 "$API_ENDPOINT" > /dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ✅ Tunnel healthy (${ORACLE_IP}:8080)"
    exit 0
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') ❌ Tunnel down - attempting restart"

    # Try to restart the client
    sudo launchctl stop com.rathole.client
    sleep 2
    sudo launchctl start com.rathole.client

    # Wait and check again
    sleep 5
    if curl -s -f -m 10 "$API_ENDPOINT" > /dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') ✅ Tunnel recovered after restart"
        exit 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') ❌ Tunnel still down after restart - manual intervention needed"
        # Could add notification here (e.g., osascript display notification)
        exit 1
    fi
fi
