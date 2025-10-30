# Cloudflare Tunnel Status

**Date:** 2025-10-30
**Status:** HTTP Working, WebSocket Limited

## Current Setup

### ✅ What's Working
- Backend API server running on `localhost:8080`
- Cloudflare tunnel running: `builderos-mobile`
- HTTP endpoints accessible at `https://api.builderos.app`
- Health check: `https://api.builderos.app/api/health` ✅

### ⚠️ WebSocket Limitations
Cloudflare tunnels use HTTP/2 by default, which has **known issues** with WebSocket upgrades:
- WebSocket connections may fail or be unreliable
- HTTP/2 to HTTP/1.1 downgrade not always successful
- Attempted config fixes (http2Origin: false) caused tunnel startup failures

## Current Services Status

```bash
# Backend API
ps aux | grep "python3 server.py"
curl http://localhost:8080/api/health

# Cloudflare Tunnel
ps aux | grep cloudflared
curl https://api.builderos.app/api/health

# Start backend
cd api && ./start.sh

# Start tunnel
cloudflared tunnel run builderos-mobile
```

## Push Notifications (Production Ready)

The app has **Apple Push Notifications (APNs)** fully configured:
- ✅ APNs certificate installed (`api/certs/apns_combined.pem`)
- ✅ Device token registration endpoint
- ✅ Automatic notifications on new messages
- ✅ Works when app is backgrounded/closed

**Push notifications work independently of WebSocket state** - this is the primary delivery mechanism when the app is not actively connected.

## Recommended Solution for Production

Since WebSocket reliability through Cloudflare is limited, recommend one of:

### Option 1: Tailscale (Recommended)
- Direct encrypted connection (no Cloudflare middleman)
- Full WebSocket support
- Lower latency
- Already configured in BuilderOS

```bash
# Update APIConfig.swift to use Tailscale URL
static var tunnelURL = "https://<tailscale-hostname>"
```

### Option 2: Use Push Notifications Only
- App uses WebSocket when actively open
- Falls back to APNs when backgrounded
- Current setup already handles this gracefully
- No code changes needed

### Option 3: Dedicated WebSocket Tunnel
- Separate tunnel/domain for WebSocket traffic
- Configure with HTTP/1.1 only
- More complex infrastructure

## Testing the Current Setup

1. **Test HTTP API:**
   ```bash
   curl https://api.builderos.app/api/health
   ```

2. **Test on iPhone:**
   - Open BuilderOS app
   - Try sending a message
   - If connection fails, check backend logs
   - Background app → Should receive APNs push notification

3. **Check Logs:**
   ```bash
   # Backend
   tail -f /tmp/builderos-api.log

   # Tunnel
   tail -f /tmp/cloudflared-simple.log
   ```

## Known Issues

1. **WebSocket via Cloudflare:** Unreliable due to HTTP/2
2. **Config file approach:** Caused tunnel startup failures
3. **Simple mode:** HTTP works, WebSocket may be intermittent

## Files

- Config (not currently used): `~/.cloudflared/builderos-mobile-config.yml`
- Credentials: `~/.cloudflared/9eaea311-5351-4b1c-a95f-27db38da53c5.json`
- Tunnel ID: `9eaea311-5351-4b1c-a95f-27db38da53c5`
- Domain: `api.builderos.app`

---

**Bottom Line:** HTTP API works through Cloudflare. Push notifications are production-ready. For reliable real-time chat when app is active, consider switching to Tailscale connection.
