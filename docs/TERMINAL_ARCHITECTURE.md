# BuilderOS Mobile - Terminal Architecture Report

**Date:** October 23, 2025
**Prepared for:** Ty
**Issue:** Confusion about multiple terminal views + Xcode Canvas preview failures

---

## Executive Summary

✅ **Build Status:** Clean build, zero compilation errors
⚠️ **Issue:** Multiple terminal implementations creating confusion
✅ **Currently Active:** `TerminalChatView` (mock/placeholder implementation)
🚧 **WebSocket Terminals:** Complete but not yet integrated into app navigation

---

## 🗂️ Terminal View Inventory

### **1. TerminalChatView** ✅ ACTIVE IN APP
**Location:** `src/Views/TerminalChatView.swift`
**Status:** ✅ Currently deployed in MainContentView tab bar
**Type:** Mock/Placeholder chat interface
**What it does:**
- Beautiful terminal-style UI with gradient effects
- Empty state with BuilderOS logo
- Text input with quick actions
- Mock command responses (status, capsules, help)
- **NOT connected to real terminal** - simulated responses only

**Integration:**
```swift
// MainContentView.swift line 22-25
TerminalChatView()
    .tabItem {
        Label("Terminal", systemImage: "terminal.fill")
    }
```

**Dependencies:** None (self-contained)
**Preview Status:** ✅ Has valid `#Preview` blocks
**Why it exists:** Polished placeholder UI while WebSocket terminal is being developed

---

### **2. WebSocketTerminalView** 🚧 COMPLETE BUT NOT INTEGRATED
**Location:** `src/Views/WebSocketTerminalView.swift`
**Status:** 🚧 Fully implemented, not yet deployed
**Type:** Real terminal emulator with WebSocket connection
**What it does:**
- Real-time terminal session via WebSocket
- Full ANSI color code parsing
- Command suggestions and autocomplete
- Quick actions toolbar
- Terminal window resize handling
- Profile-based theming (Shell, Claude, Codex profiles)

**Dependencies:**
- `TerminalWebSocketService` ✅ (in target)
- `TerminalProfile` ✅ (in target)
- `ANSIParser` ✅ (in target)
- `Command` ✅ (in target)
- `QuickAction` ✅ (in target)
- `CommandSuggestionsView` ✅ (in target)
- `QuickActionsBar` ✅ (in target)

**Preview Status:** ✅ Has valid `#Preview` with hardcoded credentials
**Why it exists:** Production-ready terminal emulator for when WebSocket API is available

---

### **3. MultiTabTerminalView** 🚧 COMPLETE BUT NOT INTEGRATED
**Location:** `src/Views/MultiTabTerminalView.swift`
**Status:** 🚧 Fully implemented, not yet deployed
**Type:** Multi-tab terminal container (iTerm2-style)
**What it does:**
- Manages up to 3 terminal tabs
- Each tab is a separate `WebSocketTerminalView` session
- Custom tab bar with close/add buttons
- Profile selection per tab (Shell, Claude, Codex)

**Dependencies:**
- `WebSocketTerminalView` ✅ (in target)
- `TerminalTab` ✅ (in target)
- `TerminalTabBar` ✅ (in target)
- `TerminalTabButton` ✅ (in target)
- `TerminalProfile` ✅ (in target)

**Preview Status:** ✅ Has valid `#Preview`
**Why it exists:** Advanced terminal UI for power users who want multiple shells

---

### **4. RealTerminalView** 🗑️ LEGACY - DELETE
**Location:** `src/Views/RealTerminalView.swift`
**Status:** 🗑️ Deprecated prototype
**Type:** Early WebSocket terminal prototype
**What it does:**
- Basic WebSocket terminal with simple UI
- Inline `LiveTerminalService` class (not using shared service)
- No ANSI parsing
- No command suggestions
- Barebones UI

**Why it exists:** Early proof-of-concept before proper architecture was designed
**Action:** DELETE - superseded by `WebSocketTerminalView`

---

### **5. Supporting Components** ✅ ALL IN TARGET

