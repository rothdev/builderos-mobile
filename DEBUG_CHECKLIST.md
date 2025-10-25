# 🔍 Debug Checklist - Black Screen Issue

## Changes Made
Added comprehensive debug logging throughout the app initialization and rendering pipeline.

## What to Do Now

### 1. Run from Xcode (Cmd+R)
- **Target:** iPhone 17 Simulator or your physical iPhone
- **Build:** Should succeed (just verified)
- **Launch:** App should start

### 2. Watch the Xcode Console Output

Look for these log messages in order:

```
🟢 APP: BuilderOSApp init() starting
🟢 APP: Development mode - onboarding skipped
🟢 APP: BuilderOSApp init() complete
🟢 APP: Building WindowGroup, hasCompletedOnboarding=true
🟢 APP: Showing MainContentView
🟢 API: BuilderOSAPIClient init() starting
🟢 API: BuilderOSAPIClient init() complete
🟢 MAIN: MainContentView body rendering, selectedTab=0
🟢 DASH: DashboardView body rendering, isLoading=false, capsules.count=0
🟢 TERM: UnifiedTerminalView body rendering
🟢 PREVIEW: LocalhostPreviewView body rendering
🟢 SETTINGS: SettingsView body rendering
🟢 API: Loading saved configuration
🟢 API: Configuration loaded, hasAPIKey=false
```

### 3. Identify Where Execution Stops

**If you see:**
- ✅ All logs above → Views are rendering, issue is visual (colors, layout)
- ❌ Stops at "APP: Building WindowGroup" → SwiftUI scene creation crash
- ❌ Stops at "MAIN: MainContentView" → TabView or child view crash
- ❌ Stops at "DASH: DashboardView" → Dashboard rendering crash
- ❌ No logs at all → App crashes before logging starts (Info.plist issue?)

### 4. Check for Errors

Look for:
- ❌ **Red error messages** (crash/exception)
- ⚠️ **Yellow warnings** (constraint issues, deprecated APIs)
- 🔴 **SIGABRT** or **SIGSEGV** (memory access crash)
- 🟡 **Thread 1: Fatal error** (Swift assertion/precondition)

### 5. Look for Silent Issues

If logs appear but screen is black:
- Check if `Color.terminalDark` is actually visible (not transparent)
- Check if NavigationStack/TabView is sized correctly
- Check if safe area is consuming entire screen

### 6. Quick Visual Test - Diagnostic View

If screen is still black after seeing all logs, swap to the diagnostic view:

**Edit BuilderOSApp.swift** (line 40):
```swift
// BEFORE (current):
MainContentView()
    .environmentObject(apiClient)

// AFTER (diagnostic):
DiagnosticView()
```

**What this does:**
- Shows bright green screen with red text
- Tests basic SwiftUI rendering without any dependencies
- If you see this → MainContentView/TabView is the problem
- If you DON'T see this → SwiftUI system rendering is broken

**Don't forget to change it back after testing!**

## Report Back With

1. **Last log line you see** (exact text)
2. **Any error messages** (copy full text)
3. **App behavior:**
   - Black screen immediately?
   - White flash then black?
   - Anything visible at all (status bar, notch outline)?
4. **Device info:**
   - Simulator or physical device?
   - iOS version?

## Possible Root Causes

Based on where logs stop:

| Last Log Seen | Likely Cause | Fix |
|---------------|--------------|-----|
| "APP: init complete" | Scene creation crash | Check @StateObject, @AppStorage |
| "APP: Showing MainContentView" | TabView crash | Check child view inits |
| "DASH: body rendering" | DashboardView crash | Check Color definitions, API calls |
| All logs present | Visual rendering issue | Colors are transparent/wrong |
| No logs at all | App crashes before main | Info.plist, bundle ID, entitlements |

---

**Next Steps:** Run app, copy console output, report findings.
