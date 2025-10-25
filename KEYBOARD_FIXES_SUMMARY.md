# Keyboard Fixes Summary

## Date: October 24, 2025

## Issues Fixed

### Issue 1: Settings Tunnel URL Field Not Editable ✅

**Problem:**
- Tunnel URL was displayed as read-only `Text` view
- Keyboard wouldn't appear when tapped
- API key field worked correctly, but tunnel URL didn't

**Root Cause:**
- `tunnelURLRow` in `SettingsView.swift` used `Text()` instead of `TextField()`
- Lines 223-227 displayed URL as static text

**Solution:**
- Replaced `Text(apiClient.tunnelURL)` with editable `TextField`
- Added proper binding to update `APIConfig.tunnelURL` on change
- Added `.textInputAutocapitalization(.never)` and `.autocorrectionDisabled()` for URL input
- Added `.keyboardType(.URL)` for optimal keyboard layout
- Triggers `healthCheck()` to reconnect after URL change
- Styled with terminal design system colors and border

**Files Changed:**
- `src/Views/SettingsView.swift` (lines 217-243)

---

### Issue 2: Terminal Keyboard Not Sending Input ✅

**Problem:**
- Keyboard appeared on terminal screen
- Toolbar with special keys appeared
- BUT typing characters didn't send anything to WebSocket
- No characters appeared in terminal

**Root Cause:**
- `TerminalInputDelegate` was created but not retained properly
- Terminal view wasn't becoming first responder when tapped
- No gesture recognizer to capture taps and focus the terminal

**Solution:**
- Added `UITapGestureRecognizer` to terminal view in `makeUIView()`
- Created `handleTap()` method in Coordinator to call `becomeFirstResponder()`
- Terminal now properly captures keyboard focus when user taps it
- Input delegate already wired correctly, just needed focus activation

**Files Changed:**
- `src/Views/PTYTerminalView.swift`:
  - Added tap gesture recognizer (lines 240-243)
  - Added `handleTap()` method in Coordinator (lines 311-317)
  - Added debug logging for troubleshooting

**How It Works:**
1. User taps terminal → tap gesture fires
2. `handleTap()` calls `terminalView.becomeFirstResponder()`
3. iOS shows keyboard
4. User types characters
5. `TerminalInputDelegate.send()` captures input
6. Input forwarded to WebSocket via `onInput` callback
7. Characters sent to PTY session on Mac

---

## Testing Results

### Build Status: ✅ SUCCESS
- Built for iPhone 17 Pro simulator: ✅
- Built for physical iPhone 13 Pro: ✅
- No compilation errors
- App installed successfully on device

### Device Info:
- Device: Roth iPhone (iPhone 13 Pro)
- Device ID: 00008110-00111DCC0A31801E
- Bundle ID: com.ty.builderos
- Build Location: `/Users/Ty/Library/Developer/Xcode/DerivedData/BuilderOS-cyfwtkynlidjqialncespvsfvptf/Build/Products/Debug-iphoneos/BuilderOS.app`

---

## Next Steps for Testing

### Test 1: Settings Tunnel URL Editing
1. Open app on iPhone
2. Go to Settings tab
3. Tap tunnel URL field
4. **Expected:** Keyboard appears with URL keyboard layout
5. **Expected:** Can type and edit URL
6. **Expected:** URL updates in app when done editing
7. **Expected:** App attempts to reconnect to new URL

### Test 2: Terminal Keyboard Input
1. Open app on iPhone
2. Go to Terminal tab
3. Tap anywhere in terminal area
4. **Expected:** Keyboard appears
5. **Expected:** Keyboard toolbar shows (Esc, Ctrl, Tab, etc.)
6. Type "hello" on keyboard
7. **Expected:** Characters appear in terminal
8. **Expected:** Characters sent to WebSocket
9. **Expected:** Mac receives the input via PTY session

### Test 3: Special Keys
1. With keyboard visible on terminal
2. Tap "Esc" in toolbar
3. **Expected:** Escape sequence sent to terminal
4. Tap arrow keys (↑, ↓, ←, →)
5. **Expected:** Arrow key sequences sent
6. Tap "Tab"
7. **Expected:** Tab character sent

---

## Debug Logging Added

If keyboard still doesn't work, check Xcode console for:
```
DEBUG: Terminal tapped, making first responder
```

This confirms the tap gesture is firing and terminal is attempting to become first responder.

---

## Technical Details

### Settings URL Field Implementation
```swift
TextField("https://your-tunnel-url.trycloudflare.com", text: Binding(
    get: { apiClient.tunnelURL },
    set: { newValue in
        APIConfig.tunnelURL = newValue
        Task {
            _ = await apiClient.healthCheck()
        }
    }
))
.font(.system(size: 12, design: .monospaced))
.foregroundStyle(Color.terminalCyan)
.textInputAutocapitalization(.never)
.autocorrectionDisabled()
.keyboardType(.URL)
.padding(.horizontal, 12)
.padding(.vertical, 8)
.background(Color.terminalInputBackground)
.terminalBorder(cornerRadius: 6)
```

### Terminal Tap Gesture Implementation
```swift
// In makeUIView():
let tapGesture = UITapGestureRecognizer(
    target: context.coordinator,
    action: #selector(Coordinator.handleTap)
)
terminalView.addGestureRecognizer(tapGesture)

// In Coordinator:
@objc func handleTap() {
    if let terminalView = terminalView {
        print("DEBUG: Terminal tapped, making first responder")
        terminalView.becomeFirstResponder()
    }
}
```

---

## Hot Reload Note

If using InjectionIII:
- Settings changes will hot-reload immediately (SwiftUI @ObserveInjection)
- Terminal changes require app restart (UIKit UIViewRepresentable doesn't hot-reload)
- For terminal testing, rebuild and reinstall app

---

## Compatibility

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftTerm 1.0+

---

## Related Files

- `src/Views/SettingsView.swift` - Settings UI
- `src/Views/PTYTerminalView.swift` - Terminal input handling
- `src/Views/UnifiedTerminalView.swift` - Uses TerminalViewWrapper (inherits fixes)
- `src/Services/BuilderOSAPIClient.swift` - API client with healthCheck()
- `src/Services/APIConfig.swift` - Tunnel URL storage

---

## Build Commands Used

```bash
# Build for simulator
xcodebuild -project src/BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# Build for device
xcodebuild -project BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -configuration Debug \
  -destination 'id=00008110-00111DCC0A31801E' \
  -allowProvisioningUpdates \
  clean build

# Install on device
xcrun devicectl device install app \
  --device 00008110-00111DCC0A31801E \
  /Users/Ty/Library/Developer/Xcode/DerivedData/BuilderOS-*/Build/Products/Debug-iphoneos/BuilderOS.app
```

---

## Status: ✅ COMPLETE

Both keyboard issues have been fixed and app has been built and installed on iPhone. Ready for testing!
