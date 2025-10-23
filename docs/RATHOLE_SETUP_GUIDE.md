# Rathole Tunnel Setup Guide

Complete guide for setting up secure iOS-to-Mac communication using Oracle Cloud + Rathole tunnel.

## Overview

This setup creates a secure, zero-cost tunnel that allows your iOS app to access BuilderOS on your Mac from anywhere, even with Proton VPN running on both devices.

**Architecture:**
```
iOS App (Proton VPN active)
    ↓ HTTPS
Oracle Cloud VM (free forever)
    ↓ Encrypted Rathole tunnel
Mac (Proton VPN active)
    ↓ Local connections
BuilderOS API + SSH + other services
```

**Total Cost:** $0/month forever (Oracle Always Free Tier)

---

## Phase 1: Oracle Cloud Account Setup (30 min)

### Step 1: Create Oracle Cloud Account

1. Go to https://oracle.com/cloud/free
2. Click **"Start for free"**
3. Fill in account details:
   - Email address
   - Name and country
   - Verify email
4. Add payment method (required but NOT charged for Always Free)
5. Complete account verification

### Step 2: Launch ARM VM

1. Login to Oracle Cloud Console
2. Navigate to **Compute → Instances**
3. Click **"Create Instance"**
4. Configure:
   - **Name:** `builderos-tunnel`
   - **Image:** `Canonical Ubuntu 22.04`
   - **Shape:** Click "Change Shape"
     - Select `VM.Standard.A1.Flex` (ARM)
     - Set OCPUs: `1`
     - Set Memory: `6 GB`
   - **Network:** Use default VCN (auto-created)
   - **SSH Keys:** Upload your Mac's public key
     ```bash
     # On Mac, get your public key:
     cat ~/.ssh/id_rsa.pub
     # Copy and paste into Oracle Cloud console
     ```
5. Click **"Create"**
6. Wait 2-3 minutes for provisioning
7. **Note the Public IP address** (e.g., `129.213.45.123`)

### Step 3: Configure Firewall

1. Navigate to **Networking → Virtual Cloud Networks**
2. Click your default VCN
3. Click **Security Lists → Default Security List**
4. Click **"Add Ingress Rules"** and add these rules:

| Source CIDR | Protocol | Destination Port | Description |
|-------------|----------|------------------|-------------|
| 0.0.0.0/0 | TCP | 2333 | Rathole control |
| 0.0.0.0/0 | TCP | 8080 | BuilderOS API |
| 0.0.0.0/0 | TCP | 2222 | SSH tunnel |
| 0.0.0.0/0 | TCP | 22 | Oracle SSH (already exists) |

5. Click **"Add Ingress Rules"** to save

### Step 4: Initial Connection

```bash
# SSH into your new VM
ssh ubuntu@YOUR_ORACLE_IP

# You should see:
# Welcome to Ubuntu 22.04...
```

---

## Phase 2: Rathole Server Deployment (20 min)

### Deploy on Oracle VM

1. Copy deployment files to Oracle VM:

```bash
# On your Mac (in builder-system-mobile directory)
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/rathole/server

# Copy to Oracle VM
scp server.toml deploy.sh ubuntu@YOUR_ORACLE_IP:~/
```

2. SSH into Oracle VM and run deployment:

```bash
# SSH to Oracle
ssh ubuntu@YOUR_ORACLE_IP

# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

3. The script will:
   - Update system packages
   - Install Rathole
   - Configure firewall (UFW)
   - Harden SSH security
   - Enable automatic updates
   - Install fail2ban
   - Create systemd service
   - Start Rathole server

4. Verify deployment:

```bash
# Check service status
sudo systemctl status rathole-server

# Should show:
# ● rathole-server.service - Rathole Tunnel Server
#    Loaded: loaded
#    Active: active (running)

# View logs
sudo journalctl -u rathole-server -f
```

---

## Phase 3: Mac Client Installation (15 min)

### Install Rathole Client on Mac

```bash
# On your Mac (in builder-system-mobile directory)
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/rathole/client

# Run installation script with your Oracle IP
./install.sh YOUR_ORACLE_IP

# Example:
# ./install.sh 129.213.45.123
```

The script will:
- Download Rathole for macOS (ARM or x86)
- Install to `/usr/local/bin/rathole`
- Create config at `/usr/local/etc/rathole/client.toml`
- Install LaunchDaemon for auto-start
- Start the client service

### Verify Installation

```bash
# Check if service is running
sudo launchctl list | grep rathole

# Should show: com.rathole.client

# View logs
tail -f /tmp/rathole-client.log

# Should show:
# [INFO] Client started
# [INFO] Connected to server at YOUR_ORACLE_IP:2333
# [INFO] Service builderios-api forwarding...
```

### Test Tunnel

```bash
# Test API endpoint through tunnel
curl http://YOUR_ORACLE_IP:8080/health

