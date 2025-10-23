# BuilderOS iOS App - Known Issues & Blockers

**Last Updated:** October 22, 2025
**Build Status:** Ready for Testing (with limitations)

---

## Critical Issues

### 1. CocoaPods Dependency Installation Failure ⚠️
**Status:** Blocked
**Priority:** Medium (workaround available)

**Issue:**
CocoaPods fails to install Tailscale SDK dependency due to Ruby FFI gem compatibility issue on macOS 15.

**Error:**
```
LoadError - dlopen(/Library/Ruby/Gems/2.6.0/gems/ffi-1.14.2/lib/ffi_c.bundle, 0x0009):
tried: '/Library/Ruby/Gems/2.6.0/gems/ffi-1.14.2/lib/ffi_c.bundle'
(cpu type/subtype in slice (arm64e.old) does not match fat header (arm64e))
```

**Root Cause:**
- macOS 15 system Ruby (2.6.0) incompatible with older FFI gem
- CocoaPods 1.10.0 uses outdated dependencies
- Known issue affecting many M1/M2/M3 Mac users

**Impact:**
- Cannot install Tailscale iOS SDK via CocoaPods
- App builds without Tailscale SDK (using mock implementation)
- Full Tailscale VPN features unavailable in current build

**Workaround:**
1. Build app without Tailscale pod (current state)
2. Use mock Tailscale authentication and device discovery for testing
3. Localhost preview and API client work via mock Tailscale IP

**Permanent Fix Options:**
- **Option A:** Upgrade to rbenv/rvm with Ruby 3.x
  ```bash
  brew install rbenv
  rbenv install 3.2.0
  rbenv global 3.2.0
  gem install cocoapods
  pod install
  ```
- **Option B:** Use Swift Package Manager instead of CocoaPods
  - Tailscale SDK may not have SPM support yet
  - Requires investigation
- **Option C:** Manual framework integration
  - Download Tailscale.xcframework manually
  - Add to Xcode project as embedded binary

**Next Steps:**
- Attempt Option A (rbenv + Ruby 3.x) for Ty's Mac
- If successful, retry `pod install` and integrate real Tailscale SDK
- Otherwise, defer to future iteration and use mock for now

---

### 2. Tailscale SDK Integration Incomplete 🚧
**Status:** In Progress (Mock Implementation)
**Priority:** High (core feature)

