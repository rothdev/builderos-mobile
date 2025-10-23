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

## Real iPhone Support

InjectionIII works on real devices too!

1. **Install InjectionIII Mac app** (optional):
   ```bash
   brew install --cask injectioniii
   ```

2. **Run app** (makes hot reload easier to monitor)

3. **Build to iPhone** over USB

4. **Edit code** - hot reloads on device

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
