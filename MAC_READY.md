# Mac Setup Complete ✅

Your Mac is now fully configured and ready for Rathole tunnel deployment!

## ✅ What's Ready on Mac

### Generated & Configured
- ✅ **SSH Key Generated**
  - Location: `~/.ssh/id_rsa.pub`
  - Ready for Oracle Cloud VM setup

- ✅ **Deployment Files Created**
  - Server config: `deployment/rathole/server/server.toml`
  - Server deploy script: `deployment/rathole/server/deploy.sh` (executable)
  - Client config template: `deployment/rathole/client/client.toml.template`
  - Client install script: `deployment/rathole/client/install.sh` (executable)
  - LaunchDaemon plist: `deployment/rathole/client/com.rathole.client.plist`

- ✅ **Secure Tokens Generated**
  - API Token: `HwH+lXVxgZu4/R9Q9oxtqbL8g2SAKRznTKBSUp51+qg=`
  - SSH Token: `TDCykmZHR1CaBKysDc+18HYE+05C9AVyCBxvDVYIb3I=`
  - Stored in: `deployment/CREDENTIALS.md` (chmod 600)

- ✅ **iOS Service Files Created**
  - `src/Services/APIConfig.swift` - Oracle IP configuration
  - `src/Services/KeychainManager.swift` - Secure token storage
  - `src/Services/BuilderOSAPIClient.swift` - Updated with retry logic

- ✅ **Monitoring Scripts Created**
  - Health check: `deployment/scripts/check_tunnel_health.sh`
  - Mac verification: `deployment/scripts/verify_mac_setup.sh`

- ✅ **Documentation Complete**
  - Full guide: `docs/RATHOLE_SETUP_GUIDE.md` (18 pages)
  - Quick start: `deployment/QUICKSTART.md` (4 pages)
  - Summary: `IMPLEMENTATION_COMPLETE.md`
  - Capsule context: `CLAUDE.md` (updated)

### System Status
- ✅ Proton VPN: Running
- ✅ Internet: Connected
- ✅ Disk space: 37GB available
- ⚠️ BuilderOS API: Not running (start before tunnel testing)
- ✅ No existing Rathole installation (clean slate)

---

## 📋 Next Steps - Deployment Roadmap

### Step 1: Create Oracle Cloud Account (30 min)

1. Go to https://oracle.com/cloud/free
2. Click "Start for free"
3. Create account:
   - Email & personal info
   - Verify email
   - Add payment method (required but NOT charged for free tier)
4. Launch ARM VM:
   - Navigate to Compute → Instances → Create Instance
   - **Name:** `builderos-tunnel`
   - **Image:** Canonical Ubuntu 22.04
   - **Shape:** Change Shape → VM.Standard.A1.Flex
     - OCPUs: 1
     - Memory: 6 GB
   - **SSH Key:** Paste your public key (shown below)
   - **Create**
5. Wait 2-3 minutes for provisioning
6. **IMPORTANT:** Note the public IP address!

**Your SSH Public Key:**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdEKg0SiREfdBMAFDb34pxCWODy6h3Qir5AIz+gxq6NRF2hi4kwwX4Oh1li40FeFT7IbLSKDRe61qI6n4EkZ5YPbLG5GAXcxEYH/jHZREXHWWtoH0vH8RUK4+9fDGlIuBbycZsCWtHUouSY4A2BMjVcr0DSN0hmjR6Yvzn/G1uzNTQdudnPqscQjVohNB+PmFQZn19qOQKnrxNOGgOFj1Zbn4y0ix2aFNtEFm1ucy8ijoETGKGZ0APu++ChagwBHZ7TAQiHN29unkcQmNxDsM2qZB8KtdF5Qt9fmXeXSNFgVOeaOcDY/FPYyzI8zn8ykrh9Cso5tdpDytnL5oQXDfSahiw7RL/DyKQ80rnF2053tgM8fjQS3xtVzK61Ik65jzv5T7yHcAIvgavXPLW/riG/tgO+Rd0BNof8sO0XqG/l29Ekl697NbBQ36ZGB/DvyZt7uThOumLBldifJawhp/P/pC1uqoN7gIFVBxQlIQrThHpEZnwXwbj6RsM/yVWwF4JybdtC2LTEcGp5ku9hMdR3KN/GYGbXkE2616oNSTxgABqo08YcGZPzofXtSsU+cQ+x7PklBD3+AytUa6uY1Q55dJnWu676j9QJib3bZK6SdzRvNK0JqFEMO0TIxivxY5Kt5GXQakLLnBRFVRuE+wJCCN1geS2HRXOgN6NHYR8nQ== ty@builderos-mac
```

7. Configure firewall:
   - Networking → Virtual Cloud Networks
   - Click your VCN → Security Lists → Default Security List
   - Add Ingress Rules (4 rules):

| Source CIDR | Protocol | Port | Description |
|-------------|----------|------|-------------|
| 0.0.0.0/0 | TCP | 2333 | Rathole control |
| 0.0.0.0/0 | TCP | 8080 | BuilderOS API |
| 0.0.0.0/0 | TCP | 2222 | SSH tunnel |
| 0.0.0.0/0 | TCP | 22 | Oracle SSH |

---

### Step 2: Deploy Server to Oracle VM (10 min)

```bash
# Copy deployment files
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/rathole/server
scp server.toml deploy.sh ubuntu@YOUR_ORACLE_IP:~/

