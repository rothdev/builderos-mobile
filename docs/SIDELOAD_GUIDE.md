# BuilderOS iOS App - Sideloading Guide

## Overview
This guide walks through building and installing the BuilderOS iOS app on your iPhone for testing. Since the app is not yet on the App Store, you'll sideload it directly from Xcode.

**Requirements:**
- Mac with Xcode 15.0+ installed
- iPhone running iOS 17+ (physical device required)
- Apple Developer Account (free or paid)
- USB-C cable (or Lightning, depending on iPhone model)

---

## Prerequisites

### 1. Verify Xcode Installation
```bash
# Check Xcode version (should be 15.0+)
xcodebuild -version

# If not installed, download from Mac App Store
# or https://developer.apple.com/download/
```

### 2. Ensure iOS 17+ on iPhone
- Settings → General → About → Software Version
- If older than iOS 17, update via Settings → General → Software Update

### 3. Apple Developer Account Setup
- Free account: Use your Apple ID (no cost)
- Paid account: Apple Developer Program ($99/year) for advanced features

---

## Build & Sideload Steps

### Step 1: Open Xcode Project

```bash
# Navigate to capsule directory
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile

# Open Xcode project (NOT workspace, since CocoaPods failed)
open src/BuilderOS.xcodeproj

# OR if you manually created workspace after pod install:
# open BuilderSystemMobile.xcworkspace
```

**IMPORTANT:** Use `.xcworkspace` if CocoaPods installed successfully, otherwise use `.xcodeproj`.

---

### Step 2: Configure Code Signing

1. **Select Project in Navigator**
   - Click "BuilderSystemMobile" at top of file list

2. **Select Target**
   - Choose "BuilderSystemMobile" under TARGETS

3. **Signing & Capabilities Tab**
   - Click "Signing & Capabilities" at top

4. **Team Selection**
   - Automatically manage signing: ✅ (checked)
   - Team: Select your Apple ID / Developer Account
   - If "Team" shows error, click "Add Account..." and sign in with Apple ID

5. **Bundle Identifier**
   - Should be: `com.builderos.ios` or `com.{yourname}.builderos`
   - If conflict, change to unique identifier (e.g., `com.tysmith.builderos`)

6. **Provisioning Profile**
   - Should auto-generate: "iOS Team Provisioning Profile: ..."
   - If error, ensure Team is selected correctly

**Common Signing Issues:**
- **"Failed to create provisioning profile"** → Sign in with Apple ID in Xcode preferences
- **"No profiles for ..."** → Ensure Bundle ID is unique (change if needed)
- **"Untrusted Developer"** → On iPhone: Settings → General → VPN & Device Management → Trust [Your Name]

---

### Step 3: Check Entitlements & Info.plist

The project should already have:

**Entitlements (BuilderOS.entitlements):**
- ✅ Keychain sharing
- ✅ Network extensions (VPN)
- ✅ Personal VPN
- ✅ App groups

**Info.plist Configuration:**
- ✅ iOS 17.0 minimum deployment target
- ✅ Local network usage description
- ✅ App Transport Security exception for Tailscale IP
- ✅ Background modes (network authentication)

**No action needed** - these are already configured in the capsule.

---

### Step 4: Connect iPhone to Mac

1. **Physical Connection**
   - Plug iPhone into Mac via USB cable
   - Unlock iPhone

2. **Trust Computer Prompt (iPhone)**
   - Prompt: "Trust This Computer?"
   - Tap "Trust"
   - Enter iPhone passcode

3. **Select Device in Xcode**
   - Top toolbar: Click device selector (next to Run button)
   - Should show your iPhone (e.g., "Ty's iPhone")
   - If not visible:
     - Xcode → Window → Devices and Simulators
     - Ensure iPhone is connected and trusted
     - May need to update iOS or Xcode

---

### Step 5: Build the App

1. **Clean Build Folder** (optional, recommended for first build)
   - Product → Clean Build Folder (Shift+Cmd+K)

2. **Build & Run**
   - Click Run button (▶) in top-left toolbar
   - OR: Product → Run (Cmd+R)

3. **Wait for Build**
   - Xcode compiles Swift source files
   - Progress shown in status bar at top
   - Build time: ~30-60 seconds (first build longer)

**Watch for Build Errors:**
- **"Command CompileSwift failed"** → Swift syntax error, check error log
- **"Linker command failed"** → Missing framework or library
- **"Code signing failed"** → Go back to Step 2, re-check signing settings

If build succeeds, Xcode will automatically install app on iPhone.

---

### Step 6: Trust Developer Certificate (First Install Only)

**On iPhone, you'll see:**
- App icon appears on home screen
- But tapping it shows: "Untrusted Developer"

**To fix:**
1. iPhone → Settings
2. General → VPN & Device Management
3. Under "Developer App", tap your Apple ID email
4. Tap "Trust [Your Name]"
5. Confirm "Trust" in popup

**Now you can launch the app!**