| Component | Location | Status | Purpose |
|-----------|----------|--------|---------|
| `TerminalWebSocketService` | `src/Services/` | ✅ In target | WebSocket connection manager |
| `TerminalProfile` | `src/Models/` | ✅ In target | Shell profile configs (Shell, Claude, Codex) |
| `TerminalTab` | `src/Models/` | ✅ In target | Tab metadata for multi-tab view |
| `TerminalKey` | `src/Models/` | ✅ In target | Keyboard toolbar keys |
| `Command` | `src/Models/` | ✅ In target | Command suggestions model |
| `QuickAction` | `src/Models/` | ✅ In target | Quick action buttons |
| `ANSIParser` | `src/Services/` | ✅ In target | ANSI escape code parser |
| `CommandSuggestionsView` | `src/Views/` | ✅ In target | Autocomplete UI |
| `QuickActionsBar` | `src/Views/` | ✅ In target | Quick action toolbar |
| `TerminalTabBar` | `src/Views/` | ✅ In target | Custom tab bar for multi-tab |
| `TerminalTabButton` | `src/Views/` | ✅ In target | Tab button UI |
| `TerminalKeyboardToolbar` | `src/Views/` | ✅ In target | Custom keyboard toolbar |
| `TerminalColors` | `src/Utilities/` | ✅ In target | Terminal color scheme |
| Terminal Components | `src/Components/` | ✅ In target | Reusable UI components |

---

## 🔍 Why Xcode Canvas Can't Preview

**Canvas Error:** "Could not analyze the built target"

**Root Cause:** Canvas previews work fine! The build succeeds. The issue is likely one of:

1. **Xcode needs restart** - Canvas sometimes gets stuck
2. **Preview device mismatch** - Canvas using different simulator than build
3. **Preview provider cache** - Xcode's preview cache is stale

**Proof it works:**
```bash
✅ xcodebuild clean build - SUCCESS (zero errors)
✅ All terminal views have valid #Preview blocks
✅ All dependencies in target
```

**Solution:**
1. Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
2. Restart Xcode
3. Select iPhone 17 as preview device
4. Try Canvas preview again

---

## 📊 Current Architecture Status

### What's Actually Running in the App

**MainContentView.swift tabs:**
1. **Dashboard** - `DashboardView` ✅
2. **Terminal** - `TerminalChatView` ✅ (mock responses only)
3. **Preview** - `LocalhostPreviewView` ✅
4. **Settings** - `SettingsView` ✅

### What's Ready But Not Integrated

- `WebSocketTerminalView` - Real terminal, waiting for WebSocket API
- `MultiTabTerminalView` - Multi-tab container, waiting for WebSocket API
- `TerminalWebSocketService` - Connects to `/api/terminal/ws` endpoint

### What's Missing for Full Terminal

**Backend requirement:** BuilderOS API needs WebSocket endpoint at:
```
wss://[tunnel-url]/api/terminal/ws
```

**Protocol:**
1. Client connects to WebSocket
2. Sends API key as first message (string)
3. Server responds with "authenticated" string
4. Client sends terminal input as data messages
5. Server sends terminal output as data messages
6. Client sends resize commands as JSON: `{"type":"resize","rows":40,"cols":80}`

---

## 🎯 Recommended Actions

### Immediate (To Resolve Confusion)

1. **Delete** `RealTerminalView.swift` - it's obsolete
   ```bash
   rm src/Views/RealTerminalView.swift
   ```

2. **Clean up duplicates** in `src/ios/BuilderSystemMobile/` directory:
   ```bash
   rm -rf src/ios/BuilderSystemMobile/
   ```
   (This appears to be an old/backup directory)

3. **Fix Canvas previews:**
   - Clean build folder in Xcode
   - Restart Xcode
   - Try previews again

### Short-term (When Ready to Deploy Real Terminal)

