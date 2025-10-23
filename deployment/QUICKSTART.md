# Rathole Tunnel - Quick Start

Complete setup in 60-90 minutes. Zero monthly cost.

## Prerequisites

- ✅ Mac with BuilderOS API running (localhost:8080)
- ✅ Proton VPN active on Mac (stays active)
- ✅ Proton VPN active on iPhone (stays active)
- ✅ SSH key on Mac (`~/.ssh/id_rsa.pub`)

## Step-by-Step

### 1. Oracle Cloud Account (30 min)

1. Go to https://oracle.com/cloud/free
2. Create account (email, payment method - NOT charged)
3. Create VM:
   - **Compute → Instances → Create**
   - Shape: **VM.Standard.A1.Flex** (ARM, 1 OCPU, 6GB RAM)
   - Image: **Ubuntu 22.04**
   - SSH key: Upload your `~/.ssh/id_rsa.pub`
4. **Note the Public IP** (e.g., `129.213.45.123`)
5. Add firewall rules:
   - **Networking → VCN → Security Lists**
   - Add ingress: TCP ports **2333, 8080, 2222** from **0.0.0.0/0**

### 2. Deploy Server (10 min)

```bash
# On Mac, copy files to Oracle VM
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/rathole/server
scp server.toml deploy.sh ubuntu@YOUR_ORACLE_IP:~/

# SSH and deploy
ssh ubuntu@YOUR_ORACLE_IP
chmod +x deploy.sh
./deploy.sh
```

### 3. Install Mac Client (5 min)

```bash
# On Mac
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/rathole/client
./install.sh YOUR_ORACLE_IP
```

### 4. Test Tunnel (2 min)

```bash
# Test API through tunnel
curl http://YOUR_ORACLE_IP:8080/health

# Should return BuilderOS API response
```

### 5. Configure iOS App (30 min)

1. Open Xcode: `src/BuilderOS.xcodeproj`
2. Remove Tailscale dependency (if present)
3. Add new files:
   - `Services/APIConfig.swift`
   - `Services/KeychainManager.swift`
4. Update `APIConfig.swift` with your Oracle IP
5. Build & run on simulator/device

### 6. First Launch

When app starts:
1. Enter API token when prompted:
   ```
   HwH+lXVxgZu4/R9Q9oxtqbL8g2SAKRznTKBSUp51+qg=
   ```
2. App connects through tunnel
3. View capsules!

## Verification

| Check | Command | Expected |
|-------|---------|----------|
| Oracle VM up | `ping YOUR_ORACLE_IP` | Response |
| Server running | `ssh ubuntu@YOUR_ORACLE_IP "systemctl status rathole-server"` | Active (running) |
| Client running | `sudo launchctl list \| grep rathole` | com.rathole.client |
| Tunnel works | `curl http://YOUR_ORACLE_IP:8080/health` | API response |
| iOS connects | Launch app | Capsules load |

## Files Created

```
deployment/
├── rathole/
│   ├── server/
│   │   ├── server.toml              # Server config
│   │   └── deploy.sh                # Server deployment script
│   └── client/
│       ├── client.toml.template     # Client config template
│       ├── com.rathole.client.plist # LaunchDaemon
│       └── install.sh               # Client install script
├── scripts/
│   └── check_tunnel_health.sh      # Health monitoring
├── CREDENTIALS.md                   # Tokens (KEEP SECURE!)
└── QUICKSTART.md                    # This file

docs/
└── RATHOLE_SETUP_GUIDE.md          # Complete guide

src/Services/
├── APIConfig.swift                  # API configuration
├── KeychainManager.swift            # Secure storage
└── BuilderOSAPIClient.swift         # Updated API client (no Tailscale)
```

## Cost

**$0/month forever** (Oracle Always Free Tier)

## Troubleshooting

| Problem | Solution |
|---------|----------|
| App can't connect | Restart Mac client: `sudo launchctl stop com.rathole.client && sudo launchctl start com.rathole.client` |
| Invalid API key | Re-enter token in iOS app settings |
| Tunnel down | Check logs: `tail -f /tmp/rathole-client.log` |
| Server down | SSH and check: `sudo systemctl status rathole-server` |

## Full Documentation

See [`docs/RATHOLE_SETUP_GUIDE.md`](../docs/RATHOLE_SETUP_GUIDE.md) for:
- Detailed explanations
- Security analysis
- Maintenance procedures
- Advanced troubleshooting

## Support

**Logs:**
- Mac: `/tmp/rathole-client.log`
- Oracle: `sudo journalctl -u rathole-server -f` (via SSH)
- Health: `~/logs/tunnel-health.log`

**Quick Commands:**
```bash
# Restart Mac client
sudo launchctl stop com.rathole.client && sudo launchctl start com.rathole.client

# Check tunnel health
./deployment/scripts/check_tunnel_health.sh

# Test API
curl http://YOUR_ORACLE_IP:8080/health
```

---

**Ready to deploy!** Start with Step 1: Oracle Cloud account creation.
