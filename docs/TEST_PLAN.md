# BuilderOS iOS App - Comprehensive Test Plan

## Overview
This test plan covers all features of the BuilderOS iOS companion app. Testing should be performed on a physical iOS device (iPhone or iPad) running iOS 17+.

**Test Environment:**
- Device: iPhone (iOS 17+ required)
- Mac: macOS with Tailscale installed and BuilderOS API running
- Network: Both devices on Tailscale network

---

## Pre-Test Setup

### Mac Setup
1. ✅ Tailscale installed and running: `brew install tailscale` → `sudo tailscale up`
2. ✅ Note Mac's Tailscale IP: `tailscale ip -4` (e.g., 100.66.202.6)
3. ✅ BuilderOS API server running: `cd /Users/Ty/BuilderOS/api && ./server_mode.sh`
4. ✅ Verify API is accessible: `curl http://localhost:8080/api/health`

### iOS App Setup
1. ✅ Build app in Xcode with valid code signing
2. ✅ Install on iPhone via Xcode (Cmd+R or sideload .ipa)
3. ✅ Grant required permissions (VPN, local network)

---

## Test Categories

### 1. Onboarding & Authentication

#### Test 1.1: First Launch Experience
- **Steps:**
  1. Fresh install (delete app if testing again)
  2. Launch app
  3. Observe onboarding flow
- **Expected:**
  - Welcome screen with BuilderOS branding appears
  - "Get Started" button is visible and functional
  - Smooth transitions between onboarding steps
- **Pass Criteria:** ✅ Onboarding UI displays correctly

#### Test 1.2: Tailscale Authentication
- **Steps:**
  1. Tap "Get Started"
  2. Proceed to Tailscale sign-in step
  3. Tap "Sign in with Tailscale"
  4. Complete OAuth flow (browser or in-app)
- **Expected:**
  - OAuth flow opens (GitHub/Google/Microsoft/Email)
  - Authentication completes successfully
  - Returns to app with authenticated state
- **Pass Criteria:** ✅ Authentication succeeds
- **Known Limitation:** Mock authentication is used (Tailscale SDK integration pending)

#### Test 1.3: Mac Discovery
- **Steps:**
  1. After authentication, observe device discovery
  2. Wait for Mac to be found on Tailscale network
- **Expected:**
  - Progress indicator shows "Finding your Mac..."
  - Mac appears with hostname and Tailscale IP
  - Checkmark and "Found your Mac!" message
- **Pass Criteria:** ✅ Mac is discovered automatically
- **Known Limitation:** Mock device list is used (Tailscale SDK integration pending)

#### Test 1.4: Onboarding Completion
- **Steps:**
  1. Tap "Continue to BuilderOS" after Mac discovery
- **Expected:**
  - Transition to main dashboard
  - User preference saved (no onboarding on next launch)
- **Pass Criteria:** ✅ Dashboard loads successfully

---

### 2. Dashboard Functionality

#### Test 2.1: Connection Status Card
- **Steps:**
  1. View dashboard connection status card
  2. Verify displayed information
- **Expected:**
  - Green checkmark icon with "Connected" status
  - Mac hostname displayed (e.g., "Roth Macbook Pro")
  - Mac Tailscale IP shown (e.g., "100.66.202.6")
  - "Tailscale VPN" badge with lock icon
- **Pass Criteria:** ✅ Connection info accurate

#### Test 2.2: System Status Card
- **Steps:**
  1. View system status card on dashboard
  2. Check displayed metrics
- **Expected:**
  - Health status indicator (green/orange/red)
  - Version number (e.g., "2.1.0")
  - Uptime formatted correctly (e.g., "68h 45m")
  - Capsule count (active vs. total)
  - Services count (running vs. total)
- **Pass Criteria:** ✅ System metrics display correctly
- **Known Limitation:** Mock data is used (API integration pending)

#### Test 2.3: Capsule Grid Display
- **Steps:**
  1. Scroll to capsules section
  2. View capsule cards
- **Expected:**
  - Capsules displayed in 2-column grid
  - Each card shows: icon, name, status badge, tags
  - Status badge color matches state (green=active, blue=dev, orange=testing, gray=archived)
  - Tags limited to 2 visible, "+X" for overflow
