# BuilderOS iOS App - Complete Setup Guide

This guide walks through the complete setup process from installing dependencies to running the app on your iPhone.

## Prerequisites

### Required Accounts
- ✅ Apple Developer Account (free or paid)
- ✅ Tailscale account (free for personal use - https://login.tailscale.com/start)
- ✅ Mac with BuilderOS installed
- ✅ Xcode 15.0+ installed on Mac

### Required Software
- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- CocoaPods (`sudo gem install cocoapods`)
- iPhone running iOS 17.0+

## Step-by-Step Setup

### 1. Install CocoaPods Dependencies

```bash
# Navigate to project directory
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile

# Install CocoaPods if not already installed
sudo gem install cocoapods

# Install project dependencies (Tailscale SDK)
pod install
```

**Expected output:**
```
Analyzing dependencies
Downloading dependencies
Installing Tailscale (1.88.0)
Generating Pods project
Integrating client project
Pod installation complete! There is 1 dependency from the Podfile.
```

### 2. Open Xcode Workspace

⚠️ **IMPORTANT:** After CocoaPods installation, always open `.xcworkspace`, NOT `.xcodeproj`

```bash
open BuilderOS.xcworkspace
```

### 3. Configure Code Signing

1. **Select BuilderOS target**
   - In Xcode project navigator, click "BuilderOS" (blue icon)
   - Select "BuilderOS" under TARGETS

2. **Set Development Team**
   - Go to "Signing & Capabilities" tab
   - Under "Signing", select your team from dropdown
   - If using free account: Xcode will auto-generate provisioning profile

3. **Update Bundle Identifier**
   - Change `com.builderos.ios` to unique ID
   - Example: `com.yourname.builderos`
   - Must be unique across App Store

### 4. Configure Entitlements

The project includes required capabilities. Verify they're enabled:

1. **Go to "Signing & Capabilities" tab**

2. **Verify these capabilities exist:**
   - ✅ Network Extensions
   - ✅ Personal VPN
   - ✅ Keychain Sharing
   - ✅ App Groups
   - ✅ Background Modes

3. **If using free Apple Developer Account:**
   - You may need to remove some capabilities
   - Minimum required: Keychain Sharing, App Groups
   - Tailscale features may be limited without Personal VPN

### 5. Register App Group (Optional but Recommended)

Required for data sharing between app and network extension:

1. **Go to Apple Developer Portal:**
   - Visit: https://developer.apple.com/account/resources/identifiers/list/applicationGroup

2. **Create App Group:**
   - Click "+" to add new App Group
   - Description: "BuilderOS App Group"
   - Identifier: `group.com.builderos.ios` (or match your bundle ID)

3. **Update Xcode:**
   - In "Signing & Capabilities" → "App Groups"
   - Select your App Group ID

### 6. Configure Mac BuilderOS Server

Before running the app, ensure your Mac is ready:

#### 6a. Install and Configure Tailscale on Mac

```bash
# Install Tailscale via Homebrew (if not installed)
brew install tailscale

# Start Tailscale service
sudo tailscaled install-system-daemon

# Authenticate (opens browser for login)
sudo tailscale up

# Verify connection
tailscale status

# Get your Tailscale IP
tailscale ip -4
# Example output: 100.66.202.6
```

#### 6b. Start BuilderOS API Server

```bash
# Navigate to API directory
cd /Users/Ty/BuilderOS/api

# Start server (generates API key)
./server_mode.sh
```

**Expected output:**
```
🚀 Starting BuilderOS API server...
✅ Server running on http://0.0.0.0:8080
✅ API Key: sk-builderos-abc123xyz789...
📱 Access from Tailscale network: http://100.66.202.6:8080
```

**Save this API key** - you'll need it for iPhone setup.

### 7. Update Info.plist for Your Mac IP

If your Mac's Tailscale IP is different from `100.66.202.6`:

1. **Open `src/Info.plist` in Xcode**

2. **Find "NSExceptionDomains" section:**
   ```xml
   <key>NSExceptionDomains</key>
   <dict>
       <key>100.66.202.6</key>  <!-- UPDATE THIS -->
       <dict>
           <key>NSExceptionAllowsInsecureHTTPLoads</key>
           <true/>
       </dict>
   </dict>
   ```

3. **Replace `100.66.202.6` with your Mac's Tailscale IP**

### 8. Build and Run on Simulator (Testing)

Before deploying to device, test in simulator:

1. **Select iPhone 15 Pro simulator**
   - Top toolbar: Select "iPhone 15 Pro" from device list

2. **Build and run:**
   - Press Cmd+R or click Play button

3. **Test onboarding flow:**
   - App should show onboarding screen
   - Tailscale authentication will be simulated (no real VPN in simulator)

**Note:** Full Tailscale features require real device.

### 9. Deploy to Physical iPhone

#### 9a. Connect iPhone

1. **Connect iPhone to Mac via USB**
2. **Trust computer on iPhone** (popup will appear)
3. **Enable Developer Mode on iPhone:**
   - Settings → Privacy & Security → Developer Mode → ON
   - iPhone will restart

#### 9b. Select Device in Xcode

1. **Top toolbar:** Select your iPhone from device list
2. **Verify iPhone is recognized** (should show "iPhone [Your Name]")

#### 9c. Build and Run

1. **Press Cmd+R** or click Play button
2. **Wait for build to complete** (first build takes ~2-3 minutes)
3. **Watch Xcode console** for build errors

#### 9d. Trust Developer Certificate (First Time Only)

After first install, iPhone will block app launch:

1. **On iPhone:** Settings → General → VPN & Device Management
2. **Find your Apple ID** under "Developer App"
3. **Tap your Apple ID → Trust**
4. **Confirm: "Trust"**

Now app will launch successfully.

### 10. First Launch Setup (On iPhone)

#### 10a. Onboarding

1. **Open BuilderOS app**
2. **Tap "Get Started"**
3. **Tap "Sign in with Tailscale"**

#### 10b. Tailscale Authentication

1. **Safari opens** for Tailscale OAuth
2. **Select authentication method:**
   - GitHub
   - Google
   - Microsoft
   - Email

3. **Sign in** with chosen method
4. **Authorize Tailscale** access
5. **Safari redirects back to app**

#### 10c. Mac Discovery

App automatically:
1. ✅ Connects to Tailscale VPN
2. ✅ Discovers devices on network
3. ✅ Identifies Mac by hostname
4. ✅ Displays: "✓ Found roth-macbook-pro"

If Mac not found:
- Verify Mac Tailscale is online: `tailscale status`
- Pull to refresh in app
- Check Mac hostname matches

#### 10d. API Key Entry

1. **Settings screen appears**
2. **Tap "Add API Key"**
3. **Paste API key** from Mac terminal (Step 6b)
4. **Tap "Save"**

#### 10e. Connect to BuilderOS

1. **Tap "Connect"**
2. **App tests API connection**
3. **Dashboard loads** with capsule data

✅ **Setup complete!** App is ready to use.

## Verification Checklist

After setup, verify everything works:

### ✅ Connection Status
- Dashboard shows: "✓ Connected"
- Mac hostname displayed
- Tailscale IP shown
- Green status indicator

### ✅ System Status Card
- Version number displayed
- Uptime shown
- Capsule count visible
- Services status listed

### ✅ Capsules Section
- Capsule cards appear
- Tap card → detail view loads
- Pull to refresh updates data

### ✅ Settings
- Tailscale status: "Connected"
- Devices list shows Mac
- API key: "Configured" (green)

## Troubleshooting

### Build Errors

**Error: "Could not find module 'Tailscale'"**

**Fix:**
```bash
# Reinstall pods
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile
pod deintegrate
pod install
```

**Error: "Signing for BuilderOS requires a development team"**

**Fix:**
1. Xcode → Signing & Capabilities
2. Select your Apple Developer Team
3. If free account: Change Bundle ID to unique value

### Runtime Errors

**"Mac not found" after authentication**

**Fix:**
1. On Mac: `tailscale status` - ensure online
2. On Mac: `tailscale ip -4` - note IP address
3. On iPhone: Settings → pull to refresh devices
4. Verify Mac IP in Info.plist matches actual IP

**"Connection failed" when connecting**

**Fix:**
1. On Mac: Verify API server is running
2. On Mac: `curl http://localhost:8080/api/health`
3. On iPhone: Check API key is correct
4. Check Tailscale VPN is connected

**"Invalid API key"**

**Fix:**
1. On Mac: Restart API server to generate new key
2. Copy fresh API key from terminal
3. On iPhone: Settings → Update API Key → paste new key

### VPN Issues

**VPN won't connect**

**Fix:**
1. On iPhone: Settings → VPN - delete old Tailscale VPN profiles
2. Force quit BuilderOS app
3. Relaunch app → sign in again
4. Grant VPN permission when prompted

**"VPN configuration permission denied"**

**Fix:**
1. On iPhone: Settings → General → Reset → Reset Network Settings
2. Restart iPhone
3. Relaunch app → sign in to Tailscale again

## Next Steps

After successful setup:

1. **Explore capsules** - Tap any capsule card for details
2. **Monitor system** - Check system status metrics
3. **Pull to refresh** - Update data anytime
4. **Background usage** - App maintains connection when backgrounded

For advanced usage, see main [README.md](../README.md).

## Support

If you encounter issues:

1. **Check Xcode console** for detailed error logs
2. **Verify Mac Tailscale** is online and API server running
3. **Test API manually:** `curl http://100.66.202.6:8080/api/status`
4. **Tailscale docs:** https://tailscale.com/kb/1114/ios-sdk

---

**Setup complete!** 🎉 You now have BuilderOS running on your iPhone with secure Tailscale access.
