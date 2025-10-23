# BuilderOS iOS Companion App

Native iOS companion app for BuilderOS with **embedded Tailscale SDK** for seamless remote access to your Mac.

## Features

✅ **Embedded Tailscale VPN** - No separate Tailscale app required
✅ **Auto-Discovery** - Automatically finds your Mac on Tailscale network
✅ **Secure Access** - End-to-end encrypted connection to BuilderOS API
✅ **Real-time Status** - Monitor capsules, system health, and services
✅ **Native iOS UI** - SwiftUI with iOS 17+ design language
✅ **Zero Configuration** - One-time setup, then seamless connectivity

## Architecture

### Tech Stack
- **Swift 5.9+** with SwiftUI
- **iOS 17.0+** minimum deployment target
- **Tailscale iOS SDK** via CocoaPods
- **NetworkExtension** framework for VPN management
- **Keychain** for secure credential storage

### Key Components

**Services:**
- `TailscaleConnectionManager` - Manages VPN connection and device discovery
- `BuilderOSAPIClient` - API client that auto-uses Tailscale IP

**Views:**
- `OnboardingView` - First-time setup with Tailscale authentication
- `DashboardView` - Main screen with system status and capsule list
- `SettingsView` - Tailscale and API configuration
- `CapsuleDetailView` - Detailed capsule information and metrics

**Models:**
- `TailscaleDevice` - Represents devices on Tailscale network
- `Capsule` - BuilderOS capsule data model
- `SystemStatus` - BuilderOS system health and metrics

## Setup Instructions

### 1. Install Dependencies

```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile

# Install CocoaPods if not already installed
sudo gem install cocoapods

# Install Tailscale SDK
pod install
```

### 2. Open Xcode Project

```bash
# Open the .xcworkspace (NOT .xcodeproj when using CocoaPods)
open BuilderOS.xcworkspace
```

### 3. Configure Code Signing

1. Select BuilderOS target in Xcode
2. Go to "Signing & Capabilities"
3. Select your Apple Developer Team
4. Update Bundle Identifier: `com.builderos.ios` → `com.yourteam.builderos`

### 4. Configure Entitlements

The project includes required entitlements:
- ✅ Network Extensions (VPN)
- ✅ Personal VPN API
- ✅ Keychain Sharing
- ✅ App Groups
- ✅ Background Modes

**Note:** You may need to register App Group ID in Apple Developer Portal:
- App Group ID: `group.com.builderos.ios`

### 5. Update Info.plist

Update the Mac IP address if different from `100.66.202.6`:

```xml
<key>NSExceptionDomains</key>
<dict>
    <key>YOUR_MAC_TAILSCALE_IP</key>
    <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <true/>
    </dict>
</dict>
```

## First Launch Setup

### On Your Mac

1. **Start BuilderOS API server:**
   ```bash
   cd /Users/Ty/BuilderOS/api
   ./server_mode.sh
   ```

2. **Note your Tailscale IP:**
   ```bash
   tailscale ip -4
   # Example output: 100.66.202.6
   ```

3. **Get API key from server output:**
   ```
   ✅ API Key: sk-builderos-xxxxxxxxxxxxxxxxxxxx
   ```

### On Your iPhone

1. **Launch BuilderOS app**
2. **Tap "Get Started"**
3. **Sign in with Tailscale** (GitHub/Google/Microsoft/Email)
4. **Wait for Mac discovery** - App automatically finds your Mac
5. **Enter API key** from server output
6. **Tap "Connect"** - Dashboard loads with capsule data

## Usage

### Automatic Connection

After first setup:
1. Open app → Auto-connects to Tailscale
2. Auto-discovers Mac on network
3. Connects to API → Dashboard loads
4. **Zero manual configuration needed**

### Viewing Capsules

- **Dashboard** shows all capsules with status indicators
- **Tap capsule card** to view detailed metrics
- **Pull to refresh** to update data
- **Color badges** indicate capsule status (green=active, blue=development, etc.)

### System Status

Dashboard displays:
- ✅ Connection status (Connected to Mac)
- ✅ System version and uptime
- ✅ Active capsules count
- ✅ Running services status

### Settings

Access via gear icon:
- **Tailscale Status** - View connected devices
- **API Key** - Update BuilderOS API key
- **Sign Out** - Disconnect from Tailscale

## Tailscale Integration

### How It Works

