# Cloudflare Tunnel Setup for BuilderOS API

**Expose BuilderOS API (localhost:8080) securely via Cloudflare Tunnel**

This setup allows your iOS app to access the BuilderOS API from anywhere, even when both devices are behind Proton VPN. Cloudflare Tunnel creates a secure, outbound-only connection that doesn't conflict with VPN configurations.

---

## Overview

**What This Does:**
- Exposes `localhost:8080` (BuilderOS API) via a public Cloudflare URL
- Works alongside Proton VPN (no VPN conflicts)
- Auto-starts on Mac boot via LaunchAgent
- Survives network changes and Mac sleep/wake cycles
- Provides secure, encrypted access without port forwarding

**Architecture:**
```
iOS App → Cloudflare Edge → Cloudflare Tunnel → Mac localhost:8080
          (Public HTTPS)    (Encrypted)         (BuilderOS API)
```

---

## Quick Start

### Prerequisites

1. **Cloudflare account** (free tier works)
2. **Domain managed by Cloudflare** (or subdomain)
3. **Homebrew installed** on Mac
4. **BuilderOS API running** on `localhost:8080`

### Installation

Run the interactive setup script:

```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile/deployment/cloudflare
./setup_tunnel.sh
```

The script will:
1. Install `cloudflared` via Homebrew (if needed)
2. Authenticate with Cloudflare (opens browser)
3. Create a new tunnel
4. Set up DNS records
5. Configure LaunchAgent for auto-start
6. Start the tunnel immediately

**Example Run:**
```bash
$ ./setup_tunnel.sh

╔════════════════════════════════════════════════╗
║   Cloudflare Tunnel Setup for BuilderOS API   ║
╚════════════════════════════════════════════════╝

ℹ Step 1: Checking if cloudflared is installed...
✓ cloudflared is already installed
cloudflared version 2024.10.0

ℹ Step 2: Authenticating with Cloudflare...
⚠ This will open a browser window for authentication.
Press Enter to continue...

✓ Successfully authenticated with Cloudflare

ℹ Step 3: Creating Cloudflare Tunnel...
Enter a name for your tunnel (e.g., 'builderos-api'): builderos-api
ℹ Creating tunnel: builderos-api
✓ Tunnel created successfully
✓ Tunnel ID: 8f3e2a1b-4c5d-6e7f-8g9h-0i1j2k3l4m5n

ℹ Step 4: Setting up DNS record...
Enter your full domain/subdomain: builderos.yourdomain.com
✓ DNS record created successfully

ℹ Step 5: Updating configuration files...
✓ tunnel-config.yml updated
✓ LaunchAgent plist updated

ℹ Step 6: Installing LaunchAgent for auto-start...
✓ LaunchAgent loaded and will start on boot

╔════════════════════════════════════════════════╗
║           Setup Complete! 🎉                    ║
╚════════════════════════════════════════════════╝

✓ Your BuilderOS API is now accessible at:
  https://builderos.yourdomain.com
```

---

## Verification

After setup, verify everything is working:

```bash
./verify_tunnel.sh
```

The verification script tests:
1. LaunchAgent is loaded
2. `cloudflared` process is running
3. BuilderOS API is accessible locally
4. Public URL is reachable
5. Authenticated endpoints work (with API key)
6. Sleep endpoint is functional

**Example Output:**
```bash
╔════════════════════════════════════════════════╗
║     Cloudflare Tunnel Verification Tool       ║
╚════════════════════════════════════════════════╝

ℹ Test 1: Checking if LaunchAgent is loaded...
✓ LaunchAgent is loaded

ℹ Test 2: Checking if cloudflared process is running...
✓ cloudflared process is running
ℹ Process ID: 12345

ℹ Test 3: Checking if BuilderOS API is running on localhost:8080...
✓ BuilderOS API is running locally

ℹ Test 4: Checking if public URL is accessible...
✓ Public URL is accessible (HTTP 200)

╔════════════════════════════════════════════════╗
║         Verification Complete! 🎉              ║
╚════════════════════════════════════════════════╝

✓ All critical tests passed!
```

