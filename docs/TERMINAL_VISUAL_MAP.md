# BuilderOS Mobile - Terminal Visual Architecture Map

## 🗺️ Current App Navigation

```
BuilderOS Mobile App
│
└─── MainContentView (TabView)
     ├─── 📊 Dashboard Tab
     │    └─── DashboardView ✅
     │
     ├─── 💬 Terminal Tab ⭐ YOU ARE HERE
     │    └─── TerminalChatView ✅ ACTIVE NOW
     │         ├─── Mock responses only
     │         ├─── Beautiful terminal UI
     │         └─── No real shell access
     │
     ├─── 🌐 Preview Tab
     │    └─── LocalhostPreviewView ✅
     │
     └─── ⚙️  Settings Tab
          └─── SettingsView ✅
```

---

## 🚀 Terminal Evolution Path

### Phase 1: Current (Mock Terminal)
```
User taps Terminal tab
    ↓
TerminalChatView displays
    ↓
User types "status"
    ↓
Mock response: "⚡ System: OPERATIONAL..."
    ↓
❌ No real shell access
```

### Phase 2: WebSocket Terminal (Future)
```
User taps Terminal tab
    ↓
WebSocketTerminalView displays
    ↓
Connects to wss://[tunnel]/api/terminal/ws
    ↓
User types "ls"
    ↓
✅ Real terminal output from BuilderOS Mac
    ↓
User types "cd capsules"
    ↓
✅ Actually navigates to capsules directory
```

### Phase 3: Multi-Tab Terminal (Advanced)
```
User taps Terminal tab
    ↓
MultiTabTerminalView displays
    ↓
┌─────────────────────────────────┐
│ [Shell] [Claude] [+]            │ ← Tab bar
├─────────────────────────────────┤
│                                  │
│  WebSocketTerminalView (Shell)  │ ← Active tab
│                                  │
└─────────────────────────────────┘
    ↓
User taps [+] button
    ↓
Profile picker: Shell / Claude / Codex
    ↓
New tab opens with separate WebSocket connection
```

---

## 🔧 Terminal View Hierarchy

### TerminalChatView (Current)
```
TerminalChatView
├─── Terminal Header
│    ├─── "$ BuilderOS" title
│    └─── "CONNECTED" status (fake)
│
├─── Empty State (when no messages)
│    ├─── BuilderOS logo
│    ├─── "$ BUILDEROS" title
│    └─── Description text
│
├─── Message List (when has messages)
│    ├─── User messages (green ">")
│    ├─── System messages (cyan "$")
│    └─── Timestamp for system messages
│
└─── Input Bar
     ├─── Quick actions button (⚡)
     ├─── Text field "$ _"
     └─── Send button (↑)
```

### WebSocketTerminalView (Ready to Deploy)
```
WebSocketTerminalView
├─── Terminal Background
│    └─── Gradient (profile color coded)
│
├─── Connection Status Bar
│    ├─── Connection indicator (🟢/🔴)
│    ├─── "CONNECTED"/"DISCONNECTED"
│    └─── Reconnect button (if disconnected)
│
├─── Terminal Output (ScrollView)
│    ├─── ANSI-parsed text
│    ├─── Colored output (green, cyan, red, etc.)
│    └─── Auto-scrolls to bottom
│
├─── Command Suggestions (when typing)
│    ├─── Filtered by input text
│    └─── Up to 5 suggestions shown
│
├─── Quick Actions Toolbar
│    ├─── Pre-configured commands
│    └─── One-tap command execution
│
└─── Input Bar
     ├─── ">" prompt (profile colored)
     ├─── Text field
     └─── Send button
```

### MultiTabTerminalView (Advanced Option)
```
MultiTabTerminalView
├─── Custom Tab Bar
│    ├─── Tab buttons (up to 3)
│    │    ├─── Tab 1: Shell 🐚
│    │    ├─── Tab 2: Claude 🧠
│    │    └─── Tab 3: Codex 💬
│    ├─── [+] Add tab button
│    └─── [×] Close tab button
│
└─── TabView (swipeable)
     ├─── Tab 1: WebSocketTerminalView (Shell profile)
     ├─── Tab 2: WebSocketTerminalView (Claude profile)
     └─── Tab 3: WebSocketTerminalView (Codex profile)
```

---

## 🧩 Supporting Components Map

### Models
```
Models/
├─── TerminalProfile
│    ├─── Shell profile (green)
│    ├─── Claude profile (purple)
│    └─── Codex profile (blue)
│
├─── TerminalTab
│    └─── Tab metadata for multi-tab view
│
├─── Command
│    ├─── BuilderOS commands (/claude, /codex, /nav)
│    ├─── Shell commands (ls, cd, pwd, cat)
│    └─── Git commands (status, log, diff)
│
└─── QuickAction
     └─── Quick action buttons (status, capsules, etc.)
```

### Services
```
Services/
├─── TerminalWebSocketService
│    ├─── WebSocket connection manager
│    ├─── connect() / disconnect()
│    ├─── sendInput() / sendBytes()
│    └─── sendResize()
│
└─── ANSIParser
     ├─── Parse ANSI escape codes
     ├─── Convert to AttributedString
     └─── Apply colors and formatting
```

### Views
```
Views/
├─── TerminalChatView ✅ Active
├─── WebSocketTerminalView 🚧 Ready
├─── MultiTabTerminalView 🚧 Ready
├─── CommandSuggestionsView
├─── QuickActionsBar
├─── TerminalTabBar
├─── TerminalTabButton
└─── TerminalKeyboardToolbar
```

