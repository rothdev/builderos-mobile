# BuilderOS Mobile - Terminal Quick Reference

**TL;DR:** You have 3 terminal views. Here's what each one does and which one is active.

---

## 🎯 Which Terminal Am I Using Right Now?

**Answer:** `TerminalChatView` (mock/placeholder)

**What it does:**
- ✅ Beautiful terminal UI
- ✅ Mock responses to commands like `status`, `capsules`, `help`
- ❌ No real shell access (fake responses)

**Where it is:**
```swift
// src/Views/MainContentView.swift line 22
TerminalChatView()
```

**Test it:**
1. Run app
2. Tap "Terminal" tab
3. Type `status` → see mock status
4. Type anything else → "coming soon"

---

## 🚀 Which Terminal Should I Use When WebSocket API is Ready?

**Answer:** `WebSocketTerminalView` (real terminal)

**What it does:**
- ✅ Real terminal session via WebSocket
- ✅ Full shell access (ls, cd, git, etc.)
- ✅ ANSI colors (green, cyan, red, bold)
- ✅ Command autocomplete
- ✅ Quick actions toolbar

**Where it is:**
```swift
// src/Views/WebSocketTerminalView.swift
```

**How to deploy:**
Replace `TerminalChatView` with this in MainContentView:
```swift
WebSocketTerminalView(
    baseURL: apiClient.tunnelURL,
    apiKey: apiClient.apiKey,
    profile: .shell
)
```

---

## 🔥 Advanced: Multi-Tab Terminal (Optional)

**Answer:** `MultiTabTerminalView` (iTerm2-style)

**What it does:**
- ✅ Up to 3 terminal tabs
- ✅ Each tab = separate shell session
- ✅ Tab bar with close/add buttons
- ✅ Run Shell, Claude, Codex simultaneously

**Where it is:**
```swift
// src/Views/MultiTabTerminalView.swift
```

**How to deploy:**
Replace `TerminalChatView` with:
```swift
MultiTabTerminalView()
```

---

## 🗑️ What Was Deleted?

**Obsolete files removed:**
- ❌ `RealTerminalView.swift` - early prototype (superseded)
- ❌ `src/ios/BuilderSystemMobile/` - duplicate files (not needed)

---

## ✅ Canvas Preview Fix

**Issue:** "Could not analyze the built target"

**Solution:**
1. Clean Build Folder (Cmd+Shift+K)
2. Restart Xcode
3. Try Canvas preview again

**Proof it works:**
```bash
✅ xcodebuild clean build - SUCCESS
✅ Zero compilation errors
```

---

## 📊 Status at a Glance

| Terminal View | Status | When to Use |
|---------------|--------|-------------|
| TerminalChatView | ✅ Active now | Placeholder until WebSocket ready |
| WebSocketTerminalView | 🚧 Ready to deploy | When WebSocket API is available |
| MultiTabTerminalView | 🚧 Ready to deploy | Advanced multi-tab option |

---

## 🛠️ WebSocket API Requirements

**Endpoint needed:** `wss://[tunnel-url]/api/terminal/ws`

**Protocol:**
1. Client sends API key (string) as first message
2. Server responds with "authenticated"
3. Client sends terminal input (data messages)
4. Server sends terminal output (data messages)
5. Client sends resize: `{"type":"resize","rows":40,"cols":80}`

---

## 📚 Full Documentation

- **Architecture deep-dive:** `docs/TERMINAL_ARCHITECTURE.md`
- **Complete investigation:** `TERMINAL_INVESTIGATION_COMPLETE.md`
- **This quick reference:** `QUICK_TERMINAL_REFERENCE.md`

---

**Status:** ✅ All terminal views documented and verified. Build succeeds. Ready to deploy real terminal when WebSocket API is ready.