---

## Configuration Files

### `tunnel-config.yml`
Main tunnel configuration:
```yaml
tunnel: <your-tunnel-id>
credentials-file: /Users/Ty/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: builderos.yourdomain.com
    service: http://localhost:8080
    originRequest:
      noTLSVerify: true
      connectTimeout: 30s
      keepAliveConnections: 10
      keepAliveTimeout: 90s
  - service: http_status:404
```

### `com.builderos.cloudflared.plist`
LaunchAgent configuration for auto-start:
- Runs on system boot (`RunAtLoad`)
- Restarts on crash (`KeepAlive`)
- Logs to `cloudflared.log` and `cloudflared.error.log`
- 10-second restart throttle

---

## Usage

### Managing the Tunnel

**Check Status:**
```bash
launchctl list | grep cloudflared
```

**View Logs:**
```bash
# Real-time logs
tail -f cloudflared.log

# Error logs
tail -f cloudflared.error.log
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

### Cloudflare CLI Commands

**List All Tunnels:**
```bash
cloudflared tunnel list
```

**Get Tunnel Info:**
```bash
cloudflared tunnel info <tunnel-id>
```

**Test Tunnel (Manual Run):**
```bash
cloudflared tunnel --config tunnel-config.yml run <tunnel-id>
```

**Delete Tunnel (Cleanup):**
```bash
# First, remove LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.builderos.cloudflared.plist

# Then delete tunnel
cloudflared tunnel delete <tunnel-name>
```

---

## iOS App Integration

### Update iOS App Configuration

1. **Update API Base URL:**
   ```swift
   // Before (Tailscale):
   let baseURL = "http://100.x.x.x:8080"

   // After (Cloudflare Tunnel):
   let baseURL = "https://builderos.yourdomain.com"
   ```

2. **Store API Key in Keychain:**
   ```swift
   import Security

   func storeAPIKey(_ key: String) {
       let keyData = key.data(using: .utf8)!
       let query: [String: Any] = [
           kSecClass as String: kSecClassGenericPassword,
           kSecAttrAccount as String: "builderos_api_key",
           kSecValueData as String: keyData
       ]
       SecItemAdd(query as CFDictionary, nil)
   }
   ```

3. **Use API Key in Requests:**
   ```swift
   var request = URLRequest(url: url)
   request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
   ```

### Test Endpoints from iOS

**Health Check (No Auth):**
```swift
GET https://builderos.yourdomain.com/health
```

**List Capsules (With Auth):**
```swift
GET https://builderos.yourdomain.com/api/capsules
Header: X-API-Key: your-api-key
```

**Sleep Mac (With Auth):**
```swift
POST https://builderos.yourdomain.com/api/system/sleep
Header: X-API-Key: your-api-key
```

---

## Sleep Endpoint

The BuilderOS API includes a `/api/system/sleep` endpoint that puts your Mac to sleep remotely.

### How It Works

**Endpoint:**
```
POST /api/system/sleep
```

**Authentication:**
Requires `X-API-Key` header with valid API key.

**Response (Success):**
```json
{
  "status": "success",
  "message": "Mac is going to sleep",
  "timestamp": "2025-10-22T21:30:00Z"
}
```

**Response (Error):**
```json
{
  "status": "error",
  "message": "Failed to sleep Mac: <error details>",
  "help": "Ensure pmset command is available and user has permissions"
}
```

### Testing from Command Line

```bash
# Set API key
export BUILDEROS_API_KEY="your-api-key"

# Test sleep endpoint (WARNING: Will actually sleep your Mac!)
curl -X POST \
  -H "X-API-Key: $BUILDEROS_API_KEY" \
  https://builderos.yourdomain.com/api/system/sleep
