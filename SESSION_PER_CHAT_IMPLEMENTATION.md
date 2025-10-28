# Session-Per-Chat Architecture Implementation

## Summary

Successfully implemented proper session-per-chat architecture for BuilderOS Mobile. Each chat now has its own independent backend CLI session with isolated conversation history.

## Problem Solved

**Before:** Multiple Claude chats shared the same backend session
- All tabs used singleton `ChatServiceManager.shared`
- Same `sessionId` stored in UserDefaults globally
- Same `messages` array shared across all chats
- Creating a second chat showed the same conversation

**After:** Each chat is an independent CLI session
- Each `ConversationTab` generates unique `sessionId` on creation
- `ChatServiceManager` maintains separate service instances per sessionId
- Messages stored separately in UserDefaults by sessionId
- Deleting chat closes backend session via API

## Implementation Details

### 1. ConversationTab Model (src/Models/ConversationTab.swift)

Added `sessionId` property that's unique per chat instance:

```swift
struct ConversationTab: Identifiable {
    let id: UUID
    let provider: ChatProvider
    var title: String
    let sessionId: String  // NEW: Unique backend session ID

    init(provider: ChatProvider, title: String? = nil, sessionId: String? = nil) {
        let tabId = UUID()
        self.id = tabId
        self.provider = provider
        self.title = title ?? provider.displayName
        // Generate unique session ID: deviceId-provider-chatId
        if let customSessionId = sessionId {
            self.sessionId = customSessionId
        } else {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            self.sessionId = "\(deviceId)-\(provider.rawValue)-\(tabId.uuidString)"
        }
    }
}
```

**Format:** `{deviceId}-{provider}-{chatId}`
**Example:** `12345678-9ABC-DEF0-1234-567890ABCDEF-claude-FEDCBA09-8765-4321-0FED-CBA987654321`

### 2. ChatServiceManager (src/Services/ChatAgentServiceBase.swift)

Changed from singleton pattern to dictionary-based storage:

**Before:**
```swift
@Published private(set) var claudeService: ClaudeAgentService?
func getOrCreateClaudeService() -> ClaudeAgentService
```

**After:**
```swift
@Published private(set) var claudeServices: [String: ClaudeAgentService] = [:]
func getOrCreateClaudeService(sessionId: String) -> ClaudeAgentService
func removeClaudeService(sessionId: String)
```

Now supports multiple concurrent sessions per provider.

### 3. ClaudeAgentService & CodexAgentService

**Changed initialization to accept sessionId parameter:**

**Before:**
```swift
override init() {
    // Load or generate session ID from UserDefaults
    if let savedSessionId = UserDefaults.standard.string(forKey: "claude_session_id") {
        self.sessionId = savedSessionId
    } else {
        let newSessionId = "\(self.deviceId)-jarvis"
        UserDefaults.standard.set(newSessionId, forKey: "claude_session_id")
        self.sessionId = newSessionId
    }
    // ...
}
```

**After:**
```swift
init(sessionId: String) {
    // Use provided session ID (unique per chat)
    self.sessionId = sessionId
    // ...
    // Load messages for this specific session
    messages = persistenceManager.loadMessages(for: sessionId)
}
```

**Added session cleanup on disconnect:**

```swift
override func disconnect() {
    // Close WebSocket...

    // Send backend API request to close session
    Task {
        await closeBackendSession()
    }
}

private func closeBackendSession() async {
    let closeURL = "\(baseURL)/api/claude/session/\(sessionId)/close"
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue(APIConfig.apiToken, forHTTPHeaderField: "Authorization")
    // ... send DELETE request
}
```

### 4. ChatPersistenceManager (src/Services/ChatPersistenceManager.swift)

**Changed from global storage to per-session storage:**

**Before:**
```swift
private let userDefaultsKey = "builderos_claude_chat_history"
func saveMessage(_ message: ClaudeChatMessage)
func loadMessages()
func clearMessages()
```

**After:**
```swift
private let userDefaultsKeyPrefix = "builderos_claude_chat_history_"
func saveMessage(_ message: ClaudeChatMessage, sessionId: String)
func loadMessages(for sessionId: String) -> [ClaudeChatMessage]
func clearMessages(for sessionId: String)
func deleteAllSessions()  // For full app reset
```

