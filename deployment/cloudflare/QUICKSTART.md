# Cloudflare Tunnel Quick Start

**Get BuilderOS API accessible from iOS in 5 minutes**

---

## Prerequisites Checklist

- [ ] Cloudflare account (free tier works)
- [ ] Domain managed by Cloudflare
- [ ] Mac with Homebrew installed
- [ ] BuilderOS API running: `cd /Users/Ty/BuilderOS/api && ./server_mode.sh`

---

## Step 1: Run Setup Script

```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/cloudflare
./setup_tunnel.sh
```

**You'll be prompted for:**
1. Install cloudflared? → `y` (if needed)
2. Cloudflare login → Browser opens, log in
3. Tunnel name → e.g., `builderos-api`
4. Domain/subdomain → e.g., `builderos.yourdomain.com`

**Script will:**
- Install cloudflared
- Create tunnel
- Set up DNS
- Configure auto-start
- Start tunnel immediately

---

## Step 2: Verify Setup

```bash
./verify_tunnel.sh
```

**Should see:**
```
✓ LaunchAgent is loaded
✓ cloudflared process is running
✓ BuilderOS API is running locally
✓ Public URL is accessible
```

---

## Step 3: Test from Command Line

```bash
# Health check (no auth needed)
curl https://builderos.yourdomain.com/health

# Capsules endpoint (requires API key)
export BUILDEROS_API_KEY="your-api-key"
curl -H "X-API-Key: $BUILDEROS_API_KEY" \
  https://builderos.yourdomain.com/api/capsules
```

---

## Step 4: Update iOS App

**Change base URL:**
```swift
// From:
let baseURL = "http://100.x.x.x:8080"  // Tailscale

// To:
let baseURL = "https://builderos.yourdomain.com"  // Cloudflare Tunnel
```

**Test in iOS app:**
- Health check should work immediately
- Authenticated endpoints need API key in header

---

## Done! 🎉

Your BuilderOS API is now accessible from anywhere via:
**`https://builderos.yourdomain.com`**

---

## Useful Commands

**Check tunnel status:**
```bash
launchctl list | grep cloudflared
```

**View logs:**
```bash
tail -f cloudflared.log
```

**Restart tunnel:**
```bash
launchctl kickstart -k gui/$(id -u)/com.builderos.cloudflared
```

---

## Troubleshooting

**502 Bad Gateway?**
→ BuilderOS API not running. Start it:
```bash
cd /Users/Ty/BuilderOS/api && ./server_mode.sh
```

**DNS not resolving?**
→ Wait 1-5 minutes for DNS propagation

**Tunnel not starting?**
→ Check logs: `tail -f cloudflared.error.log`

---

**For full documentation, see [README.md](README.md)**
