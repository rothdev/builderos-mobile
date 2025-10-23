#!/bin/bash
#
# Cloudflare Tunnel Setup for BuilderOS
# Interactive script to configure Cloudflare Tunnel for exposing localhost:8080
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
TUNNEL_CONFIG="$SCRIPT_DIR/tunnel-config.yml"
PLIST_TEMPLATE="$SCRIPT_DIR/com.builderos.cloudflared.plist"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCHAGENT_PLIST="$LAUNCHAGENT_DIR/com.builderos.cloudflared.plist"

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
echo -e "${BLUE}║   Cloudflare Tunnel Setup for BuilderOS API   ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo ""

# Step 1: Check if cloudflared is installed
log_info "Step 1: Checking if cloudflared is installed..."
if ! command -v cloudflared &> /dev/null; then
    log_warning "cloudflared is not installed."
    echo ""
    read -p "Would you like to install cloudflared via Homebrew? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing cloudflared via Homebrew..."
        brew install cloudflare/cloudflare/cloudflared
        log_success "cloudflared installed successfully"
    else
        log_error "cloudflared is required. Install it with: brew install cloudflare/cloudflare/cloudflared"
        exit 1
    fi
else
    log_success "cloudflared is already installed"
    cloudflared --version
fi

echo ""

# Step 2: Login to Cloudflare
log_info "Step 2: Authenticating with Cloudflare..."
log_warning "This will open a browser window for authentication."
echo ""
read -p "Press Enter to continue with authentication..."
echo ""

if cloudflared tunnel login; then
    log_success "Successfully authenticated with Cloudflare"
else
    log_error "Authentication failed. Please try again."
    exit 1
fi

echo ""

# Step 3: Create tunnel
log_info "Step 3: Creating Cloudflare Tunnel..."
echo ""
read -p "Enter a name for your tunnel (e.g., 'builderos-api'): " TUNNEL_NAME

if [ -z "$TUNNEL_NAME" ]; then
    log_error "Tunnel name cannot be empty"
    exit 1
fi

log_info "Creating tunnel: $TUNNEL_NAME"
TUNNEL_OUTPUT=$(cloudflared tunnel create "$TUNNEL_NAME" 2>&1)

if [ $? -eq 0 ]; then
    log_success "Tunnel created successfully"
    echo "$TUNNEL_OUTPUT"

    # Extract tunnel ID from output
    TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}' | head -1)

    if [ -z "$TUNNEL_ID" ]; then
        log_error "Could not extract tunnel ID. Please check the output above."
        exit 1
    fi

    log_success "Tunnel ID: $TUNNEL_ID"
else
    log_error "Failed to create tunnel. Error:"
    echo "$TUNNEL_OUTPUT"
    exit 1
fi

echo ""

# Step 4: Create DNS record
log_info "Step 4: Setting up DNS record..."
echo ""
log_warning "You need a domain or subdomain for your tunnel."
echo "Example: builderos-api.yourdomain.com"
echo ""
read -p "Enter your full domain/subdomain: " TUNNEL_HOSTNAME

if [ -z "$TUNNEL_HOSTNAME" ]; then
    log_error "Hostname cannot be empty"
    exit 1
fi

log_info "Creating DNS record for: $TUNNEL_HOSTNAME"
if cloudflared tunnel route dns "$TUNNEL_ID" "$TUNNEL_HOSTNAME"; then
    log_success "DNS record created successfully"
else
    log_warning "DNS record creation failed. You may need to create it manually in Cloudflare dashboard."
    log_info "Run: cloudflared tunnel route dns $TUNNEL_ID $TUNNEL_HOSTNAME"
fi

echo ""

# Step 5: Update configuration files
log_info "Step 5: Updating configuration files..."