```

### iOS Implementation Example

```swift
func sleepMac() async throws {
    let url = URL(string: "\(baseURL)/api/system/sleep")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.invalidResponse
    }

    let result = try JSONDecoder().decode(SleepResponse.self, from: data)
    print("Mac sleep status: \(result.status)")
}
```

---

## Security Considerations

### API Key Protection

1. **Never commit API keys to version control**
2. **Store API key in Strongbox** (Mac) and **Keychain** (iOS)
3. **Use environment variable** for local development:
   ```bash
   export BUILDEROS_API_KEY="your-secure-api-key"
   ```

### Tunnel Security

- **HTTPS Only:** All traffic between iOS app and Cloudflare is encrypted
- **Cloudflare to Mac:** Tunnel connection is also encrypted
- **No Exposed Ports:** No need to open router ports or configure firewalls
- **Revocable:** Delete tunnel instantly if compromised

### Monitoring

**Check Access Logs:**
```bash
# BuilderOS API logs
tail -f /Users/Ty/BuilderOS/api/server.log

# Cloudflare Tunnel logs
tail -f cloudflared.log
```

**Enable Cloudflare Access (Optional):**
For additional security, consider [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/applications/) for identity-based authentication.

---

## Troubleshooting

### Tunnel Not Starting

**Check LaunchAgent:**
```bash
launchctl list | grep cloudflared
```

**Check Process:**
```bash
ps aux | grep cloudflared
```

**View Logs:**
```bash
tail -f cloudflared.error.log
```

**Common Fix:**
```bash
# Unload and reload
launchctl unload ~/Library/LaunchAgents/com.builderos.cloudflared.plist
launchctl load ~/Library/LaunchAgents/com.builderos.cloudflared.plist
```

### DNS Not Resolving

**Wait for DNS Propagation:**
DNS changes can take 1-5 minutes. Check with:
```bash
nslookup builderos.yourdomain.com
```

**Manually Create DNS Record:**
```bash
cloudflared tunnel route dns <tunnel-id> builderos.yourdomain.com
```

### 502 Bad Gateway

**Cause:** BuilderOS API is not running on `localhost:8080`.

**Fix:**
```bash
cd /Users/Ty/BuilderOS/api
./server_mode.sh
```

**Verify API:**
```bash
curl http://localhost:8080/health
```

### API Key Issues

**Check API Key:**
```bash
# In BuilderOS API directory
source .env
echo $BUILDEROS_API_KEY
```

**Test with API Key:**
```bash
curl -H "X-API-Key: $BUILDEROS_API_KEY" \
  https://builderos.yourdomain.com/api/capsules
```

---

## VPN Compatibility

### Why This Works with Proton VPN

Traditional solutions (port forwarding, Tailscale) can conflict with VPNs. Cloudflare Tunnel:
- **Outbound-only connection** from Mac to Cloudflare (no inbound ports)
- **Works through VPN** because Mac initiates the connection
- **No routing conflicts** with VPN's network configuration
- **No DNS leaks** since tunnel handles routing internally

### Running Both Proton VPN and Cloudflare Tunnel

1. **Start Proton VPN** on Mac (as usual)
2. **Start Cloudflare Tunnel** (LaunchAgent or manual)
3. **Both operate independently** without conflicts
4. **iOS app** connects via Cloudflare's global edge network

**Connectivity Flow:**
```
iOS (Proton VPN) → Cloudflare Edge → Tunnel → Mac (Proton VPN) → BuilderOS API
      ↑                                                   ↑
    Encrypted                                         Encrypted
```

---

## File Structure

```
deployment/cloudflare/
├── README.md                      # This file
├── setup_tunnel.sh                # Interactive setup script
├── verify_tunnel.sh               # Verification script
├── tunnel-config.yml              # Tunnel configuration
├── com.builderos.cloudflared.plist # LaunchAgent plist
├── .tunnel-info                   # Generated by setup script
├── cloudflared.log                # Tunnel logs (generated)
└── cloudflared.error.log          # Error logs (generated)
```

---

## Additional Resources

- **Cloudflare Tunnel Docs:** https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **cloudflared CLI Reference:** https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/
- **BuilderOS API Docs:** `/Users/Ty/BuilderOS/api/CONNECTION_INFO.md`
- **LaunchAgent Guide:** https://www.launchd.info/

---

## License

Part of BuilderOS - Ty's personal build system.

---

**Setup completed successfully? Run `./verify_tunnel.sh` to confirm!**
