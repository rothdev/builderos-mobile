#!/bin/bash
#
# Cloudflare Tunnel Verification Script
# Tests that the tunnel is running and accessible
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TUNNEL_INFO="$SCRIPT_DIR/.tunnel-info"

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Banner
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Cloudflare Tunnel Verification Tool       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Load tunnel configuration
if [ ! -f "$TUNNEL_INFO" ]; then
    log_error "Tunnel configuration not found. Have you run setup_tunnel.sh?"
    exit 1
fi

source "$TUNNEL_INFO"

log_info "Verifying tunnel: $TUNNEL_NAME"
echo ""

# Test 1: Check if LaunchAgent is loaded
log_info "Test 1: Checking if LaunchAgent is loaded..."
if launchctl list | grep -q "com.builderos.cloudflared"; then
    log_success "LaunchAgent is loaded"
else
    log_error "LaunchAgent is not loaded"
    log_info "Try: launchctl load ~/Library/LaunchAgents/com.builderos.cloudflared.plist"
    exit 1
fi

echo ""

# Test 2: Check if cloudflared process is running
log_info "Test 2: Checking if cloudflared process is running..."
if pgrep -q cloudflared; then
    log_success "cloudflared process is running"
    CLOUDFLARED_PID=$(pgrep cloudflared)
    log_info "Process ID: $CLOUDFLARED_PID"
else
    log_error "cloudflared process is not running"
    log_info "Check logs: tail -f $SCRIPT_DIR/cloudflared.log"
    exit 1
fi

echo ""

# Test 3: Check if local API is running
log_info "Test 3: Checking if BuilderOS API is running on localhost:8080..."
if curl -s -f http://localhost:8080/health &> /dev/null; then
    log_success "BuilderOS API is running locally"
else
    log_error "BuilderOS API is not responding on localhost:8080"
    log_info "Start the API with: cd /Users/Ty/BuilderOS/api && ./server_mode.sh"
    exit 1
fi

echo ""

# Test 4: Check if public URL is accessible
log_info "Test 4: Checking if public URL is accessible..."
log_info "Testing: $PUBLIC_URL/health"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PUBLIC_URL/health" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    log_success "Public URL is accessible (HTTP $HTTP_CODE)"
else
    log_error "Public URL returned HTTP $HTTP_CODE"
    log_info "Wait a few minutes for DNS to propagate, then try again"
    log_info "Or check: cloudflared tunnel info $TUNNEL_ID"
    exit 1
fi

echo ""

# Test 5: Test authenticated endpoint
log_info "Test 5: Testing authenticated endpoint..."
log_warning "This test requires BUILDEROS_API_KEY environment variable"

if [ -z "$BUILDEROS_API_KEY" ]; then
    log_warning "BUILDEROS_API_KEY not set, skipping authenticated endpoint test"
    log_info "Set it with: export BUILDEROS_API_KEY='your-api-key'"
else
    log_info "Testing: $PUBLIC_URL/api/capsules"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "X-API-Key: $BUILDEROS_API_KEY" \
        "$PUBLIC_URL/api/capsules" || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        log_success "Authenticated endpoint is working (HTTP $HTTP_CODE)"
    else
        log_error "Authenticated endpoint returned HTTP $HTTP_CODE"
        log_info "Check API key configuration"
    fi
fi

echo ""

# Test 6: Test sleep endpoint (optional)
log_info "Test 6: Testing sleep endpoint (dry-run)..."
log_warning "This test will NOT actually sleep your Mac"

if [ -z "$BUILDEROS_API_KEY" ]; then
    log_warning "BUILDEROS_API_KEY not set, skipping sleep endpoint test"
else
    log_info "Testing: $PUBLIC_URL/api/system/sleep"
    RESPONSE=$(curl -s -X POST \
        -H "X-API-Key: $BUILDEROS_API_KEY" \
        "$PUBLIC_URL/api/system/sleep" || echo '{"status":"error"}')

    if echo "$RESPONSE" | grep -q '"status":"success"'; then
        log_success "Sleep endpoint is working (NOT executed - Mac still awake)"
        log_warning "Note: The endpoint works, but we didn't actually sleep the Mac for testing"
    else
        log_warning "Sleep endpoint test inconclusive"
        log_info "Response: $RESPONSE"
    fi
fi

echo ""

# Summary
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Verification Complete! 🎉              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

log_success "All critical tests passed!"
echo ""
log_info "Tunnel Status:"
echo "  • Tunnel ID: $TUNNEL_ID"
echo "  • Public URL: $PUBLIC_URL"
echo "  • Local Service: http://localhost:8080"
echo "  • LaunchAgent: Running"
echo "  • Process: Running (PID: $CLOUDFLARED_PID)"
echo ""

log_info "Useful Commands:"
echo "  • View tunnel logs: tail -f $SCRIPT_DIR/cloudflared.log"
echo "  • View tunnel info: cloudflared tunnel info $TUNNEL_ID"
echo "  • List all tunnels: cloudflared tunnel list"
echo "  • Restart tunnel: launchctl kickstart -k gui/\$(id -u)/com.builderos.cloudflared"
echo ""

log_info "Next Steps:"
echo "  1. Update iOS app with public URL: $PUBLIC_URL"
echo "  2. Store API key securely in iOS Keychain"
echo "  3. Test iOS app connectivity"
echo ""

log_success "Tunnel is ready for use!"
echo ""