# Update tunnel-config.yml
log_info "Updating tunnel-config.yml..."
sed -i.bak "s/TUNNEL_ID_PLACEHOLDER/$TUNNEL_ID/g" "$TUNNEL_CONFIG"
sed -i.bak "s/TUNNEL_HOSTNAME_PLACEHOLDER/$TUNNEL_HOSTNAME/g" "$TUNNEL_CONFIG"
rm -f "${TUNNEL_CONFIG}.bak"
log_success "tunnel-config.yml updated"

# Update LaunchAgent plist
log_info "Updating LaunchAgent plist..."
sed -i.bak "s/TUNNEL_ID_PLACEHOLDER/$TUNNEL_ID/g" "$PLIST_TEMPLATE"
rm -f "${PLIST_TEMPLATE}.bak"
log_success "LaunchAgent plist updated"

echo ""

# Step 6: Install LaunchAgent
log_info "Step 6: Installing LaunchAgent for auto-start..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCHAGENT_DIR"

# Copy plist to LaunchAgents
cp "$PLIST_TEMPLATE" "$LAUNCHAGENT_PLIST"
log_success "LaunchAgent installed to: $LAUNCHAGENT_PLIST"

# Load LaunchAgent
log_info "Loading LaunchAgent..."
launchctl unload "$LAUNCHAGENT_PLIST" 2>/dev/null || true
launchctl load "$LAUNCHAGENT_PLIST"
log_success "LaunchAgent loaded and will start on boot"

echo ""

# Step 7: Start tunnel now
log_info "Step 7: Starting tunnel..."
sleep 2  # Give LaunchAgent time to start

if launchctl list | grep -q "com.builderos.cloudflared"; then
    log_success "Tunnel is running!"
else
    log_warning "Tunnel may not have started. Check logs:"
    log_info "  Log file: $SCRIPT_DIR/cloudflared.log"
    log_info "  Error log: $SCRIPT_DIR/cloudflared.error.log"
fi

echo ""

# Step 8: Summary and next steps
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Setup Complete! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
log_success "Your BuilderOS API is now accessible at:"
echo ""
echo -e "  ${GREEN}https://$TUNNEL_HOSTNAME${NC}"
echo ""
log_info "Configuration Summary:"
echo "  • Tunnel ID: $TUNNEL_ID"
echo "  • Tunnel Name: $TUNNEL_NAME"
echo "  • Public URL: https://$TUNNEL_HOSTNAME"
echo "  • Local Service: http://localhost:8080"
echo "  • Config File: $TUNNEL_CONFIG"
echo "  • LaunchAgent: $LAUNCHAGENT_PLIST"
echo ""
log_info "Useful Commands:"
echo "  • Check tunnel status: launchctl list | grep cloudflared"
echo "  • View logs: tail -f $SCRIPT_DIR/cloudflared.log"
echo "  • Stop tunnel: launchctl unload $LAUNCHAGENT_PLIST"
echo "  • Start tunnel: launchctl load $LAUNCHAGENT_PLIST"
echo "  • Restart tunnel: launchctl kickstart -k gui/\$(id -u)/com.builderos.cloudflared"
echo ""
log_info "Next Steps:"
echo "  1. Ensure BuilderOS API is running on localhost:8080"
echo "  2. Test the connection: $SCRIPT_DIR/verify_tunnel.sh"
echo "  3. Update your iOS app with the public URL: https://$TUNNEL_HOSTNAME"
echo ""
log_warning "Important: Keep your API key secure!"
echo "  • The tunnel is now publicly accessible (but API key protected)"
echo "  • Store API key in iOS app's secure Keychain"
echo "  • Monitor access logs regularly"
echo ""

# Save configuration for verification script
cat > "$SCRIPT_DIR/.tunnel-info" <<EOF
TUNNEL_ID=$TUNNEL_ID
TUNNEL_NAME=$TUNNEL_NAME
TUNNEL_HOSTNAME=$TUNNEL_HOSTNAME
PUBLIC_URL=https://$TUNNEL_HOSTNAME
EOF

log_success "Setup complete!"
echo ""