- **Pass Criteria:** ✅ Capsules render correctly
- **Known Limitation:** Mock capsule data is used

#### Test 2.4: Pull-to-Refresh
- **Steps:**
  1. Pull down on dashboard to refresh
  2. Wait for refresh to complete
- **Expected:**
  - Refresh animation appears
  - System status and capsules refresh
  - Refresh indicator disappears
- **Pass Criteria:** ✅ Refresh mechanism works

---

### 3. Localhost Preview Feature

#### Test 3.1: Preview Tab Navigation
- **Steps:**
  1. Tap "Preview" tab at bottom
  2. View localhost preview interface
- **Expected:**
  - Connection status header shows Mac IP
  - Quick links for common ports displayed (React, n8n, API, etc.)
  - Custom port input field visible
  - Empty state message: "Preview Localhost"
- **Pass Criteria:** ✅ Preview tab UI renders correctly

#### Test 3.2: Quick Link Buttons
- **Steps:**
  1. Test each quick link button:
     - React/Next.js (port 3000)
     - n8n Workflows (port 5678)
     - BuilderOS API (port 8080)
     - Vite/Vue (port 5173)
     - Flask/Django (port 5000)
  2. Tap any quick link
- **Expected:**
  - Button highlights (blue background) when active
  - WebView loads URL: `http://{mac-tailscale-ip}:{port}`
  - Loading spinner appears during load
  - Web content renders if server is running
  - Error if server not running on that port
- **Pass Criteria:** ✅ Quick links work for running servers

#### Test 3.3: Custom Port Input
- **Steps:**
  1. Enter custom port number (e.g., 3001)
  2. Tap "Go" button
- **Expected:**
  - WebView loads custom port
  - URL bar shows correct address
  - Content displays if server running
- **Pass Criteria:** ✅ Custom port input functional

#### Test 3.4: WebView Interaction
- **Steps:**
  1. Load a dev server (e.g., React on port 3000)
  2. Interact with web content:
     - Scroll
     - Tap links
     - Use back/forward gestures
- **Expected:**
  - Web content fully interactive
  - Swipe gestures navigate back/forward
  - Loading indicator shows during navigation
  - Responsive web design adapts to iPhone screen
- **Pass Criteria:** ✅ WebView behaves like Safari

#### Test 3.5: Preview Error Handling
- **Steps:**
  1. Tap quick link for port with no running server
  2. Try custom port that's not in use
- **Expected:**
  - Alert appears: "Connection Error"
  - Clear error message displayed
  - Can dismiss alert and retry
- **Pass Criteria:** ✅ Error states handled gracefully

---

### 4. Settings & Configuration

#### Test 4.1: Settings Tab Navigation
- **Steps:**
  1. Tap "Settings" tab
  2. View settings screen
- **Expected:**
  - Tailscale connection section visible
  - API key section visible
  - Power control section visible
  - About section with version info
- **Pass Criteria:** ✅ Settings UI complete

#### Test 4.2: Tailscale Connection Status
- **Steps:**
  1. View Tailscale connection section
  2. Check displayed information
- **Expected:**
  - Connection status (Connected/Disconnected)
  - Green/red indicator circle
  - Devices list shows Mac and current iPhone
  - Mac has checkmark badge
  - Online indicators (green dots)
- **Pass Criteria:** ✅ Connection info accurate

#### Test 4.3: Tailscale Sign Out
- **Steps:**
  1. Tap "Sign Out of Tailscale" (red button)
  2. Confirm in alert
- **Expected:**
  - Confirmation alert appears
  - After confirm, returns to onboarding
  - Credentials cleared from Keychain
  - VPN disconnects
- **Pass Criteria:** ✅ Sign out works correctly

#### Test 4.4: API Key Configuration
- **Steps:**
  1. Tap "Add" or "Update" API key button
  2. Enter API key in secure field
  3. Tap "Save"
- **Expected:**
  - Sheet modal appears with secure input
  - API key field is password-protected (dots)
  - Help text shows where to generate key
  - Save button enabled only when key entered
  - After save, status shows "Configured" (green)
- **Pass Criteria:** ✅ API key storage works
- **Security:** ✅ Key stored in iOS Keychain (not visible in UI)

#### Test 4.5: Sleep Mac Button
- **Steps:**
  1. Tap "Sleep Mac" button in Power Control section
  2. Confirm action