**Issue:**
Full Tailscale iOS SDK not yet integrated due to CocoaPods blocker (see Issue #1).

**Current State:**
- Mock authentication flow (simulates OAuth)
- Mock device discovery (hardcoded Mac device)
- Placeholder VPN manager (uses NEVPNManager without Tailscale backend)

**What Works:**
- ✅ App UI and navigation
- ✅ Onboarding flow (simulated)
- ✅ Settings screens
- ✅ Localhost preview (if Mac IP is correct in mock data)
- ✅ API client (if BuilderOS API running)

**What Doesn't Work:**
- ❌ Real Tailscale VPN connection
- ❌ Actual OAuth with Tailscale servers
- ❌ Dynamic device discovery from Tailscale network
- ❌ Auto-detection of Mac IP address

**Manual Override for Testing:**
Edit `TailscaleConnectionManager.swift` line 194 to hardcode your Mac's Tailscale IP:
```swift
let mockDevices = [
    TailscaleDevice(
        id: "mac-primary",
        hostName: "roth-macbook-pro",
        ipAddress: "YOUR_MAC_TAILSCALE_IP_HERE", // e.g., "100.66.202.6"
        isOnline: true,
        lastSeen: Date(),
        os: "macOS 15.0"
    )
]
```

**Next Steps:**
1. Resolve CocoaPods issue (Issue #1)
2. Integrate real Tailscale SDK
3. Replace mock methods with actual SDK calls
4. Test on physical device with Tailscale network

---

### 3. BuilderOS API Not Yet Implemented 🔨
**Status:** Blocked (external dependency)
**Priority:** High (required for full functionality)

**Issue:**
iOS app calls BuilderOS API endpoints that may not yet exist on Mac server.

**Required Endpoints:**
```
GET  /api/status              → System status (version, uptime, health)
GET  /api/capsules            → List all capsules
GET  /api/capsules/{id}       → Capsule details
GET  /api/capsules/{id}/metrics → Capsule metrics (files, LOC, disk)
POST /api/system/sleep        → Put Mac to sleep
POST /api/system/wake         → Wake Mac (requires Raspberry Pi)
GET  /api/health              → Health check
```

**Current State:**
- API client code is complete in `BuilderOSAPIClient.swift`
- Uses mock data in app for now
- Actual API calls will fail with connection errors

**Testing with Mock Data:**
App functions with mock data:
- Dashboard shows example capsules
- System status displays placeholder metrics
- Capsule details use example data

**Next Steps:**
1. Implement BuilderOS API server endpoints (backend work)
2. Start API server: `/Users/Ty/BuilderOS/api/server_mode.sh`
3. Test API connectivity: `curl http://localhost:8080/api/health`
4. Update iPhone app to call real API instead of mock data

---

## Medium Priority Issues

### 4. Design System Naming Conflicts 🎨
**Status:** Fixed
**Priority:** Medium (usability)

**Issue:**
LocalhostPreviewView referenced `Colors.primary`, `Typography.body`, etc., but design system files used different structures.

**Fix Applied:**
Created `DesignSystem.swift` with unified enums for Colors, Typography, and Spacing that match usage in views.

**Files Modified:**
- ✅ Created: `/src/Utilities/DesignSystem.swift`
- ✅ Provides: `Colors`, `Typography`, `Spacing` enums
- ✅ Compatible with existing view code

**Status:** Resolved ✅

---

### 5. Xcode Project Target Name Mismatch 📦
**Status:** Fixed
**Priority:** Medium (build blocker)

**Issue:**
Podfile referenced target `BuilderOS` but Xcode project has target `BuilderSystemMobile`.

**Fix Applied:**
Updated Podfile to target correct name.

**Files Modified:**
- ✅ `/Podfile` → Changed target from `BuilderOS` to `BuilderSystemMobile`

**Status:** Resolved ✅ (though CocoaPods still fails for different reason)

---

## Low Priority / Future Enhancements

### 6. Wake Mac Feature Not Implemented 💤
**Status:** Future Feature
**Priority:** Low (nice-to-have)

**Issue:**
"Wake Mac" button shows placeholder message. Actual wake-on-LAN requires Raspberry Pi intermediary.

**Reason:**
Macs cannot be woken remotely over internet without local device to send magic packet.

**Architecture:**
1. iPhone → API call to Raspberry Pi (always-on)
2. Raspberry Pi → WoL magic packet to Mac (same local network)
3. Mac wakes up

**Current Implementation:**
- Button shows alert: "Wake feature requires Raspberry Pi intermediary. See documentation for setup."
- API endpoint `/api/system/wake` exists but is placeholder

**Next Steps:**
- Defer to Phase 2
- Document Raspberry Pi WoL relay setup
- Implement API endpoint when hardware available

---

### 7. No Widget or Lock Screen Integration 📱
**Status:** Future Feature
**Priority:** Low (enhancement)

**Issue:**
App does not yet have iOS widgets, lock screen widgets, or Siri shortcuts.

**Potential Features:**
- Home screen widget: System status at-a-glance
- Lock screen widget: Connection status badge
- Siri shortcuts: "Hey Siri, sleep my Mac"
- Apple Watch companion app

**Next Steps:**
- Roadmap for Q1 2026 (Phase 2)
- Requires WidgetKit and App Intents framework

---

### 8. No Push Notifications 🔔
**Status:** Future Feature
**Priority:** Low (enhancement)

**Issue:**
App doesn't receive push notifications for system alerts or capsule events.

**Use Cases:**
- Capsule build completed
- System health alert
- n8n workflow triggered
- API server offline

**Next Steps:**
- Implement APNs (Apple Push Notification service)
- BuilderOS backend sends notifications to iPhone
- Roadmap for Q2 2026 (Phase 3)

---

## Testing Limitations

### 9. Physical Device Required for Full Testing 📲
**Status:** Expected Limitation
**Priority:** N/A (iOS Simulator limitation)

**Issue:**
iOS Simulator cannot test:
- Tailscale VPN (requires NetworkExtension framework)
- Keychain storage (different implementation)
- True network connectivity
- Device-specific performance

**Workaround:**
- Must use physical iPhone for testing (iOS 17+ required)
- Sideload via Xcode (see SIDELOAD_GUIDE.md)

---

### 10. App Expires After 7 Days (Free Developer Account) ⏰
**Status:** Expected Limitation
**Priority:** N/A (Apple policy)

**Issue:**
Apps signed with free Apple Developer account expire after 7 days.

**Workaround:**
- Rebuild and reinstall weekly
- OR upgrade to paid Apple Developer account ($99/year) for 1-year validity

**Not a Blocker:** Acceptable for personal testing.

---

## Build & Configuration Issues

### 11. Info.plist Hardcoded Tailscale IP 🌐
**Status:** Configuration Required
**Priority:** Medium (manual setup)

**Issue:**
`Info.plist` has hardcoded exception for Mac Tailscale IP `100.66.202.6` to allow HTTP over Tailscale VPN.

**Location:** `/src/Info.plist` lines 64-70

**Problem:**
If Ty's Mac has a different Tailscale IP, localhost preview will fail due to App Transport Security.

**Fix:**
1. Check Mac's Tailscale IP: `tailscale ip -4`
2. Update Info.plist NSExceptionDomains key with correct IP
3. Rebuild app

**Future Enhancement:**
- Dynamic ATS exception configuration
- Or use HTTPS for localhost (self-signed cert)

---

## Summary

**Ready for Tonight's Testing:** ✅ YES (with limitations)

**What Will Work:**
- ✅ App builds and installs on iPhone
- ✅ Onboarding UI flow (mock auth)
- ✅ Tab navigation (Dashboard, Preview, Settings)
- ✅ Localhost preview (if API server running and IP correct)
- ✅ Settings screens and UI
- ✅ API key configuration (Keychain storage)
- ✅ Sleep Mac button (if API implemented)
- ✅ Light/Dark mode
- ✅ Pull-to-refresh

**What Won't Work:**
- ❌ Real Tailscale VPN connection
- ❌ Real OAuth authentication
- ❌ Dynamic device discovery
- ❌ Live capsule data (unless API implemented)
- ❌ Wake Mac feature
- ❌ System metrics (unless API implemented)

**Recommended Testing Approach:**
1. Build and install app on iPhone (see SIDELOAD_GUIDE.md)
2. Test UI/UX and navigation thoroughly
3. Verify localhost preview with running dev server
4. Test API key configuration and Keychain
5. Document any crashes or UI issues
6. Defer real Tailscale testing to next iteration

**Next Iteration Priorities:**
1. Fix CocoaPods / integrate Tailscale SDK
2. Implement BuilderOS API endpoints
3. Test on real Tailscale network
4. Replace mock data with live API calls

---

**Status Legend:**
- ⚠️ Blocked - Cannot proceed without fix
- 🚧 In Progress - Work underway
- 🔨 External Dependency - Waiting on other work
- 🎨 Fixed - Issue resolved
- 💤 Future Feature - Planned for later
- 📱 Expected Limitation - Not a bug
- 🌐 Configuration - Requires manual setup

---

**Questions or Issues?** See capsule `CLAUDE.md` or create issue in repo.
