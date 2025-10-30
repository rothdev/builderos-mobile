# Chat History Persistence Issue

## Problem Summary

Chat conversations disappear when the app is closed. The backend has 13 stored sessions, but the iOS app doesn't display them.

## Root Cause

The iOS app and backend use **two separate, unsynced persistence systems**:

### Backend (✅ Working)
- **Storage:** SQLite database (`api/sessions.db`)
- **Location:** `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/sessions.db`
- **Sessions stored:** 13 (8 Claude, 5 Codex)
- **API endpoint:** `GET /api/sessions` returns all stored sessions
- **Persistence:** Survives backend restarts ✅

### iOS App (❌ Not Working)
- **Storage:** UserDefaults (local device storage)
- **Location:** `ChatPersistenceManager.swift`
- **Key format:** `builderos_claude_chat_history_{sessionId}`
- **Behavior:** Creates NEW tabs on each app launch
- **Missing:** No logic to fetch sessions from backend ❌

## Architecture Gap

```
┌─────────────────┐         ┌──────────────────┐
│   iOS App       │         │   Backend API    │
│                 │         │                  │
│ UserDefaults    │    X    │ SQLite Database  │
│ (not synced)    │ ◄─────► │ (13 sessions)    │
│                 │         │                  │
│ Creates fresh   │         │ Persists across  │
│ tabs on launch  │         │ restarts         │
└─────────────────┘         └──────────────────┘
```

## Evidence

**Backend has the data:**
```bash
$ curl http://localhost:8080/api/sessions
{
  "total": 13,
  "sessions": [
    {
      "session_id": "28C390BF-...-claude-E01B72FE-...",
      "agent_type": "claude",
      "message_count": 2,
      "created_at": "2025-10-28T17:27:36.441474",
      "last_activity": "2025-10-28T17:28:10.920853"
    },
    ...
  ]
}
```

**iOS app creates new tabs:**
```swift
// ClaudeChatView.swift, line 35-39
init(selectedTab: Binding<Int>) {
    self._selectedTab = selectedTab
    let initialTab = ConversationTab(provider: .claude)  // NEW tab
    self._tabs = State(initialValue: [initialTab])      // Fresh state
    self._selectedTabId = State(initialValue: initialTab.id)
}
```

No logic to:
1. Call `/api/sessions` endpoint
2. Restore previous tabs
3. Load message history from backend

## Solution Options

### Option 1: Fetch Backend Sessions on Launch (Recommended)

**Implementation:**
1. Add session restoration logic to `ClaudeChatView.onAppear()`
2. Call backend `/api/sessions` API
3. Recreate tabs for each stored session
4. Load message history for each tab

**Pros:**
- Backend is source of truth
- Chat history persists across devices (if backend is remote)
- Simpler sync model

**Cons:**
- Requires backend connection
- Slightly slower app startup

**Code changes needed:**
- `ClaudeChatView.swift`: Add session fetching in `onAppear`
- New service method: `fetchStoredSessions()` in chat service
- Parse backend response and recreate tabs

### Option 2: Two-Way Sync

**Implementation:**
1. Keep UserDefaults for offline access
2. Sync with backend when connected
3. Conflict resolution strategy

**Pros:**
- Works offline
- Faster app startup

**Cons:**
- More complex
- Sync conflicts possible
- Duplicated storage

### Option 3: Backend API for Message History

**Implementation:**
1. Add new backend endpoint: `GET /api/sessions/{sessionId}/messages`
2. iOS app fetches messages from backend on demand
3. Cache in UserDefaults for offline viewing

**Pros:**
- Clean separation of concerns
- Efficient memory usage

**Cons:**
- Requires new backend endpoint
- More API calls

## Recommended Implementation (Option 1)

### Step 1: Add Session List API Method

**File:** `src/Services/ClaudeAgentService.swift`

```swift
func fetchStoredSessions() async throws -> [ChatSession] {
    let url = APIConfig.baseURL.appendingPathComponent("/api/sessions")
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(SessionListResponse.self, from: data)
    return response.sessions
}

struct SessionListResponse: Codable {
    let total: Int
    let sessions: [ChatSession]
}

struct ChatSession: Codable, Identifiable {
    let session_id: String
    let agent_type: String
    let device_id: String
    let message_count: Int
    let created_at: String
    let last_activity: String

    var id: String { session_id }
}
```

### Step 2: Restore Tabs on Launch

**File:** `src/Views/ClaudeChatView.swift`

```swift
.onAppear {
    Task {
        do {
            // Fetch stored sessions from backend
            let sessions = try await serviceManager.fetchStoredSessions()

            // Filter for this device
            let deviceSessions = sessions.filter {
                $0.device_id == UIDevice.current.identifierForVendor?.uuidString
            }

            // Recreate tabs for existing sessions
            if !deviceSessions.isEmpty {
                tabs = deviceSessions.map { session in
                    ConversationTab(
                        id: UUID(uuidString: session.session_id.split(separator: "-").last ?? "")!,
                        provider: session.agent_type == "claude" ? .claude : .codex,
                        sessionId: session.session_id
                    )
                }
                selectedTabId = tabs.first?.id ?? UUID()
            }
        } catch {
            print("❌ Failed to restore sessions: \(error)")
            // Fall back to creating fresh tab
        }
    }
}
```

### Step 3: Load Message History

**File:** `src/Services/ClaudeAgentService.swift`

```swift
func fetchMessageHistory(sessionId: String) async throws -> [ClaudeChatMessage] {
    // First check UserDefaults cache
    if let cached = persistenceManager.loadMessages(for: sessionId), !cached.isEmpty {
        return cached
    }

    // If not in cache, fetch from backend
    let url = APIConfig.baseURL
        .appendingPathComponent("/api/sessions/\(sessionId)/messages")
    let (data, _) = try await URLSession.shared.data(from: url)
    let messages = try JSONDecoder().decode([ClaudeChatMessage].self, from: data)

    // Cache locally
    persistenceManager.setMessages(messages, for: sessionId)

    return messages
}
```

## Testing Plan

1. **Restart Backend** (already done ✅)
2. **Verify Sessions Exist:**
   ```bash
   curl http://localhost:8080/api/sessions | jq
   ```
3. **Implement Session Restoration** (code changes above)
4. **Test on Device:**
   - Create 2-3 chat conversations
   - Close app completely
   - Reopen app
   - Verify tabs are restored with message history

## Status

- **Backend:** ✅ Working, 13 sessions stored
- **iOS App:** ❌ Missing session restoration logic
- **Fix Status:** Not implemented (requires code changes above)

## Next Steps

1. Add `/api/sessions/{sessionId}/messages` backend endpoint
2. Implement `fetchStoredSessions()` in iOS service
3. Add session restoration logic to `ClaudeChatView.onAppear()`
4. Test end-to-end on physical device

---

**Created:** 2025-10-29
**Backend Status:** Running on port 8080 ✅
**Cloudflare Tunnel:** `api.builderos.app` → `localhost:8080` ✅