# SSH to Oracle VM and deploy
ssh ubuntu@YOUR_ORACLE_IP
chmod +x deploy.sh
./deploy.sh

# Verify it's running
sudo systemctl status rathole-server
# Should show "Active: active (running)"
```

---

### Step 3: Install Client on Mac (5 min)

```bash
# Run installation script with your Oracle IP
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/rathole/client
./install.sh YOUR_ORACLE_IP

# Script will:
# - Download Rathole for macOS
# - Install to /usr/local/bin/rathole
# - Create config at /usr/local/etc/rathole/client.toml
# - Install LaunchDaemon for auto-start
# - Start the service

# Verify it's running
sudo launchctl list | grep rathole
# Should show: com.rathole.client

# Check logs
tail -f /tmp/rathole-client.log
# Should show connection to Oracle server
```

---

### Step 4: Test Tunnel (2 min)

```bash
# Make sure BuilderOS API is running on Mac
cd /Users/Ty/BuilderOS/api
./start_api.sh  # Or however you start your API

# Test tunnel
curl http://YOUR_ORACLE_IP:8080/health

# Should return BuilderOS API response
# If you get a response, tunnel is working! 🎉
```

---

### Step 5: Configure iOS App (30 min)

1. **Open Xcode project:**
   ```bash
   cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/src
   open BuilderOS.xcodeproj
   ```

2. **Remove Tailscale dependency** (if present):
   - Project Settings → Package Dependencies
   - Remove Tailscale package
   - Clean build: Shift+Cmd+K

3. **Add new service files:**
   - Right-click Services folder → Add Files
   - Select:
     - `Services/APIConfig.swift`
     - `Services/KeychainManager.swift`
   - Ensure "Copy items if needed" is checked

4. **Remove old Tailscale file:**
   - Select `Services/TailscaleConnectionManager.swift`
   - Right-click → Delete → Move to Trash

5. **Update Oracle IP:**
   - Open `Services/APIConfig.swift`
   - Line 18: Change `PLACEHOLDER_ORACLE_IP` to your actual Oracle IP
   ```swift
   static var serverIP = "YOUR_ORACLE_IP"  // e.g., "129.213.45.123"
   ```

6. **Build & test:**
   ```bash
   # Build for simulator
   xcodebuild -scheme BuilderOS \
     -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
     build

   # If successful, run on simulator or device
   ```

---

### Step 6: Launch & Test (15 min)

1. **Launch app** on iPhone or simulator

2. **Enter API token** when prompted:
   ```
   HwH+lXVxgZu4/R9Q9oxtqbL8g2SAKRznTKBSUp51+qg=
   ```

3. **Test connectivity:**
   - App should connect through tunnel
   - Capsules should load
   - Try on WiFi and cellular
   - Verify Proton VPN is active on both devices

4. **Verify everything:**
   - [ ] App connects on WiFi ✓
   - [ ] App connects on cellular ✓
   - [ ] Proton VPN active on iPhone ✓
   - [ ] Proton VPN active on Mac ✓
   - [ ] Auto-reconnect works (toggle WiFi) ✓
   - [ ] Latency acceptable (<100ms) ✓

---

## 🛠️ Troubleshooting

### Mac Client Won't Start
```bash
# Check logs
tail -100 /tmp/rathole-client-error.log

# Test config manually
rathole /usr/local/etc/rathole/client.toml
```

### iOS App Can't Connect
```bash
# Restart Mac client
sudo launchctl stop com.rathole.client
sudo launchctl start com.rathole.client

# Test tunnel
curl http://YOUR_ORACLE_IP:8080/health
```

### Oracle Server Down
```bash
# SSH to Oracle
ssh ubuntu@YOUR_ORACLE_IP

# Check status
sudo systemctl status rathole-server

# Restart if needed
sudo systemctl restart rathole-server

# Check logs
sudo journalctl -u rathole-server -f
```

---

## 📚 Documentation References

- **Quick Start:** `deployment/QUICKSTART.md`
- **Full Guide:** `docs/RATHOLE_SETUP_GUIDE.md`
- **Credentials:** `deployment/CREDENTIALS.md`
- **Summary:** `IMPLEMENTATION_COMPLETE.md`

---

## ✅ Final Checklist

### Pre-Deployment
- [x] SSH key generated
- [x] Deployment files ready
- [x] Tokens generated
- [x] iOS service files created
- [x] Documentation complete
- [x] Mac setup verified

### During Deployment
- [ ] Oracle Cloud account created
- [ ] VM launched & firewall configured
- [ ] Server deployed & running
- [ ] Mac client installed & running
- [ ] Tunnel tested & working
- [ ] iOS app configured & tested

### Post-Deployment
- [ ] Health monitoring enabled (cron)
- [ ] Bookmark Oracle Cloud console
- [ ] Save Oracle IP in `deployment/CREDENTIALS.md`
- [ ] Test from different networks
- [ ] Enable notifications (optional)

---

## 🚀 Ready to Deploy!

**Time investment:** 60-90 minutes
**Monthly cost:** $0 (forever)
**VPN conflicts:** None (works WITH Proton VPN)

Start here: **`deployment/QUICKSTART.md`**

Or follow detailed walkthrough: **`docs/RATHOLE_SETUP_GUIDE.md`**

---

**All Mac configurations complete. You're ready to create the Oracle Cloud account and deploy! 🎉**
