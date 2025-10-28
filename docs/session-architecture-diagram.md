# Session-Per-Chat Architecture Diagram

## Before (Broken - Shared Session)

```
┌─────────────────────────────────────────────────────┐
│             ClaudeChatView (UI)                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Tab 1: Claude      Tab 2: Claude      Tab 3: Codex │
│  (id: UUID-A)       (id: UUID-B)       (id: UUID-C) │
│       │                  │                  │        │
│       └──────────────────┴──────────────────┘        │
│                          │                           │
│                          ▼                           │
│              ┌─────────────────────┐                 │
│              │ ChatServiceManager  │                 │
│              │     (SINGLETON)     │                 │
│              ├─────────────────────┤                 │
│              │ claudeService: ONE  │◄────┐           │
│              │ codexService: ONE   │◄──┐ │           │
│              └─────────────────────┘   │ │           │
│                          │              │ │           │
│                          ▼              │ │           │
│         ┌─────────────────────────┐    │ │           │
│         │  ClaudeAgentService     │────┘ │           │
│         │  sessionId: GLOBAL      │      │           │
│         │  messages: [SHARED]     │      │           │
│         └─────────────────────────┘      │           │
│                          │                │           │
│         ┌─────────────────────────┐      │           │
│         │  CodexAgentService      │──────┘           │
│         │  sessionId: GLOBAL      │                  │
│         │  messages: [SHARED]     │                  │
│         └─────────────────────────┘                  │
│                                                      │
│  ❌ PROBLEM: All tabs share same messages!          │
└─────────────────────────────────────────────────────┘
```

## After (Fixed - Session-Per-Chat)

```
┌──────────────────────────────────────────────────────────────────┐
│                    ClaudeChatView (UI)                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Tab 1: Claude           Tab 2: Claude           Tab 3: Codex    │
│  id: UUID-A              id: UUID-B              id: UUID-C      │
│  sessionId: device-      sessionId: device-      sessionId:      │
│    claude-A                claude-B                device-        │
│       │                        │                    codex-C       │
│       │                        │                        │         │
│       ▼                        ▼                        ▼         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           ChatServiceManager (SINGLETON)                  │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ claudeServices: [String: ClaudeAgentService]             │   │
│  │   "device-claude-A" → Service A ◄───────────────┐        │   │
│  │   "device-claude-B" → Service B ◄─────────┐     │        │   │
│  │                                             │     │        │   │
│  │ codexServices: [String: CodexAgentService] │     │        │   │
│  │   "device-codex-C" → Service C ◄─────┐     │     │        │   │
│  └────────────────────────────────────│─┴─────┴─────┘        │   │
│                                        │   │   │               │   │
│                                        ▼   ▼   ▼               │   │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌────────┐│   │
│  │ ClaudeAgentService  │  │ ClaudeAgentService  │  │ Codex  ││   │
│  │ sessionId: dev-cl-A │  │ sessionId: dev-cl-B │  │Service ││   │
│  │ messages: [A only]  │  │ messages: [B only]  │  │  ...   ││   │
│  │                     │  │                     │  │        ││   │
│  │ WebSocket → backend │  │ WebSocket → backend │  │ WS →   ││   │
│  │   session A         │  │   session B         │  │  sess C││   │
│  └─────────────────────┘  └─────────────────────┘  └────────┘│   │
│                                                                   │
│  ✅ FIXED: Each tab has independent messages and backend session!│
└──────────────────────────────────────────────────────────────────┘
```

## Session Lifecycle

### 1. Creating a New Chat

```
User taps "+" button
        │
        ▼
ConversationTab.init()
        │
        ├─ Generate UUID (tabId)
        ├─ Get deviceId from UIDevice
        └─ Create sessionId: "\(deviceId)-\(provider)-\(tabId)"
        │
        ▼
ClaudeChatView.addNewTab()
        │
        ▼
createServiceForTab(tab)
        │
        ▼
ChatServiceManager.getOrCreateClaudeService(sessionId)
        │
        ├─ Check if service already exists for sessionId
        │
        ├─ If exists: Return existing service
        │
        └─ If new: Create ClaudeAgentService(sessionId)
                   │
                   ├─ Load messages from persistence
                   │  (key: "builderos_claude_chat_history_{sessionId}")
                   │
                   └─ Auto-connect to backend WebSocket
                      (sends sessionId in connection payload)
```

### 2. Sending Messages

