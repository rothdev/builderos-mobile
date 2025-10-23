# BuilderOS iOS App - Tonight's Quick Start

**Goal:** Get the app on your iPhone and test core features tonight!

---

## 5-Minute Setup

### 1. Open Xcode Project (1 min)
```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile
open src/BuilderOS.xcodeproj
```

### 2. Code Signing Setup (2 min)
1. Click "BuilderSystemMobile" in project navigator
2. Select "BuilderSystemMobile" target
3. Click "Signing & Capabilities" tab
4. ✅ Automatically manage signing
5. Team: Select your Apple ID
6. Bundle ID: Should auto-generate or use `com.builderos.ios`

### 3. Connect iPhone & Build (2 min)
1. Plug iPhone into Mac via USB
2. Unlock iPhone, tap "Trust This Computer"
3. In Xcode, select your iPhone from device dropdown (top toolbar)
4. Click Run button (▶) or press Cmd+R
5. Wait ~30 seconds for build to complete

---

## First Launch on iPhone

### Trust Developer Certificate
1. App icon appears on iPhone home screen
2. Tap it → Shows "Untrusted Developer" message
3. iPhone Settings → General → VPN & Device Management
4. Under "Developer App", tap your email
5. Tap "Trust [Your Name]"
6. Confirm "Trust"

### Grant Permissions
1. Launch BuilderOS app
2. Allow "Local Network Access" → Required ✅
3. Allow "VPN Configuration" → Required ✅

---

## Quick Feature Test Checklist

**Onboarding (Mock Auth):**
- [ ] Welcome screen appears
- [ ] Tap "Get Started"
- [ ] Tap "Sign in with Tailscale" (mock flow)
- [ ] See "Found your Mac!" with IP address
- [ ] Tap "Continue to BuilderOS"

**Dashboard Tab:**
- [ ] Connection status shows "Connected"
- [ ] System status card visible (mock data)
- [ ] Capsule grid shows example capsules
- [ ] Pull down to refresh works
- [ ] Tap a capsule → Detail screen slides in

**Preview Tab:**
- [ ] Quick links for common ports visible
- [ ] Tap "React/Next.js" button (port 3000)
  - If you have React dev server running → WebView loads it ✅
  - If not running → Connection error (expected)
- [ ] Try custom port input and "Go" button
- [ ] WebView can scroll and interact with content

**Settings Tab:**
- [ ] Tailscale section shows "Connected"
- [ ] Devices list shows Mac and iPhone
- [ ] Tap "Add API Key" → Modal sheet appears
- [ ] Enter fake key → Saves to Keychain
- [ ] Status changes to "Configured" (green)
- [ ] Power control buttons visible (Sleep/Wake)
- [ ] About section shows version "1.0.0"

**General UX:**
- [ ] Tab bar navigation smooth
- [ ] Switch to Dark Mode → All colors adapt
- [ ] Rotate to landscape → Layout adjusts
- [ ] Force quit and relaunch → State preserved

---

## What to Expect (Mock Data)

**✅ Will Work:**
- UI and navigation
- Onboarding flow (simulated)
- Localhost preview (if dev server running)
- API key configuration
- Light/Dark mode
- All animations and transitions

**❌ Won't Work (Expected):**
- Real Tailscale VPN connection (mock)
- Live capsule data from Mac (mock)
- System metrics (mock)
- Wake Mac feature (placeholder)
- OAuth authentication (mock)

---

## Optional: Test with Real Dev Server

**If you want to test localhost preview:**

### Start React Dev Server (Example)
```bash
# In any React project
npm start
# OR
yarn start

# Server runs on http://localhost:3000
```

### Start BuilderOS API (If Implemented)
```bash
cd /Users/Ty/BuilderOS/api
./server_mode.sh

# API runs on http://localhost:8080
```

### In iOS App
1. Go to Preview tab
2. Tap "React/Next.js" quick link (port 3000)
3. Should load your React app in WebView!
4. Try "BuilderOS API" (port 8080) if API running

**Important:** Ensure Mac Tailscale IP in mock code matches reality:
- Check: `tailscale ip -4` (e.g., 100.66.202.6)
- If different, update `TailscaleConnectionManager.swift` line 198
- Rebuild app

---

## Troubleshooting Fast Fixes

**App Won't Build:**
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Restart Xcode
- Retry

**iPhone Not Showing in Xcode:**
- Reconnect USB cable
- Unlock iPhone
- Trust computer again

**App Crashes on Launch:**
- Check Xcode console for error message
- Verify iOS version is 17+
- See KNOWN_ISSUES.md

**"Untrusted Developer" Won't Go Away:**
- Settings → General → VPN & Device Management
- Must tap your email under "Developer App" section
- Then tap "Trust"

---

## Tonight's Testing Goals

**Primary:** Verify app is stable and navigable
- ✅ No crashes during basic usage
- ✅ All screens accessible
- ✅ Animations smooth
- ✅ Dark mode works

**Secondary:** Test localhost preview
- ✅ WebView loads content
- ✅ Quick links functional
- ✅ Custom port input works

**Nice to Have:** API integration
- ✅ API key configuration works
- ✅ Sleep Mac button (if API exists)
- ✅ Live data (if API implemented)

---

## After Testing

**Report Back:**
- Any crashes or errors?
- UI/UX feedback?
- Features that surprised you (good or bad)?
- Anything confusing or broken?

**Document Issues:**
- Add to KNOWN_ISSUES.md
- Or just tell me verbally!

---

## Full Documentation (For Later)

When you have more time, check out:
- **TEST_PLAN.md** - Comprehensive testing checklist
- **SIDELOAD_GUIDE.md** - Detailed build/install instructions
- **KNOWN_ISSUES.md** - All limitations and blockers
- **CLAUDE.md** - Capsule overview and architecture

---

**Ready to test! Let's see this app on your iPhone.** 🚀

**Estimated Time Tonight:** 15-20 minutes (build + quick test)