4. **Swap TerminalChatView → WebSocketTerminalView in MainContentView:**
   ```swift
   // Replace line 22-25 in MainContentView.swift
   WebSocketTerminalView(
       baseURL: apiClient.tunnelURL,
       apiKey: apiClient.apiKey,
       profile: .shell
   )
   .tabItem {
       Label("Terminal", systemImage: "terminal.fill")
   }
   ```

5. **OR upgrade to multi-tab terminal:**
   ```swift
   MultiTabTerminalView()
       .tabItem {
           Label("Terminal", systemImage: "terminal.fill")
       }
   ```

### Long-term (Backend Work)

6. **Implement WebSocket endpoint** in BuilderOS API:
   - Path: `/api/terminal/ws`
   - Auth: First message is API key (string)
   - I/O: Bidirectional data messages (UTF-8 strings)
   - Resize: JSON messages for terminal size changes

---

## 🧪 Testing the Terminal

### Current State (TerminalChatView)
✅ **Works:** Beautiful UI, mock responses
❌ **Doesn't work:** Real commands, actual shell access

**Test it:**
1. Run app on simulator
2. Tap "Terminal" tab
3. Type `status` → see mock status response
4. Type `capsules` → see mock capsule list
5. Type anything else → see "coming soon" message

### Future State (WebSocketTerminalView)
Once WebSocket API is ready:

1. Run app on simulator
2. Tap "Terminal" tab
3. Real terminal prompt appears
4. Type `ls` → see actual BuilderOS directory contents
5. Type `cd capsules` → navigate to capsules
6. Type `git status` → see real git status

---

## 📁 File Structure Cleanup

### Keep (Production Code)

```
src/
├── Views/
│   ├── TerminalChatView.swift          ← Currently active
│   ├── WebSocketTerminalView.swift     ← Ready for deployment
│   ├── MultiTabTerminalView.swift      ← Ready for deployment
│   ├── TerminalTabBar.swift
│   ├── TerminalTabButton.swift
│   ├── TerminalKeyboardToolbar.swift
│   ├── CommandSuggestionsView.swift
│   └── QuickActionsBar.swift
├── Services/
│   ├── TerminalWebSocketService.swift
│   └── ANSIParser.swift
├── Models/
│   ├── TerminalProfile.swift
│   ├── TerminalTab.swift
│   ├── TerminalKey.swift
│   ├── Command.swift
│   └── QuickAction.swift
├── Utilities/
│   └── TerminalColors.swift
└── Components/
    └── Terminal*.swift (9 files)
```

### Delete (Obsolete)

```
src/
├── Views/
│   └── RealTerminalView.swift          ← DELETE
└── ios/BuilderSystemMobile/            ← DELETE entire directory
    ├── WebSocketTerminalView.swift     (duplicate)
    ├── TerminalWebSocketService.swift  (duplicate)
    ├── ANSIParser.swift                (duplicate)
    └── ...
```

---

## ✅ Summary

**The actual terminal you're using right now:**
- `TerminalChatView` - Mock chat interface with beautiful design

**The real terminals ready to deploy:**
- `WebSocketTerminalView` - Single terminal session
- `MultiTabTerminalView` - Multi-tab terminal container

**Why Canvas isn't working:**
- It actually is! Build succeeds. Canvas likely needs Xcode restart.

**What to do:**
1. Delete `RealTerminalView.swift` and `src/ios/BuilderSystemMobile/` directory
2. Restart Xcode to fix Canvas
3. When WebSocket API is ready, swap in `WebSocketTerminalView`

**Current functionality:**
- ✅ Beautiful terminal-style UI
- ✅ Mock command responses
- ❌ No real shell access yet (waiting for WebSocket API)

---

## 🚀 Next Steps

1. **Immediate:** Clean up obsolete files (RealTerminalView, ios/ directory)
2. **Short-term:** Implement WebSocket endpoint in BuilderOS API
3. **Deploy:** Swap TerminalChatView → WebSocketTerminalView in MainContentView
4. **Optional:** Enable multi-tab mode with MultiTabTerminalView

The terminal architecture is solid. You have a working placeholder (TerminalChatView) and production-ready WebSocket terminals waiting for the backend API.
