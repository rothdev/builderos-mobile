# InjectionIII Hot Reloading Setup

**Purpose:** Enable instant code updates without rebuilding the app (30x faster iteration)

**Time to setup:** 5-10 minutes

---

## Step 1: Add Swift Package Dependency

1. **Open Xcode Project:**
   ```bash
   open BuilderSystemMobile.xcodeproj
   ```

2. **Add Package:**
   - File → Add Package Dependencies
   - Enter: `https://github.com/krzysztofzablocki/Inject`
   - Version: Up to Next Major (recommended)
   - Click "Add Package"
   - Select target: `BuilderSystemMobile`
   - Click "Add Package"

---

## Step 2: Update View Files

Add two lines to each SwiftUI View:

```swift
import SwiftUI
import Inject  // ← Add this import

struct DashboardView: View {
    @ObserveInjection var inject  // ← Add this property

    var body: some View {
        VStack {
            // ... your view code
        }
        .enableInjection()  // ← Add this modifier at the end
    }
}
```

### Views to Update:

**Essential (high-traffic views):**
- ✅ `MainContentView.swift`
- ✅ `DashboardView.swift` (in src/Views/)
- ✅ `CapsuleListView.swift`
- ✅ `TerminalTabView.swift` / `MultiTabTerminalView.swift`
- ✅ `SettingsView.swift`
- ✅ `ChatView.swift`

**Component views (update as needed):**
- `CapsuleRowView.swift`
- `EmptyStateView.swift`
- `FloatingActionButton.swift`
- `OnboardingView.swift`

---

## Step 3: Verify Installation

1. **Build the app** (Cmd+B)
2. **Run on Simulator** (Cmd+R)
3. **Make a change** to any View (change text, color, spacing)
4. **Save the file** (Cmd+S)
5. **Check Simulator** - change should appear instantly (1-2 seconds)

---

## Usage Tips

### Hot Reload Workflow:

```
1. Run app on Simulator (Cmd+R) - one time
2. Navigate to the screen you're working on
3. Edit View code in Xcode
4. Save (Cmd+S) - changes appear in <2s
5. Repeat steps 3-4 (no rebuilding!)
```

### What Hot Reloads:
- ✅ View layouts (VStack, HStack, ZStack)
- ✅ Text, colors, spacing
- ✅ View logic and state
- ✅ Conditional rendering
- ❌ Model changes (requires rebuild)
- ❌ New dependencies (requires rebuild)

### Troubleshooting:

**Changes not appearing?**
- Ensure `.enableInjection()` is at the end of `body`
- Check Xcode console for Inject messages
- Try rebuilding (Cmd+B) once

**Build errors after adding package?**
- Clean build folder: Cmd+Shift+K
- Close and reopen Xcode
- Verify import statement: `import Inject`

---

## Real iPhone Support (Wireless Hot Reload)

InjectionIII works on real devices wirelessly!

### Required Configuration:

**1. Info.plist Setup (CRITICAL for wireless):**

Add InjectionIII Bonjour service to `Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>BuilderOS needs local network access for hot reload during development.</string>
<key>NSBonjourServices</key>
<array>
    <string>_inject._tcp</string>
</array>
```

**✅ Already configured in this project!**

**2. Enable Wireless Debugging in Xcode:**

This is the CRITICAL step for wireless hot reload:

1. **Connect iPhone via USB** (one time only)
2. **Open Xcode** → Window → Devices and Simulators
3. **Select your iPhone** in the left sidebar
4. **✅ Check "Connect via network"** checkbox
5. **Wait for globe icon** to appear next to device name
6. **Disconnect USB cable** - device stays connected wirelessly!

**3. Verify Wireless Connection:**

- Device shows globe icon 🌐 in Xcode Devices window
- Device appears in Xcode scheme selector with globe icon
- Both Mac and iPhone on **same Wi-Fi network**

**4. Build to iPhone wirelessly:**

```bash
# In Xcode, select your iPhone from scheme selector (with globe icon)
# Press Cmd+R to build and run
# App installs wirelessly!
```

**5. Test Hot Reload:**

1. **Edit any View file** (e.g., MainContentView.swift)
2. **Save (Cmd+S)**
3. **Watch iPhone** - changes appear in 1-2 seconds!
4. **No rebuild needed** - just save and see updates

### Troubleshooting Wireless Hot Reload:

**"Changes not appearing on device?"**

1. **Check wireless debugging is ON:**
   - Xcode → Devices → Your iPhone → "Connect via network" is checked
   - Globe icon 🌐 visible next to device

2. **Verify same Wi-Fi network:**
   - Mac and iPhone must be on same network
   - Corporate/school networks may block Bonjour discovery

3. **Check Xcode console for Inject logs:**
   ```
   💉 Injection connected
   💉 Loaded .../MainContentView.swift
   ```

4. **Restart if needed:**
   - Disconnect/reconnect wireless debugging in Xcode Devices
   - Rebuild app once (Cmd+B)
   - Ensure app is running on device

**"Device not showing in Xcode?"**

- Reconnect via USB temporarily
- Re-enable "Connect via network" in Devices window
- Check Mac firewall settings (allow Xcode incoming connections)

**"Hot reload works on simulator but not device?"**

- Missing `_inject._tcp` in NSBonjourServices (already fixed in this project)
- Wireless debugging not enabled in Xcode Devices
- VPN blocking local network discovery (disable VPN temporarily for dev)

---

## Production Safety

**Zero overhead in production:**
- `@ObserveInjection` becomes no-op
- `.enableInjection()` inlined out
- No performance impact
- No need to remove code for App Store

---

## Performance Impact

**Development:**
- First build: Same as before
- Hot reload: ~1-2s (vs 30-60s full rebuild)
- **30x faster iteration** for UI changes

**Production:**
- Zero overhead (automatically optimized out)
- No runtime cost
- Safe for App Store release

---

## Documentation

- **Inject GitHub:** https://github.com/krzysztofzablocki/Inject
- **SwiftUI Guide:** https://github.com/krzysztofzablocki/Inject#swiftui

---

*InjectionIII Setup Guide - BuilderOS Mobile*