---

### Step 7: Launch & Test

1. **Launch App**
   - Tap BuilderOS icon on iPhone home screen
   - App should launch to onboarding screen

2. **Grant Permissions**
   - **Local Network:** Allow (required for Tailscale)
   - **VPN Configuration:** Allow (required for Tailscale VPN)

3. **Begin Testing**
   - Follow TEST_PLAN.md for comprehensive testing
   - Report any crashes or issues

---

## Troubleshooting

### Build Fails with CocoaPods Error
**Problem:** "Tailscale" pod not found or gem error

**Solution:**
- The CocoaPods dependency has known Ruby compatibility issues on macOS 15
- For initial testing, the app can build without Tailscale SDK (using mock authentication)
- Tailscale SDK integration will be completed in future iteration

**Workaround:**
1. Remove Podfile reference to Tailscale temporarily
2. Build with Xcode project (not workspace)
3. App will use mock Tailscale authentication for testing

---

### App Crashes on Launch
**Possible Causes:**
1. **iOS version too old** → Must be iOS 17+
2. **Missing entitlements** → Verify BuilderOS.entitlements is included in project
3. **Runtime error** → Check Xcode console for crash logs

**Debug Steps:**
```bash
# View crash logs in Xcode
# Window → Devices and Simulators → View Device Logs
# Look for BuilderOS crash reports
```

---

### iPhone Not Showing in Xcode
**Solutions:**
1. **Reconnect USB cable** (try different port)
2. **Unlock iPhone** (must be unlocked during install)
3. **Trust computer again** (Settings → General → Reset Location & Privacy, then reconnect)
4. **Restart Xcode and iPhone**
5. **Update Xcode** (App Store → Updates)

---

### "No Code Signing Identities Found"
**Problem:** Xcode can't find valid signing certificate

**Solution:**
1. Xcode → Preferences → Accounts
2. Click "+" → Add Apple ID
3. Sign in with your Apple ID
4. Select account → Manage Certificates → "+" → Apple Development
5. Close preferences, retry code signing setup

---

### App Installs but Shows "Untrusted Developer"
**Solution:**
- See Step 6 above: Trust developer certificate in iPhone Settings
- Settings → General → VPN & Device Management → Trust [Your Name]

---

### "Could not launch BuilderOS"
**Problem:** App installed but won't launch from Xcode

**Solution:**
1. Disconnect iPhone from Mac
2. Launch app manually from home screen
3. If you need Xcode debugging, try:
   - Product → Clean Build Folder
   - Restart Xcode
   - Rebuild and run

---

## Alternative: Sideload via .ipa File

If you want to install without keeping iPhone connected:

### Step 1: Archive App
```bash
# In Xcode:
# Product → Archive
# Wait for archiving to complete
# Organizer window opens
```

### Step 2: Export IPA
1. In Organizer, select archive
2. Click "Distribute App"
3. Choose "Development" (for testing on your devices)
4. Select signing options (automatic recommended)
5. Export to folder (e.g., Desktop/BuilderOS.ipa)

### Step 3: Install IPA
**Option A: Xcode Devices Window**
1. Xcode → Window → Devices and Simulators
2. Select your iPhone
3. Drag .ipa file to "Installed Apps" section

**Option B: Apple Configurator 2** (Mac App Store)
1. Open Apple Configurator 2
2. Connect iPhone
3. Double-click iPhone
4. Click "Add" → Apps → Choose .ipa file

---

## Quick Reference Commands

```bash
# Navigate to project
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile

# Open in Xcode
open src/BuilderOS.xcodeproj

# Build from command line (if needed)
xcodebuild -project src/BuilderOS.xcodeproj \
  -scheme BuilderSystemMobile \
  -destination 'platform=iOS,name=Ty's iPhone' \
  clean build

# View connected devices
xcrun xctrace list devices

# Install IPA to connected iPhone
xcrun devicectl device install app \
  --device <device-id> \
  BuilderOS.ipa
```

---

## Next Steps After Installation

1. **Test core features** (see TEST_PLAN.md)
2. **Report bugs** in GitHub issues or capsule docs
3. **Iterate on feedback** and rebuild as needed

---

## App Retention Notes

**Free Apple Developer Account:**
- Apps expire after **7 days**
- Must rebuild and reinstall weekly
- No limit on number of installs

**Paid Apple Developer Account ($99/year):**
- Apps valid for **1 year**
- Can distribute via TestFlight
- Up to 10,000 beta testers

**For BuilderOS:** Free account is sufficient for personal testing.

---

## Support & Troubleshooting

**Xcode Issues:** [Apple Developer Forums](https://developer.apple.com/forums/)

**BuilderOS Issues:** See capsule `docs/` or create issue in repo

**Emergency Reset:**
1. Delete app from iPhone
2. Xcode → Clean Build Folder
3. Restart Xcode and iPhone
4. Start sideload process from beginning

---

**Ready to sideload and test!** 🚀
