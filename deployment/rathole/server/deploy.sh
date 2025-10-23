#!/bin/bash
# Rathole Server Deployment Script
# Run this on Oracle Cloud VM after initial setup

set -e

echo "🚀 Starting Rathole Server Deployment..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
   echo "❌ Please do not run as root"
   exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt install -y curl unzip fail2ban ufw

# Download Rathole
echo "⬇️  Downloading Rathole..."
cd /tmp
RATHOLE_VERSION="v0.5.0"
wget -q https://github.com/rapiz1/rathole/releases/download/${RATHOLE_VERSION}/rathole-x86_64-unknown-linux-gnu.zip
unzip -q rathole-x86_64-unknown-linux-gnu.zip

# Install binary
echo "📥 Installing Rathole binary..."
sudo mv rathole /usr/local/bin/
sudo chmod +x /usr/local/bin/rathole
rm rathole-x86_64-unknown-linux-gnu.zip

# Verify installation
rathole --version

# Create config directory
echo "📁 Creating configuration directory..."
sudo mkdir -p /etc/rathole

# Copy configuration (assumes server.toml is in same directory)
if [ -f "server.toml" ]; then
    echo "📝 Installing configuration..."
    sudo cp server.toml /etc/rathole/server.toml
    sudo chmod 600 /etc/rathole/server.toml
else
    echo "⚠️  Warning: server.toml not found. Please create /etc/rathole/server.toml manually"
fi

# Create systemd service
echo "⚙️  Creating systemd service..."
sudo tee /etc/systemd/system/rathole-server.service > /dev/null <<EOF
[Unit]
Description=Rathole Tunnel Server
After=network.target

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/local/bin/rathole /etc/rathole/server.toml
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Configure firewall
echo "🔥 Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 2333/tcp comment 'Rathole control'
sudo ufw allow 8080/tcp comment 'BuilderOS API'
sudo ufw allow 2222/tcp comment 'SSH tunnel'
sudo ufw --force enable

# Disable password authentication for SSH
echo "🔒 Hardening SSH..."
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Enable automatic security updates
echo "🛡️  Enabling automatic security updates..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure fail2ban
echo "🛡️  Configuring fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Reload systemd
sudo systemctl daemon-reload

# Enable and start Rathole
echo "🚀 Starting Rathole server..."
sudo systemctl enable rathole-server
sudo systemctl start rathole-server

# Check status
sleep 2
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Service Status:"
sudo systemctl status rathole-server --no-pager

echo ""
echo "📝 View logs with: sudo journalctl -u rathole-server -f"
echo ""
echo "🔑 Your Oracle VM public IP: $(curl -s ifconfig.me)"
echo ""
echo "⚠️  IMPORTANT: Update the client configuration with your Oracle IP!"