# Should return BuilderOS API response
```

---

## Phase 4: iOS App Configuration (2-3 hours)

### Update Xcode Project

1. Open Xcode project:

```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/src
open BuilderOS.xcodeproj
```

2. Remove Tailscale dependency:
   - Go to **Project Settings → Package Dependencies**
   - Remove Tailscale package (if present)
   - Clean build folder (Shift+Cmd+K)

3. Add new service files to Xcode:
   - Right-click **Services** folder
   - **Add Files to "BuilderOS"**
   - Select:
     - `Services/APIConfig.swift`
     - `Services/KeychainManager.swift`
   - Ensure "Copy items if needed" is checked
   - Click **Add**

4. Remove Tailscale files:
   - Select `Services/TailscaleConnectionManager.swift`
   - Right-click → **Delete**
   - Choose **Move to Trash**

### Configure API Settings

1. Open `Services/APIConfig.swift` in Xcode
2. Update the placeholder IP:

```swift
// Change this line:
static var serverIP = "PLACEHOLDER_ORACLE_IP"

// To your Oracle IP:
static var serverIP = "129.213.45.123"  // Your actual IP
```

3. Save the file

### Build and Test

```bash
# Build for iOS Simulator
xcodebuild -scheme BuilderOS \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build

# If successful, run on simulator
xcodebuild -scheme BuilderOS \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  test
```

### First Launch Setup

When you launch the app for the first time:

1. App will prompt for API token
2. Enter the API token from `deployment/CREDENTIALS.md`:
   ```
   HwH+lXVxgZu4/R9Q9oxtqbL8g2SAKRznTKBSUp51+qg=
   ```
3. Token is stored securely in iOS Keychain
4. App should connect and load capsule data

---

## Phase 5: Testing & Validation

### Test Checklist

- [ ] Oracle VM accessible: `ping YOUR_ORACLE_IP`
- [ ] Rathole server running: `ssh ubuntu@YOUR_ORACLE_IP "systemctl status rathole-server"`
- [ ] Mac client running: `sudo launchctl list | grep rathole`
- [ ] API tunnel working: `curl http://YOUR_ORACLE_IP:8080/health`
- [ ] iOS app builds without errors
- [ ] iOS app connects on WiFi
- [ ] iOS app connects on cellular
- [ ] Proton VPN active on iOS during test
- [ ] Proton VPN active on Mac during test
- [ ] Auto-reconnect works (toggle WiFi)
- [ ] Latency acceptable (<100ms)

### Performance Testing

```bash
# Test API latency
time curl http://YOUR_ORACLE_IP:8080/health

# Should return in <100ms typically
```

### Network Scenarios

1. **WiFi to cellular transition:**
   - Open app on WiFi
   - Disable WiFi, enable cellular
   - App should reconnect automatically

2. **VPN reconnection:**
   - Disable Proton VPN on iPhone
   - Re-enable Proton VPN
   - App should still work

3. **Mac sleep/wake:**
   - Put Mac to sleep
   - Wait 5 minutes
   - Wake Mac
   - Rathole client should auto-reconnect
   - Verify: `tail -f /tmp/rathole-client.log`

---

## Maintenance

### Daily Monitoring

The health check script runs automatically every 5 minutes:

```bash
# View health log
tail -f ~/logs/tunnel-health.log

# Should show regular "✅ Tunnel healthy" messages
```

### Control Services

**Mac Client:**
```bash
# Stop client
sudo launchctl stop com.rathole.client

# Start client
sudo launchctl start com.rathole.client

# Restart client
sudo launchctl stop com.rathole.client && \
sudo launchctl start com.rathole.client

# Disable auto-start
sudo launchctl unload /Library/LaunchDaemons/com.rathole.client.plist

# Enable auto-start
sudo launchctl load /Library/LaunchDaemons/com.rathole.client.plist
```

**Oracle Server:**
```bash
# SSH to Oracle VM
ssh ubuntu@YOUR_ORACLE_IP

# Check status
sudo systemctl status rathole-server

# Stop server
sudo systemctl stop rathole-server

# Start server
sudo systemctl start rathole-server

# Restart server
sudo systemctl restart rathole-server

# View logs
sudo journalctl -u rathole-server -f
```

### Monthly Tasks

