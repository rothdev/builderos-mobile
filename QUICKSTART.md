# BuilderOS Mobile - Quick Start Guide

**Get productive in 10 minutes**

---

## Prerequisites

- ✅ Mac with Xcode 15+ installed
- ✅ iOS Simulator or iPhone for testing
- ✅ Cloudflare Tunnel running on Mac
- ✅ BuilderOS API server running

---

## 1. Add InjectionIII (2 minutes)

**Why:** Get 30x faster iteration (30-60s → 2s per change)

### Step 1: Add Package

1. Open Xcode project:
   ```bash
   cd /Users/Ty/BuilderOS/capsules/builderos-mobile
   open BuilderSystemMobile.xcodeproj
   ```

2. In Xcode:
   - File → Add Package Dependencies
   - Paste: `https://github.com/krzysztofzablocki/Inject`
   - Click "Add Package"
   - Target: BuilderSystemMobile
   - Click "Add Package" again

### Step 2: Verify Setup

InjectionIII hooks are **already added** to these views:
- ✅ MainContentView.swift
- ✅ CapsuleListView.swift
- ✅ TerminalTabView.swift
- ✅ ChatView.swift

You're ready to go!

---

## 2. Test Hot Reloading (2 minutes)

### Run the App

1. **Build and run** (Cmd+R)
2. **Wait for Simulator** to launch app
3. **Keep Simulator visible** alongside Xcode

### Make a Change

1. Open `MainContentView.swift`
2. Find the Dashboard tab label:
   ```swift
   Label("Dashboard", systemImage: "house.fill")
   ```
3. Change to:
   ```swift
   Label("Home", systemImage: "house.fill")  // Changed!
   ```
4. **Save file** (Cmd+S)
5. **Watch Simulator** - tab label updates in ~2 seconds! 🎉

### Undo Change

Change it back to "Dashboard" and save. It updates instantly again!

**You now have 30x faster iteration.** No more waiting for rebuilds!

---

## 3. Development Loop

### The Fast Way (With InjectionIII)

```
1. Run app ONCE (Cmd+R)
   ↓
2. Navigate to screen you're working on
   ↓
3. Edit code in Xcode
   ↓
4. Save (Cmd+S)
   ↓
5. See changes in ~2s ← Magic!
   ↓
6. Repeat steps 3-5 indefinitely
```

**No rebuilding between changes!**

---

## 4. Working with Designs

### Penpot Mockups

**Location:** `design/*.html` (temporary HTML references)

**Penpot Project:** Create via `docs/PENPOT_PROJECT_GUIDE.md`

### Design → Swift Workflow

1. **📐 UI Designer** creates mockups in Penpot
2. **📱 Mobile Dev** implements in Swift
3. **Validate** by comparing screenshots to Penpot

**See:** `docs/MOBILE_WORKFLOW.md` for complete process

---

## 5. Common Tasks

### Add a New View

```swift
import SwiftUI
import Inject  // ← Add this

struct MyNewView: View {
    @ObserveInjection var inject  // ← Add this

    var body: some View {
        Text("Hello World")
            .enableInjection()  // ← Add this
    }
}
```

**That's it!** Now your view hot reloads.

### Test Component States (Xcode Previews)

```swift
#Preview("Default") {
    MyNewView()
}

#Preview("Dark Mode") {
    MyNewView()
        .preferredColorScheme(.dark)
}
```

View in Xcode's Canvas panel.

### Build Documentation (Optional)

```
Product → Build Documentation (Cmd+Shift+Ctrl+D)
```

Opens in Xcode Documentation window.

---

## 6. Troubleshooting

### InjectionIII Not Working?

**Issue:** Changes don't appear after saving

**Fix:**
1. Check you added `import Inject` at top of file
2. Check you added `@ObserveInjection var inject` to struct
3. Check you added `.enableInjection()` at end of `body`
4. Try rebuilding once: Clean Build Folder (Cmd+Shift+K), then Cmd+R

### Can't Find Package?

**Issue:** "No such module 'Inject'"

**Fix:**
1. File → Add Package Dependencies
2. URL: `https://github.com/krzysztofzablocki/Inject`
3. Make sure you selected "BuilderSystemMobile" target

### App Won't Build?

**Issue:** Build errors after changes

**Fix:**
1. Clean Build Folder (Cmd+Shift+K)
2. Close and reopen Xcode
3. Build again (Cmd+B)

---

## 7. Next Steps

### Learn the Full Workflow

**Read:** `docs/MOBILE_WORKFLOW.md`

Covers:
- Complete design → implementation process
- Penpot integration
- DocC documentation
- Performance metrics
- Best practices

### Set Up Documentation (Optional)

**Read:** `docs/DOCC_SETUP.md`

Generate beautiful docs for complex components.

### Create Penpot Project (When Needed)

**Read:** `docs/PENPOT_PROJECT_GUIDE.md`

Step-by-step Penpot project setup.

---

## Key Files

```
capsules/builderos-mobile/
├── QUICKSTART.md                    ← You are here
├── docs/
│   ├── MOBILE_WORKFLOW.md           ← Complete workflow
│   ├── INJECTION_SETUP.md           ← Hot reload details
│   ├── DOCC_SETUP.md                ← Documentation setup
│   └── PENPOT_PROJECT_GUIDE.md      ← Design workflow
└── src/
    └── ios/BuilderSystemMobile/
        └── Views/                   ← Your UI code
```

---

## Pro Tips

### 1. Keep Simulator Visible

Split screen: Xcode on left, Simulator on right. Watch changes happen live!

### 2. Use Xcode Previews for Isolated Components

Complex components? Add `#Preview` blocks and view in Canvas.

### 3. Document Complex Code

Add `///` comments for DocC documentation generation.

### 4. Screenshot for Design Comparison

Simulator → Cmd+S to save screenshot. Compare to Penpot mockups.

### 5. Real Device Testing

InjectionIII works on real iPhones too! Connect via USB and build.

---

## Success Checklist

After following this guide, you should have:

- ✅ InjectionIII package added to Xcode
- ✅ Tested hot reloading (2-second updates working)
- ✅ Understood the development loop (run once, iterate fast)
- ✅ Know where to find full documentation

**You're ready to build!** 🚀

---

## Time Savings

**Before InjectionIII:**
- 30-60 seconds per change
- ~60-120 iterations per hour
- 30-60 minutes lost to waiting per day

**With InjectionIII:**
- 1-2 seconds per change
- ~1,800 iterations per hour
- 45-55 minutes saved per day
- **30x faster!**

---

## Questions?

**Full workflow:** `docs/MOBILE_WORKFLOW.md`
**InjectionIII details:** `docs/INJECTION_SETUP.md`
**DocC setup:** `docs/DOCC_SETUP.md`
**Design process:** `docs/PENPOT_PROJECT_GUIDE.md`

---

*Quick Start Guide - BuilderOS Mobile*
*Last Updated: October 2025*