1. **Authentication** - OAuth flow via Tailscale
2. **VPN Connection** - NEVPNManager establishes encrypted tunnel
3. **Device Discovery** - Lists all devices on Tailscale network
4. **Mac Selection** - Auto-selects Mac based on hostname
5. **API Access** - Uses Mac's Tailscale IP (`100.66.202.6`) for API calls

### Network Flow

```
iPhone → Tailscale VPN → Mac (100.66.202.6:8080) → BuilderOS API
        (encrypted)           (localhost)
```

### Security

- ✅ End-to-end encryption via Tailscale
- ✅ OAuth authentication (no passwords)
- ✅ API key stored in iOS Keychain
- ✅ Localhost API connection (not exposed to internet)
- ✅ VPN disconnects when app closes

## Development

### Project Structure

```
builder-system-mobile/
├── src/
│   ├── BuilderOSApp.swift          # Main app entry point
│   ├── Models/
│   │   ├── TailscaleDevice.swift   # Device model
│   │   ├── Capsule.swift            # Capsule model
│   │   └── SystemStatus.swift       # System status model
│   ├── Services/
│   │   ├── TailscaleConnectionManager.swift  # VPN management
│   │   └── BuilderOSAPIClient.swift          # API client
│   ├── Views/
│   │   ├── OnboardingView.swift     # First-time setup
│   │   ├── DashboardView.swift      # Main dashboard
│   │   ├── SettingsView.swift       # Settings screen
│   │   └── CapsuleDetailView.swift  # Capsule details
│   └── Utilities/
│       ├── Colors.swift             # Design system colors
│       ├── Typography.swift         # Typography styles
│       └── Spacing.swift            # Layout constants
├── Podfile                          # CocoaPods dependencies
├── Package.swift                    # SPM dependencies (future)
├── BuilderOS.entitlements           # App entitlements
└── README.md                        # This file
```

### Running Tests

```bash
# Run unit tests
xcodebuild test -workspace BuilderOS.xcworkspace -scheme BuilderOS -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Building for Device

1. Connect iPhone via USB
2. Select device in Xcode
3. Cmd+R to build and run
4. Trust developer certificate on device (Settings → General → VPN & Device Management)

## Troubleshooting

### "Mac not found"

**Cause:** Mac is offline or not connected to Tailscale

**Fix:**
1. On Mac: `tailscale status` - ensure "Logged in"
2. On Mac: `tailscale ip -4` - verify IP address
3. On iPhone: Pull to refresh in Settings

### "Connection failed"

**Cause:** BuilderOS API server not running

**Fix:**
1. On Mac: `cd /Users/Ty/BuilderOS/api && ./server_mode.sh`
2. Verify server started on port 8080
3. On iPhone: Retry connection

### "Invalid API key"

**Cause:** API key expired or incorrect

**Fix:**
1. On Mac: Restart API server to generate new key
2. Copy new API key from terminal output
3. On iPhone: Settings → Update API Key

### VPN won't connect

**Cause:** Missing entitlements or provisioning profile

**Fix:**
1. Verify entitlements file is included in target
2. Check provisioning profile includes Network Extensions capability
3. Re-generate provisioning profile in Apple Developer Portal

## API Endpoints Used

All endpoints relative to `http://{mac-tailscale-ip}:8080`:

- `GET /api/status` - System status
- `GET /api/capsules` - List all capsules
- `GET /api/capsules/{id}` - Capsule details
- `GET /api/capsules/{id}/metrics` - Capsule metrics
- `POST /api/capsules/{id}/actions` - Execute capsule action

## Roadmap

### Phase 1 (Current)
- ✅ Tailscale VPN integration
- ✅ Auto-discovery of Mac
- ✅ System status monitoring
- ✅ Capsule list and details

### Phase 2 (Planned)
- [ ] Push notifications for capsule events
- [ ] Execute capsule actions from iPhone
- [ ] Log viewer for capsule output
- [ ] n8n workflow triggers

### Phase 3 (Future)
- [ ] iPad optimized layout
- [ ] Apple Watch companion app
- [ ] Siri shortcuts integration
- [ ] Widget for quick status

## License

Private - BuilderOS System

## Support

For issues or questions:
- Check Tailscale SDK docs: https://tailscale.com/kb/1114/ios-sdk
- BuilderOS API docs: http://100.66.202.6:8080/api/docs
- Xcode console logs for debugging

---

**Note:** This app is designed for personal use with BuilderOS. Tailscale account required (free for personal use).