- **Expected:**
  - Loading spinner appears during request
  - API call sent to: `POST http://{mac-ip}:8080/api/system/sleep`
  - Success alert: "Mac is going to sleep..."
  - Mac actually goes to sleep (verify on Mac)
- **Pass Criteria:** ✅ Sleep command works
- **Known Limitation:** Requires BuilderOS API implementation

#### Test 4.6: Wake Mac Button (Placeholder)
- **Steps:**
  1. Tap "Wake Mac" button
- **Expected:**
  - Alert appears with instructions
  - Message: "Wake feature requires Raspberry Pi intermediary. See documentation for setup."
  - Button disabled if not connected or no API key
- **Pass Criteria:** ✅ Wake button shows placeholder message
- **Future Feature:** Requires Raspberry Pi WoL relay

#### Test 4.7: About Section
- **Steps:**
  1. View About section
  2. Check version/build info
  3. Tap Documentation link
- **Expected:**
  - Version shows: "1.0.0"
  - Build shows: "1"
  - Documentation link opens external browser
- **Pass Criteria:** ✅ About info correct

---

### 5. Navigation & UX

#### Test 5.1: Tab Bar Navigation
- **Steps:**
  1. Switch between Dashboard, Preview, Settings tabs
  2. Navigate back and forth multiple times
- **Expected:**
  - Smooth transitions between tabs
  - Each tab maintains its state
  - Tab icons highlight correctly
  - No lag or jank
- **Pass Criteria:** ✅ Tab navigation smooth

#### Test 5.2: Capsule Detail Navigation
- **Steps:**
  1. On Dashboard, tap any capsule card
  2. View detail screen
  3. Tap back to return to Dashboard
- **Expected:**
  - Detail screen slides in from right
  - Shows full capsule information
  - Back button returns to Dashboard
  - Dashboard scroll position preserved
- **Pass Criteria:** ✅ Navigation stack works

#### Test 5.3: Light/Dark Mode Adaptation
- **Steps:**
  1. Test app in Light Mode (Settings → Display)
  2. Switch to Dark Mode
  3. View all screens in both modes
- **Expected:**
  - All colors adapt to Light/Dark mode
  - Text remains readable
  - Cards use .ultraThinMaterial (glassmorphic)
  - Status indicators visible in both modes
- **Pass Criteria:** ✅ Both modes look good

#### Test 5.4: Orientation Support (iPhone)
- **Steps:**
  1. Rotate iPhone to landscape
  2. View each tab in landscape
- **Expected:**
  - Portrait mode: default orientation
  - Landscape mode: layout adapts gracefully
  - All content remains accessible
- **Pass Criteria:** ✅ Landscape orientation works

#### Test 5.5: iPad Support (if tested on iPad)
- **Steps:**
  1. Install on iPad
  2. View in portrait and landscape
  3. Test Split View and Slide Over
- **Expected:**
  - Larger screen utilizes space well
  - Grid columns increase on iPad
  - Safe areas respected
  - Multitasking modes work
- **Pass Criteria:** ✅ iPad experience good

---

### 6. Performance & Stability

#### Test 6.1: Launch Time
- **Steps:**
  1. Force quit app
  2. Launch from home screen
  3. Measure time to dashboard
- **Expected:**
  - Cold launch: <2 seconds to dashboard
  - Warm launch: <0.5 seconds
  - No lag or stutter
- **Pass Criteria:** ✅ Launch performance acceptable

#### Test 6.2: Memory Usage
- **Steps:**
  1. Use app for extended period
  2. Navigate between tabs repeatedly
  3. Load multiple localhost servers in Preview tab
  4. Monitor memory in Xcode Instruments (if available)
- **Expected:**
  - Memory usage stays under 100MB
  - No memory leaks
  - No crashes due to OOM
- **Pass Criteria:** ✅ Stable memory usage

#### Test 6.3: Network Error Handling
- **Steps:**
  1. Disconnect from Tailscale VPN
  2. Try to use app features
  3. Reconnect to Tailscale
- **Expected:**
  - Graceful error messages
  - Retry mechanisms work
  - App recovers when connection restored
- **Pass Criteria:** ✅ Network errors handled well

#### Test 6.4: Background/Foreground Transition
- **Steps:**
  1. Use app normally
  2. Switch to another app (backgrounding)
  3. Return to BuilderOS app