---

## 🔄 WebSocket Connection Flow

```
iOS App                          BuilderOS API
   │                                  │
   │  1. Connect to WebSocket         │
   ├──────────────────────────────────>│
   │     wss://[tunnel]/api/terminal/ws│
   │                                  │
   │  2. Send API key (string)        │
   ├──────────────────────────────────>│
   │                                  │
   │  3. Receive "authenticated"      │
   │<──────────────────────────────────┤
   │                                  │
   │  isConnected = true              │
   │                                  │
   │  4. User types "ls"              │
   │  Send "ls\n" (data)              │
   ├──────────────────────────────────>│
   │                                  │
   │  5. Execute command on Mac       │
   │                                  │
   │  6. Receive output (data)        │
   │<──────────────────────────────────┤
   │     "file1.txt\nfile2.txt\n..."  │
   │                                  │
   │  7. Parse ANSI codes             │
   │  8. Display colored text         │
   │                                  │
   │  9. Terminal resizes             │
   │  Send resize JSON                │
   ├──────────────────────────────────>│
   │  {"type":"resize","rows":40,...} │
   │                                  │
```

---

## 🎨 Profile Color Coding

```
┌─────────────────────────────────────────────┐
│ Shell Profile                               │
│ Color: Green (#00FF88)                      │
│ Initial Command: None (raw shell)          │
│ Working Dir: /Users/Ty/BuilderOS           │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Claude Profile                              │
│ Color: Purple (#A855F7)                     │
│ Initial Command: cd BuilderOS && claude     │
│ Working Dir: /Users/Ty/BuilderOS           │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Codex Profile                               │
│ Color: Blue (#3B82F6)                       │
│ Initial Command: [BridgeHub command]       │
│ Working Dir: /Users/Ty/BuilderOS           │
└─────────────────────────────────────────────┘
```

---

## 📊 Dependency Graph

```
WebSocketTerminalView
├── TerminalWebSocketService ✅
│   └── URLSession (WebSocket)
├── TerminalProfile ✅
├── ANSIParser ✅
│   └── AttributedString
├── Command ✅
├── QuickAction ✅
├── CommandSuggestionsView ✅
└── QuickActionsBar ✅

MultiTabTerminalView
├── WebSocketTerminalView ✅
├── TerminalTab ✅
├── TerminalTabBar ✅
│   └── TerminalTabButton ✅
└── TerminalProfile ✅

TerminalChatView
└── No dependencies (self-contained) ✅
```

**Legend:**
- ✅ In Xcode target
- 🚧 Ready to deploy
- ❌ Not available

---

## 🚦 Deployment Roadmap

### Current State
```
[Production] TerminalChatView
    ↓
[Mock responses]
    ↓
[Beautiful UI only]
```

### After WebSocket API Ready
```
[Production] WebSocketTerminalView
    ↓
[Real WebSocket connection]
    ↓
[Full shell access]
```

### Optional Advanced State
```
[Production] MultiTabTerminalView
    ↓
[Multiple WebSocket sessions]
    ↓
[Shell + Claude + Codex simultaneously]
```

---

## 🔍 File Location Map

```
builderos-mobile/
├── src/
│   ├── Views/
│   │   ├── TerminalChatView.swift ⭐ Active now
│   │   ├── WebSocketTerminalView.swift 🚧 Ready
│   │   ├── MultiTabTerminalView.swift 🚧 Ready
│   │   ├── CommandSuggestionsView.swift
│   │   ├── QuickActionsBar.swift
│   │   ├── TerminalTabBar.swift
│   │   ├── TerminalTabButton.swift
│   │   ├── TerminalKeyboardToolbar.swift
│   │   └── MainContentView.swift ← Change terminal here
│   │
│   ├── Services/
│   │   ├── TerminalWebSocketService.swift
│   │   └── ANSIParser.swift
│   │
│   ├── Models/
│   │   ├── TerminalProfile.swift
│   │   ├── TerminalTab.swift
│   │   ├── TerminalKey.swift
│   │   ├── Command.swift
│   │   └── QuickAction.swift
│   │
│   ├── Utilities/
│   │   └── TerminalColors.swift
│   │
│   └── Components/
│       └── Terminal*.swift (9 UI components)
│
└── docs/
    ├── TERMINAL_ARCHITECTURE.md ← Full details
    ├── TERMINAL_VISUAL_MAP.md ← This file
    └── TERMINAL_INVESTIGATION_COMPLETE.md ← Summary
```

---

## ✅ Quick Decision Matrix

**Question: Which terminal should I use?**

| Scenario | Use This | Why |
|----------|----------|-----|
| Right now (no WebSocket API) | TerminalChatView | Beautiful placeholder with mock responses |
| WebSocket API is ready | WebSocketTerminalView | Real terminal, single session |
| Need multiple shells simultaneously | MultiTabTerminalView | Shell + Claude + Codex all at once |
| Just want to test UI | TerminalChatView | Already active, works now |

**Question: Why can't I preview in Canvas?**
- Build succeeds ✅
- Code is valid ✅
- Xcode cache issue → Restart Xcode

**Question: Where do I change which terminal is active?**
- File: `src/Views/MainContentView.swift`
- Line: 22-25
- Replace: `TerminalChatView()` with desired terminal view

---

**Visual map complete!** See other docs for implementation details.
