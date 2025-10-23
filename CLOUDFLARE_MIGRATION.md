# Cloudflare Tunnel Migration - Complete

## Summary
Successfully migrated BuilderOS iOS app from Tailscale/Rathole tunnel to Cloudflare Tunnel connectivity.

## Changes Made

### 1. **APIConfig.swift** ✅
- Changed from Oracle IP (`serverIP`) to Cloudflare URL (`tunnelURL`)
- Updated base URL to use full HTTPS URL
- Changed keychain key from `rathole_api_token` to `builderos_api_token`
- Added `loadSavedConfiguration()` to load URL from UserDefaults
- Added `updateTunnelURL()` to persist URL changes

### 2. **BuilderOSAPIClient.swift** ✅
- Replaced `macIP` with `tunnelURL` property
- Updated from `http://IP:8080` to full Cloudflare HTTPS URL
- Increased timeout from 5s to 10s for remote HTTPS connection
- Added `sleepMac()` function for remote sleep via `POST /system/sleep`
- Added `SleepResponse` model for sleep endpoint response
- Updated error messages to reference Cloudflare Tunnel instead of Tailscale

### 3. **SettingsView.swift** ✅
- Changed "Tailscale IP Address" to "Cloudflare Tunnel URL"
- Updated placeholder to `https://builderos-xyz.trycloudflare.com`
- Changed keyboard type from `.decimalPad` to `.URL`
- Added System Control section with Sleep Mac button
- Added sleep confirmation dialog
- Added `sleepMac()` function with error handling
- Updated setup instructions to reference Cloudflare Tunnel

### 4. **OnboardingView.swift** ✅
- Completely rewritten to remove Tailscale authentication
- Now uses simple 3-step flow:
  1. Welcome screen
  2. Enter Cloudflare URL + API Key
  3. Test connection
- Removed `TailscaleConnectionManager` dependency
- Added direct URL and API key input fields
- Uses `BuilderOSAPIClient.healthCheck()` for connection testing
- Updated messaging to reference Cloudflare Tunnel

### 5. **DashboardView.swift** ✅
- Removed `TailscaleConnectionManager` dependency
- Updated connection status card to show Cloudflare Tunnel
- Changed "Tailscale VPN" label to "Cloudflare Tunnel"
- Shows tunnel URL instead of Tailscale IP
- Simplified connection state management
- Fixed capsule loading to use `BuilderOSAPIClient` methods

### 6. **Info.plist** ✅
- Added NSAppTransportSecurity configuration
- Set `NSAllowsArbitraryLoads` to `false` (secure HTTPS only)
- Removed Tailscale-specific VPN requirements
- Added comment explaining Cloudflare provides valid SSL

### 7. **Removed Files** ✅
- ❌ `TailscaleConnectionManager.swift` - No longer needed
- ❌ `TailscaleDevice.swift` - No longer needed

## New Features

### Remote Sleep Functionality ✅
- Added `POST /system/sleep` endpoint support
- Sleep button in Settings with confirmation dialog
- Graceful error handling and user feedback
- Connection state clears when Mac goes to sleep

## Configuration

### User Setup Process
1. Backend Dev creates Cloudflare tunnel on Mac
2. User copies Cloudflare URL (e.g., `https://builderos-xyz.trycloudflare.com`)
3. User enters URL and API key in iOS app (Onboarding or Settings)
4. App tests connection via `/api/health` endpoint
5. Ready to use!

### Placeholder Values
- **Cloudflare URL**: `PLACEHOLDER_CLOUDFLARE_URL` in `APIConfig.swift`
- **Example URL**: `https://builderos-xyz.trycloudflare.com` in UI placeholders

### Backend Dev Responsibilities
Backend Dev agent will create a setup script to:
1. Install and configure Cloudflare Tunnel (cloudflared)
2. Start tunnel pointing to `localhost:8080`
3. Output the public Cloudflare URL
4. Provide API token for authentication

## Benefits of Cloudflare Tunnel

✅ **VPN Compatible**: Works alongside Proton VPN on both devices
✅ **HTTPS Encryption**: Cloudflare provides SSL certificates automatically
✅ **Zero Configuration**: No IP addresses to manage
✅ **Fast & Reliable**: Cloudflare's global network
✅ **Free Tier**: No cost for personal use
✅ **No Port Forwarding**: No router configuration needed

## Testing Checklist

Before release, verify:
- [ ] Onboarding flow completes successfully
- [ ] Connection test works in Settings
- [ ] Dashboard loads system status and capsules
- [ ] Sleep button puts Mac to sleep
- [ ] App works on WiFi
- [ ] App works on cellular (if tunnel is public)
- [ ] Proton VPN active on both devices (no conflicts)
- [ ] HTTPS connections use valid SSL (no warnings)

## Next Steps

1. **Backend Dev**: Create Cloudflare tunnel setup script
   - Install cloudflared
   - Configure tunnel to localhost:8080
   - Output Cloudflare URL and API token
   - Create LaunchDaemon for auto-start

2. **Testing**: Verify end-to-end flow with real tunnel

3. **Documentation**: Update capsule CLAUDE.md with Cloudflare instructions

## Verification

### Final Check
```bash
# No TailscaleConnectionManager or TailscaleDevice references in Swift code
grep -r "TailscaleConnectionManager\|TailscaleDevice" src --include="*.swift" | wc -l
# Result: 0 ✅
```

### Remaining Tailscale Mentions (Harmless)
- Color definitions in `Colors.swift` (Tailscale brand colors - can be removed later)
- API response properties (`tailscale_ip` in server responses - backend compatibility)
- Comments and documentation files

## Migration Complete ✅

All Tailscale dependencies removed. App now uses Cloudflare Tunnel for secure, VPN-compatible connectivity.

**Date**: 2025-10-22
**Agent**: 📱 Mobile Dev (Jarvis orchestration)

---

## Summary for Backend Dev

The iOS app is now ready for Cloudflare Tunnel integration. Backend Dev needs to:

1. **Install cloudflared** on Mac
2. **Create tunnel** pointing to `localhost:8080` (BuilderOS API)
3. **Configure port routing** (optional) for localhost preview:
   - `/port-3000` → `localhost:3000` (React/Next.js)
   - `/port-5678` → `localhost:5678` (n8n)
   - `/port-5173` → `localhost:5173` (Vite/Vue)
   - etc.
4. **Output tunnel URL** (e.g., `https://builderos-xyz.trycloudflare.com`)
5. **Provide API token** for authentication
6. **Set up LaunchDaemon** for tunnel auto-start on boot

Once setup is complete, user enters the Cloudflare URL and API token in the iOS app, and it's ready to use!