- **Expected:**
  - State preserved correctly
  - VPN reconnects if needed
  - Data refreshes on return
  - No crashes
- **Pass Criteria:** ✅ Background handling good

---

### 7. Accessibility

#### Test 7.1: VoiceOver Support
- **Steps:**
  1. Enable VoiceOver (Settings → Accessibility)
  2. Navigate app with VoiceOver
  3. Test all buttons and controls
- **Expected:**
  - All UI elements have labels
  - Tab bar announces correctly
  - Buttons have descriptive actions
  - Card content read in logical order
- **Pass Criteria:** ✅ VoiceOver usable

#### Test 7.2: Dynamic Type Support
- **Steps:**
  1. Change text size (Settings → Display → Text Size)
  2. Test smallest and largest sizes
  3. View all screens
- **Expected:**
  - Text scales appropriately
  - Layout doesn't break
  - Touch targets remain 44pt minimum
  - All content readable
- **Pass Criteria:** ✅ Dynamic Type works

#### Test 7.3: High Contrast Mode
- **Steps:**
  1. Enable Increase Contrast (Settings → Accessibility)
  2. View all screens
- **Expected:**
  - Colors have sufficient contrast
  - Status indicators remain visible
  - Text remains readable
- **Pass Criteria:** ✅ High contrast usable

---

### 8. Security & Privacy

#### Test 8.1: Keychain Storage
- **Steps:**
  1. Save API key in Settings
  2. Force quit app
  3. Relaunch and check API key status
- **Expected:**
  - API key persists across launches
  - Key not visible in UI (secure field)
  - Stored securely in iOS Keychain
- **Pass Criteria:** ✅ Keychain works

#### Test 8.2: Network Security
- **Steps:**
  1. Monitor network traffic (Wireshark/Charles Proxy)
  2. Verify all API calls go through Tailscale
- **Expected:**
  - API calls to Tailscale IPs only (100.x.x.x)
  - HTTP over encrypted VPN tunnel
  - No external API calls (except Tailscale OAuth)
- **Pass Criteria:** ✅ Network security correct

#### Test 8.3: Permissions
- **Steps:**
  1. Fresh install
  2. Check permission prompts
- **Expected:**
  - Local network permission requested
  - VPN permission requested (NetworkExtension)
  - Clear explanations in prompts
- **Pass Criteria:** ✅ Permissions appropriate

---

## Test Summary Template

### Test Session: [Date]
**Tester:** [Name]
**Device:** [iPhone model, iOS version]
**Build:** [Version, build number]

| Category | Test | Result | Notes |
|----------|------|--------|-------|
| Onboarding | 1.1 First Launch | ✅ / ❌ | |
| Onboarding | 1.2 Authentication | ✅ / ❌ | |
| ... | ... | ... | ... |

**Overall Assessment:**
[Summary of test session]

**Blockers:**
[Any critical issues preventing testing]

**Next Steps:**
[Actions needed before re-test]

---

## Known Limitations (Current Build)

1. **Tailscale SDK Integration:** Mock authentication and device discovery (full SDK pending)
2. **API Integration:** Mock capsule data (requires BuilderOS API running)
3. **CocoaPods Dependency:** Tailscale pod installation requires Ruby gem fix
4. **Wake Mac Feature:** Placeholder only (requires Raspberry Pi WoL relay)
5. **Device Testing Only:** Must test on physical iPhone (Simulator lacks VPN support)

---

## Testing Priorities

### Must Test (Critical Path)
- ✅ App launches without crash
- ✅ Onboarding flow completes
- ✅ Dashboard displays
- ✅ Tab navigation works
- ✅ Settings screen accessible
- ✅ Light/Dark mode works

### Should Test (Core Features)
- ✅ Localhost preview WebView
- ✅ Quick link buttons
- ✅ Custom port input
- ✅ API key configuration
- ✅ Sleep Mac button (if API available)
- ✅ Pull-to-refresh

### Nice to Test (Polish)
- ✅ Animations smooth
- ✅ VoiceOver support
- ✅ Dynamic Type
- ✅ iPad layout
- ✅ Landscape orientation
- ✅ Memory performance

---

**Ready for Testing:** Tonight on Ty's iPhone!
