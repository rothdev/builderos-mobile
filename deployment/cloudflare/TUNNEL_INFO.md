# Cloudflare Tunnel Setup - BuilderOS Mobile

## Current Configuration

**Tunnel Type:** Free Quick Tunnel (trycloudflare.com)
**Current URL:** `https://api.builderos.app`
**Status:** ✅ Running via LaunchAgent
**Cost:** $0/month forever

**Why Quick Tunnel?**
- Zero cost forever (no domain fees)
- Auto-starts on Mac boot
- URL changes on tunnel restart (~once per few weeks)
- 30-second update workflow after reboot

## How It Works

1. **LaunchAgent** (`com.builderos.cloudflared`) auto-starts quick tunnel on Mac boot
2. **Quick Tunnel** requests random subdomain from trycloudflare.com
3. **Cloudflare Edge** establishes encrypted connection to localhost:8080
4. **BuilderOS API** exposed via HTTPS tunnel (TLS 1.3)
5. **iOS app** connects using current tunnel URL

## URL Behavior

⚠️ **The public URL changes when tunnel restarts (Mac reboot)**

- Quick tunnel **auto-starts** on boot ✅
- Service **keeps running** indefinitely ✅
- **Auto-restarts** on failure (LaunchAgent) ✅
- Public URL is **randomized** on tunnel restart ❌
- Update takes **30 seconds** after reboot ⏱️

### After Mac Reboot (30-second update):

**Quick method** (recommended):
```bash
cd deployment/cloudflare && ./get_current_url.sh
```

The script will:
1. ✅ Get current URL from logs
2. ✅ Test tunnel connectivity
3. ✅ Show exact line to update in iOS app

**Manual method:**
```bash
# 1. Get URL
tail -20 cloudflared.error.log | grep -o 'https://[^[:space:]]*trycloudflare.com' | tail -1

# 2. Edit src/Services/APIConfig.swift line 10
# 3. Rebuild in Xcode (Cmd+R)
```

**Impact:** Once every few weeks when Mac reboots. 30 seconds total.

## Management Commands

**Check Status:**
```bash
launchctl list | grep cloudflared
# Should show: com.builderos.cloudflared
```

**View Current URL:**
```bash
tail -20 /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/cloudflare/cloudflared.error.log | grep "https://"
```

**Restart Tunnel:**
```bash
launchctl kickstart -k gui/$(id -u)/com.builderos.cloudflared
```

**Stop Tunnel:**
```bash
launchctl unload ~/Library/LaunchAgents/com.builderos.cloudflared.plist
```

**Start Tunnel:**
```bash
launchctl load ~/Library/LaunchAgents/com.builderos.cloudflared.plist
```

## Alternative Approaches (If You Want Permanent URL)

**Current setup (recommended):** $0/month, 30-second update after reboot

### Option A: Purchase Domain ($10-15/year)

**Cost:** ~$12/year domain registration
**Setup:** 10 minutes
**Result:** Permanent URL like `api.yourdomain.com`

1. Buy domain (Namecheap, Porkbun, etc.)
2. Add to Cloudflare (free)
3. Create DNS CNAME record → tunnel ID
4. Never update iOS app again

**Trade-off:** Small recurring cost for convenience

### Option B: Tailscale VPN Alternative

**Cost:** $0/month (free tier: 1 user, 100 devices)
**Limitation:** Conflicts with Proton VPN on iOS (only one VPN at a time)
**Result:** Permanent IP `100.x.x.x`

**Why not used:**
- iOS allows only one VPN connection
- Would require disabling Proton VPN
- User requirement: keep Proton VPN active

### Option C: Accept Current Behavior

**Cost:** $0/month forever
**Time:** 30 seconds every few weeks
**BuilderOS principle:** Simplicity > minor inconvenience

## Current API Access

**Public URL:** Check logs for current URL
**BuilderOS API:** http://localhost:8080
**API Key:** `dev-key-change-me`

**Test Connection:**
```bash
# Get current URL from logs
URL=$(tail -20 deployment/cloudflare/cloudflared.error.log | grep -o 'https://[^[:space:]]*trycloudflare.com')

# Test API
curl -s $URL/api/status | jq .
```

## Security & Reliability

**Encryption:**
- ✅ HTTPS/TLS 1.3 (Cloudflare SSL)
- ✅ Application-layer tunnel (no VPN conflicts)
- ✅ Proton VPN compatible on both devices

**Reliability:**
- ✅ 4 redundant tunnel connections
- ✅ Auto-restart on failure (LaunchAgent)
- ✅ Cloudflare global edge network
- ✅ Health monitoring and auto-healing

**Authentication:**
- ⚠️ Dev API key: `dev-key-change-me` (update for production)
- 🔐 Consider JWT tokens for production deployment

## Files & Locations

**LaunchAgent (auto-start on boot):**
- `~/Library/LaunchAgents/com.builderos.cloudflared.plist`

**Helper Scripts:**
- `deployment/cloudflare/get_current_url.sh` - Get URL & test connectivity

**Logs:**
- `deployment/cloudflare/cloudflared.log` - Standard output
- `deployment/cloudflare/cloudflared.error.log` - Info logs (contains URL)

**iOS App:**
- `src/Services/APIConfig.swift` - Tunnel URL configuration (line 10)

---

**Setup Date:** 2025-10-23
**Cloudflared Version:** 2025.9.1
**Tunnel Type:** Quick Tunnel (trycloudflare.com)
**Cost:** $0/month forever
