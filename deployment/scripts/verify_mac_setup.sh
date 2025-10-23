#!/bin/bash
# Mac Setup Verification Script
# Run this before deploying the Rathole tunnel

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Mac Setup Verification for Rathole Tunnel           ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check() {
    local name="$1"
    local command="$2"

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

warn() {
    local name="$1"
    local command="$2"

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════════"
echo "PREREQUISITES"
echo "═══════════════════════════════════════════════════════════"

# Check SSH key
if [ -f ~/.ssh/id_rsa.pub ]; then
    echo -e "${GREEN}✓${NC} SSH public key exists (~/.ssh/id_rsa.pub)"
    echo "  📋 Your public key (needed for Oracle Cloud):"
    echo "  ───────────────────────────────────────────"
    cat ~/.ssh/id_rsa.pub | head -c 60
    echo "..."
    echo ""
else
    echo -e "${RED}✗${NC} SSH public key not found"
    echo "  Generate with: ssh-keygen -t rsa -b 4096"
    ERRORS=$((ERRORS + 1))
fi

# Check for required commands
check "curl installed" "command -v curl"
check "openssl installed" "command -v openssl"
check "launchctl available" "command -v launchctl"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "BUILDEROS API STATUS"
echo "═══════════════════════════════════════════════════════════"

if curl -s -f -m 2 http://localhost:8080/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} BuilderOS API is running on localhost:8080"
    RESPONSE=$(curl -s http://localhost:8080/health)
    echo "  Response: $RESPONSE"
elif lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Port 8080 is in use but not responding to /health"
    echo "  Check what's running: lsof -i :8080"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${YELLOW}⚠${NC} BuilderOS API not running on localhost:8080"
    echo "  Start it before deploying tunnel"
    echo "  Command: cd /Users/Ty/BuilderOS/api && ./start_api.sh"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "DEPLOYMENT FILES"
echo "═══════════════════════════════════════════════════════════"

CAPSULE_DIR="/Users/Ty/BuilderOS/capsules/builder-system-mobile"

# Check deployment files
if [ -f "$CAPSULE_DIR/deployment/rathole/server/server.toml" ]; then
    echo -e "${GREEN}✓${NC} Server config exists"
else
    echo -e "${RED}✗${NC} Server config missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -x "$CAPSULE_DIR/deployment/rathole/server/deploy.sh" ]; then
    echo -e "${GREEN}✓${NC} Server deployment script exists and is executable"
else
    echo -e "${RED}✗${NC} Server deployment script missing or not executable"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "$CAPSULE_DIR/deployment/rathole/client/client.toml.template" ]; then
    echo -e "${GREEN}✓${NC} Client config template exists"
else
    echo -e "${RED}✗${NC} Client config template missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -x "$CAPSULE_DIR/deployment/rathole/client/install.sh" ]; then
    echo -e "${GREEN}✓${NC} Client installation script exists and is executable"
else
    echo -e "${RED}✗${NC} Client installation script missing or not executable"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "$CAPSULE_DIR/deployment/CREDENTIALS.md" ]; then
    echo -e "${GREEN}✓${NC} Credentials file exists"
    PERMS=$(stat -f %Lp "$CAPSULE_DIR/deployment/CREDENTIALS.md")
    if [ "$PERMS" = "600" ]; then
        echo -e "${GREEN}✓${NC} Credentials file has correct permissions (600)"
    else
        echo -e "${YELLOW}⚠${NC} Credentials file permissions are $PERMS (should be 600)"
        echo "  Fix with: chmod 600 $CAPSULE_DIR/deployment/CREDENTIALS.md"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} Credentials file missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "NETWORK & VPN"
echo "═══════════════════════════════════════════════════════════"

# Check internet connectivity
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Internet connectivity"
else
    echo -e "${RED}✗${NC} No internet connectivity"
    ERRORS=$((ERRORS + 1))
fi

# Check if Proton VPN is running (look for common VPN process names)
if pgrep -x "ProtonVPN" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Proton VPN is running"
elif ps aux | grep -i "proton" | grep -v grep > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Proton VPN appears to be running"
else
    echo -e "${YELLOW}⚠${NC} Proton VPN may not be running"
    echo "  The tunnel will work with or without VPN"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "DISK SPACE"
echo "═══════════════════════════════════════════════════════════"

AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')
echo "  Available space on /: $AVAILABLE"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "EXISTING RATHOLE INSTALLATION"
echo "═══════════════════════════════════════════════════════════"

if [ -f "/usr/local/bin/rathole" ]; then
    echo -e "${YELLOW}⚠${NC} Rathole already installed at /usr/local/bin/rathole"
    VERSION=$(/usr/local/bin/rathole --version 2>&1 || echo "unknown")
    echo "  Version: $VERSION"
    echo "  This will be overwritten if you run install.sh"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} No existing Rathole installation (clean slate)"
fi

if [ -f "/usr/local/etc/rathole/client.toml" ]; then
    echo -e "${YELLOW}⚠${NC} Rathole client config already exists"
    echo "  Location: /usr/local/etc/rathole/client.toml"
    echo "  This will be overwritten if you run install.sh"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} No existing Rathole config"
fi

if [ -f "/Library/LaunchDaemons/com.rathole.client.plist" ]; then
    echo -e "${YELLOW}⚠${NC} Rathole LaunchDaemon already exists"
    if sudo launchctl list | grep -q com.rathole.client; then
        echo -e "${YELLOW}  Service is currently running${NC}"
    else
        echo "  Service is not running"
    fi
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} No existing Rathole LaunchDaemon"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "SUMMARY"
echo "═══════════════════════════════════════════════════════════"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Mac is ready for Rathole tunnel deployment.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Create Oracle Cloud account (if not already done)"
    echo "  2. Deploy server: cd deployment/rathole/server"
    echo "  3. Run: ./install.sh YOUR_ORACLE_IP"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup complete with $WARNINGS warning(s)${NC}"
    echo ""
    echo "You can proceed, but review the warnings above."
    exit 0
else
    echo -e "${RED}✗ Setup incomplete: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Fix the errors above before proceeding."
    exit 1
fi