**Storage format:** `builderos_claude_chat_history_{sessionId}`

### 5. ClaudeChatView (src/Views/ClaudeChatView.swift)

**Updated service creation to pass sessionId:**

```swift
private func createServiceForTab(_ tab: ConversationTab) {
    // ...
    let service: ChatAgentServiceBase
    switch tab.provider {
    case .claude:
        service = serviceManager.getOrCreateClaudeService(sessionId: tab.sessionId)
    case .codex:
        service = serviceManager.getOrCreateCodexService(sessionId: tab.sessionId)
    }
    // ...
}
```

**Updated tab removal to clean up service:**

```swift
private func removeTab(_ tabId: UUID) {
    guard let tab = tabs.first(where: { $0.id == tabId }) else { return }

    // Remove service from manager (disconnects and cleans up)
    switch tab.provider {
    case .claude:
        serviceManager.removeClaudeService(sessionId: tab.sessionId)
    case .codex:
        serviceManager.removeCodexService(sessionId: tab.sessionId)
    }
    // ... remove tab from UI
}
```

## Backend API Requirements

The mobile app now sends session close requests. Backend must implement:

**Endpoint:** `DELETE /api/claude/session/{sessionId}/close`
**Endpoint:** `DELETE /api/codex/session/{sessionId}/close`

**Headers:**
- `Authorization: {apiToken}`

**Response:**
- `200 OK` - Session closed successfully
- `404 Not Found` - Session doesn't exist (acceptable, may have timed out)
- `401 Unauthorized` - Invalid API token

**Backend behavior:**
- Close CLI process for the session
- Clean up session resources
- Remove session from active sessions map

## Testing Checklist

- [x] ✅ Build succeeds with no errors
- [ ] Create first Claude chat - verify new session created
- [ ] Send messages in first chat - verify messages persist
- [ ] Create second Claude chat - verify independent session
- [ ] Send messages in second chat - verify separate history
- [ ] Switch between chats - verify correct history shown
- [ ] Delete first chat - verify session closed
- [ ] Verify second chat still works independently
- [ ] Restart app - verify chats restore with correct history
- [ ] Test with Codex chats as well
- [ ] Test with 5 concurrent chats (UI limit)

## Verification Commands

**Check session IDs in logs:**
```bash
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.builderos.mobile"' | grep "session ID"
```

**Check stored sessions in UserDefaults:**
```bash
xcrun simctl get_app_container booted com.builderos.mobile data
# Then inspect Library/Preferences/*.plist
```

**Monitor backend session close API calls:**
```bash
# In backend logs, watch for DELETE /api/claude/session/{id}/close
```

## Success Criteria Met

✅ Each chat creates a new unique sessionId on initialization
✅ ChatServiceManager supports multiple service instances per provider
✅ Messages are stored separately per session in UserDefaults
✅ Deleting a chat calls backend API to close session
✅ Project builds successfully with no errors
✅ Architecture supports concurrent independent conversations

## Migration Notes

**Existing users:**
- Old global session will remain in UserDefaults but won't be used
- First new chat will create fresh session with new format
- No data loss - old messages remain accessible if needed

**Session ID format change:**
- Old: `{deviceId}-jarvis` or `{deviceId}-codex`
- New: `{deviceId}-{provider}-{chatId}`

## Files Modified

1. `src/Models/ConversationTab.swift` - Added sessionId property
2. `src/Services/ChatAgentServiceBase.swift` - Multi-instance service manager
3. `src/Services/ClaudeAgentService.swift` - Accept sessionId parameter, add close API
4. `src/Services/CodexAgentService.swift` - Accept sessionId parameter, add close API
5. `src/Services/ChatPersistenceManager.swift` - Per-session storage
6. `src/Views/ClaudeChatView.swift` - Pass sessionId, cleanup on delete

## Next Steps

1. **Test on device/simulator** - Verify multiple chats work independently
2. **Implement backend endpoints** - Add session close API handlers
3. **Optional: Session list UI** - Show active sessions for debugging
4. **Optional: Session export** - Allow users to export chat history per session

---

**Implementation Date:** 2025-10-28
**Status:** ✅ Complete - Ready for testing