```
User types message in Tab A
        │
        ▼
ClaudeChatView.sendMessage()
        │
        ├─ Get activeService (service for Tab A's sessionId)
        │
        ▼
ClaudeAgentService.sendMessage(text)
        │
        ├─ Append user message to messages array
        ├─ Persist to UserDefaults (key: "...{sessionId}")
        │
        └─ Send to WebSocket with payload:
           {
             "content": "user message",
             "session_id": "device-claude-A",
             "device_id": "device-id",
             "chat_type": "jarvis"
           }
        │
        ▼
Backend receives message
        │
        ├─ Lookup CLI process for sessionId
        ├─ If not exists: Create new claude-code CLI process
        └─ Send message to CLI process
        │
        ▼
Backend streams response
        │
        ▼
ClaudeAgentService receives chunks
        │
        ├─ Append to currentResponseText
        ├─ Update messages array (streaming)
        └─ On "complete": Persist final message
```

### 3. Switching Between Chats

```
User taps Tab B
        │
        ▼
ClaudeChatView.selectedTabId = tab-B-id
        │
        ├─ activeTab changes to Tab B
        ├─ activeService changes to Tab B's service
        │
        ▼
View refreshes
        │
        ├─ messageListView shows Tab B's messages
        │  (from Tab B's service.messages array)
        │
        └─ Input area bound to Tab B's service
```

### 4. Deleting a Chat

```
User taps X on Tab A, confirms deletion
        │
        ▼
ClaudeChatView.removeTab(tabId)
        │
        ├─ Find tab by ID to get sessionId
        │
        ▼
ChatServiceManager.removeClaudeService(sessionId)
        │
        ├─ Get service for sessionId
        │
        ▼
ClaudeAgentService.disconnect()
        │
        ├─ Close WebSocket connection
        │
        └─ Call closeBackendSession()
           │
           └─ Send HTTP DELETE to:
              /api/claude/session/{sessionId}/close
              │
              ▼
           Backend receives DELETE
              │
              ├─ Find CLI process for sessionId
              ├─ Terminate CLI process
              └─ Remove from active sessions map
        │
        ▼
ChatServiceManager removes service from dictionary
        │
        ▼
UI removes tab from tabs array
        │
        ▼
User now sees remaining tabs only
```

## Message Persistence Structure

### UserDefaults Storage

```
UserDefaults
├─ "builderos_claude_chat_history_device-claude-UUID-A"
│  └─ [Message1, Message2, Message3, ...]
│
├─ "builderos_claude_chat_history_device-claude-UUID-B"
│  └─ [Message4, Message5, Message6, ...]
│
└─ "builderos_claude_chat_history_device-codex-UUID-C"
   └─ [Message7, Message8, Message9, ...]
```

Each session stores its own message history independently.

### Backend Session Mapping

```
Backend (Python/Node.js)
├─ active_sessions = {
│    "device-claude-UUID-A": {
│        "cli_process": <subprocess>,
│        "websocket": <WebSocket>,
│        "created_at": timestamp,
│        "last_activity": timestamp
│    },
│    "device-claude-UUID-B": {
│        "cli_process": <subprocess>,
│        "websocket": <WebSocket>,
│        "created_at": timestamp,
│        "last_activity": timestamp
│    }
│  }
```

## Session ID Format

```
Format: {deviceId}-{provider}-{chatId}

Example:
12345678-9ABC-DEF0-1234-567890ABCDEF-claude-FEDCBA09-8765-4321-0FED-CBA987654321
│                                      │ │      │
│                                      │ │      └─ Chat instance UUID
│                                      │ └─ Provider (claude/codex)
│                                      └─ Device UUID

Benefits:
✅ Globally unique across all devices
✅ Traceable to specific device
✅ Identifies provider type
✅ Unique per chat instance
✅ Persistent across app restarts
```

## Key Design Decisions

1. **Why Dictionary-Based Storage?**
   - Supports multiple concurrent sessions
   - O(1) lookup by sessionId
   - Easy to add/remove sessions
   - Maintains service lifecycle

2. **Why Not SwiftData/Core Data?**
   - UserDefaults sufficient for small message history
   - Simpler implementation
   - Faster reads/writes
   - Auto-syncs with iCloud (if enabled)
   - Max 200 messages per session (trimmed automatically)

3. **Why Session Close API?**
   - Clean up backend resources immediately
   - Don't rely on timeout for cleanup
   - Better resource management
   - User gets instant feedback (session closed)

4. **Why Keep ChatServiceManager Singleton?**
   - Central registry for all services
   - Prevents duplicate service instances
   - Easier to manage lifecycle
   - Can implement global operations (disconnectAll)

---

**Architecture:** Session-Per-Chat with Independent Backend CLI Processes
**Status:** ✅ Implemented
**Date:** 2025-10-28