- [ ] Check Oracle bandwidth usage (max 10TB/month - you'll use ~450MB)
- [ ] Review Rathole logs for anomalies
- [ ] Verify Oracle VM security updates applied
- [ ] Test tunnel from different networks

### Security Updates

Oracle VM automatically installs security updates. Verify:

```bash
ssh ubuntu@YOUR_ORACLE_IP
apt list --upgradable
```

---

## Troubleshooting

### iOS App: "Cannot reach BuilderOS Mac"

**Check:**
1. Is BuilderOS API running on Mac?
   ```bash
   curl http://localhost:8080/health
   ```
2. Is Rathole client running?
   ```bash
   sudo launchctl list | grep rathole
   tail -f /tmp/rathole-client.log
   ```
3. Is Rathole server running?
   ```bash
   ssh ubuntu@YOUR_ORACLE_IP "systemctl status rathole-server"
   ```

**Fix:**
```bash
# Restart Mac client
sudo launchctl stop com.rathole.client
sudo launchctl start com.rathole.client
```

### iOS App: "Invalid API key"

**Check:**
1. Token matches server config?
   ```bash
   # View client config
   cat /usr/local/etc/rathole/client.toml | grep token

   # View server config
   ssh ubuntu@YOUR_ORACLE_IP "cat /etc/rathole/server.toml | grep token"
   ```

**Fix:**
- Delete and re-enter token in iOS app settings
- Token should be: `HwH+lXVxgZu4/R9Q9oxtqbL8g2SAKRznTKBSUp51+qg=`

### Mac Client: Won't start

**Check logs:**
```bash
tail -100 /tmp/rathole-client-error.log
```

**Common issues:**
- Config file syntax error
- Wrong Oracle IP
- Firewall blocking connection

**Fix:**
```bash
# Test config manually
rathole /usr/local/etc/rathole/client.toml

# Watch for errors in output
```

### Oracle Server: Connection refused

**Check firewall:**
```bash
ssh ubuntu@YOUR_ORACLE_IP

# Check UFW status
sudo ufw status

# Should show:
# 2333/tcp   ALLOW       Anywhere
# 8080/tcp   ALLOW       Anywhere
```

**Check Oracle Cloud Security List:**
- Log into Oracle Cloud Console
- Navigate to VCN → Security Lists
- Verify ingress rules (see Phase 1, Step 3)

### High Latency

**Test latency:**
```bash
# From iOS device (using Termius or similar):
time curl http://YOUR_ORACLE_IP:8080/health

# Should be <100ms typically
```

**Causes:**
- Oracle VM region far from you (choose closer region)
- Mobile network congestion (try different location)
- Mac or Oracle VM CPU overload

---

## Security Notes

### What's Protected

- ✅ End-to-end encryption (Noise Protocol - WireGuard-grade)
- ✅ Per-service token authentication
- ✅ No exposed Mac ports (all traffic through tunnel)
- ✅ Automatic security updates (Oracle VM)
- ✅ fail2ban protection (brute force prevention)
- ✅ SSH keys only (no passwords)

### Attack Surface

| Component | Exposure | Risk | Mitigation |
|-----------|----------|------|------------|
| Oracle VM | Public internet | Low | Firewall, fail2ban, auto-updates |
| Rathole ports | Public | Low | Token auth, Noise encryption |
| API token | Config files | Medium | File perms (600), Keychain storage |
| SSH tunnel | Oracle VM only | Very Low | Token auth, encrypted |

### Token Rotation

Rotate tokens every 6 months or if compromised:

```bash
# Generate new tokens
openssl rand -base64 32  # API token
openssl rand -base64 32  # SSH token

# Update configs (see deployment/CREDENTIALS.md)
# Restart all services
```

---

## Cost Analysis

### Oracle Cloud Always Free

| Resource | Free Tier | Your Usage | Cost |
|----------|-----------|------------|------|
| Compute | 4 ARM OCPUs | 1 OCPU | $0 |
| Memory | 24 GB | 6 GB | $0 |
| Storage | 200 GB | ~20 GB | $0 |
| Bandwidth | 10 TB/month | ~450 MB/month | $0 |
| **Total** | | | **$0/month** |

### Bandwidth Usage Estimate

Assuming:
- 100 API requests/day
- 50KB request + 100KB response = 150KB per request
- Daily: 100 × 150KB = 15MB
- Monthly: 15MB × 30 = 450MB

**Verdict:** Well within 10TB/month limit (0.0045% usage)

---

## Next Steps

1. **Update CLAUDE.md:** Document Oracle IP and tunnel setup
2. **Create iOS Settings Screen:** Add UI for Oracle IP + token config
3. **TestFlight Deployment:** Beta test with tunnel
4. **App Store Submission:** Submit production app

---

## Support

**Documentation:**
- This guide: `docs/RATHOLE_SETUP_GUIDE.md`
- Credentials: `deployment/CREDENTIALS.md`
- API docs: `docs/API_INTEGRATION.md`

**Logs:**
- Mac client: `/tmp/rathole-client.log`
- Oracle server: `sudo journalctl -u rathole-server -f`
- Tunnel health: `~/logs/tunnel-health.log`

**Quick Commands:**
```bash
# Check everything
./deployment/scripts/check_tunnel_health.sh

# Restart Mac client
sudo launchctl stop com.rathole.client && \
sudo launchctl start com.rathole.client

# Test API
curl http://YOUR_ORACLE_IP:8080/health
```
