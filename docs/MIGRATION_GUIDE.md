# BuilderOS Mobile Backend Migration Guide

**Version:** 2.0 (Session-Persistent)
**Migration Date:** 2025-10-27
**Status:** Ready for Testing

---

## Overview

This guide covers migrating BuilderOS Mobile from the stateless backend (`server.py`) to the session-persistent backend (`server_persistent.py`) with full BridgeHub integration.

---

## What's Changing

### Architecture Changes

**Before (v1.0 - Stateless):**
- Each message processed independently
- Zero conversation history
- Direct Anthropic API calls
- No agent coordination
- Context lost between messages

**After (v2.0 - Session-Persistent):**
- Full conversation history retained
- SQLite session persistence
- BridgeHub integration for agent coordination
- CLAUDE.md context loaded for Jarvis
- Sessions survive reconnects
- Multi-device support (same session across devices)

### Backend Changes

| Component | Old | New |
|-----------|-----|-----|
| **API Server** | `api/server.py` | `api/server_persistent.py` |
| **Session Management** | None | `api/session_manager.py` |
| **BridgeHub Integration** | None | `api/bridgehub_client.py` |
| **Database** | None | `api/sessions.db` (SQLite) |
| **Message Format** | `{"content": "text"}` | `{"content": "text", "session_id": "xxx", "device_id": "yyy"}` |

---

## Migration Steps

### Step 1: Backup Current Server

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile

# Backup old server
cp api/server.py api/server.py.backup

# Verify backup
ls -l api/server.py.backup
```

### Step 2: Install New Backend Files

The following files are already created:
- ✅ `api/session_manager.py` - Session persistence layer
- ✅ `api/bridgehub_client.py` - BridgeHub integration
- ✅ `api/server_persistent.py` - New persistent server

**No additional installation needed** - files are ready to use.

### Step 3: Test SessionManager

```bash
# Test session management
python3 api/session_manager.py

# Expected output:
# ✅ Database initialized: /tmp/test_sessions.db
# ✨ Created new session 'test-session-1' (claude)
# Session has 2 messages
# Stats: {'total': 1, 'by_agent': {'claude': 1, 'codex': 0}}
```

### Step 4: Test BridgeHub Client

```bash
# Test BridgeHub health check
python3 -c "
import asyncio
from api.bridgehub_client import BridgeHubClient

async def test():
    health = await BridgeHubClient.health_check()
    print(f'BridgeHub exists: {health[\"bridgehub_exists\"]}')
    print(f'Node.js available: {health[\"node_available\"]}')
    print(f'Ready: {health[\"ready\"]}')

asyncio.run(test())
"

# Expected output:
# BridgeHub exists: True
# Node.js available: True
# Ready: True
```

### Step 5: Stop Old Server

```bash
# Find process running on port 8080
lsof -ti:8080

# Kill process (if running)
kill $(lsof -ti:8080)

# Or use pkill
pkill -f "python3 api/server.py"
```

### Step 6: Start New Server

```bash
# Start persistent server
python3 api/server_persistent.py

# Expected output:
# ============================================================
# 🚀 BuilderOS Mobile API Server v2.0 (Session-Persistent)
# ============================================================
# 📡 Listening on http://localhost:8080
# 🔌 WebSocket endpoints:
#    - ws://localhost:8080/api/claude/ws (Jarvis)
#    - ws://localhost:8080/api/codex/ws (Codex)
# 💾 Session database: api/sessions.db
# 📚 Active sessions: 0
# ============================================================
```

### Step 7: Verify Health

```bash
# Check health endpoint
curl http://localhost:8080/api/health | jq .

# Expected response:
# {
#   "status": "ok",
#   "version": "2.0.0-persistent",
#   "connections": {
#     "claude": 0,
#     "codex": 0
#   },
#   "sessions": {
#     "total": 0,
#     "by_agent": {"claude": 0, "codex": 0}
#   },
#   "bridgehub": {
#     "bridgehub_exists": true,
#     "node_available": true,
#     "ready": true
#   }
# }
```

---

## iOS App Changes

### Minimal Updates Required

The iOS app needs **small changes** to include session metadata in messages.

#### 1. Update Message Format

**File:** `src/Services/ClaudeAgentService.swift`

**Current:**
```swift
let messageJSON = ["content": text]
```

**New:**
```swift
let messageJSON: [String: Any] = [
    "content": text,
    "session_id": self.sessionId,
    "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
]
```

#### 2. Add Session ID Property

**File:** `src/Services/ClaudeAgentService.swift`

```swift
class ClaudeAgentService {
    private let sessionId: String

    override init() {
        super.init()

        // Generate or load persistent session ID
        if let savedSessionId = UserDefaults.standard.string(forKey: "claude_session_id") {
            self.sessionId = savedSessionId
        } else {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            let newSessionId = "mobile-jarvis-\(deviceId)"
            UserDefaults.standard.set(newSessionId, forKey: "claude_session_id")
            self.sessionId = newSessionId
        }

        print("📋 Claude session ID: \(self.sessionId)")
    }
}
```

#### 3. Same Changes for Codex Service

**File:** `src/Services/CodexAgentService.swift`

Apply the same changes:
- Add `sessionId` property
- Generate persistent session ID (key: `"codex_session_id"`, prefix: `"mobile-codex-"`)
- Include in message JSON

---

## Testing Checklist

### Backend Testing

- [ ] **SessionManager Tests**
  - [ ] Session creation works
  - [ ] Messages added to history
  - [ ] Session persists to database
  - [ ] Session loads from database
  - [ ] CLAUDE.md context loaded

- [ ] **BridgeHub Integration**
  - [ ] Health check passes
  - [ ] BridgeHub executable found
  - [ ] Node.js available
  - [ ] Payload format correct

- [ ] **API Server**
  - [ ] Server starts successfully
  - [ ] Health endpoint returns OK
  - [ ] WebSocket endpoints accessible
  - [ ] Authentication works

### iOS App Testing

- [ ] **Connection**
  - [ ] iOS app connects to new server
  - [ ] Authentication successful
  - [ ] "ready" message received

- [ ] **Session Persistence**
  - [ ] Session ID generated on first launch
  - [ ] Session ID persists across app restarts
  - [ ] Session ID included in messages
  - [ ] Device ID included in messages

- [ ] **Multi-Turn Conversations**
  - [ ] Send message → receive response
  - [ ] Send follow-up message
  - [ ] Context from first message retained
  - [ ] Verify conversation history on server

- [ ] **Session Switching**
  - [ ] Switch from Jarvis to Codex
  - [ ] Codex session independent from Jarvis
  - [ ] Switch back to Jarvis
  - [ ] Jarvis session state preserved

- [ ] **Reconnection**
  - [ ] Disconnect iOS app
  - [ ] Reconnect iOS app
  - [ ] Session continues with history
  - [ ] No context loss

### End-to-End Testing

- [ ] **Multi-Device Sync**
  - [ ] Start conversation on iPhone
  - [ ] Continue same session on iPad (same session_id)
  - [ ] Verify shared history

- [ ] **Agent Coordination** (Advanced)
  - [ ] Send message that triggers agent delegation
  - [ ] Verify agent execution via BridgeHub
  - [ ] Verify agent output returned to iOS

---

## Rollback Plan

If issues occur, rollback to old server:

```bash
# 1. Stop new server
pkill -f "python3 api/server_persistent.py"

# 2. Start old server
python3 api/server.py.backup

# 3. Revert iOS app changes (remove session_id from messages)

# 4. Rebuild iOS app
```

---

## Database Management

### Location

```
/Users/Ty/BuilderOS/capsules/builderos-mobile/api/sessions.db
```

### Backup

```bash
# Manual backup
cp api/sessions.db api/sessions.db.backup.$(date +%Y%m%d)

# Automated backup (add to cron)
0 3 * * * cd /Users/Ty/BuilderOS/capsules/builderos-mobile && cp api/sessions.db api/sessions.db.backup.$(date +\%Y\%m\%d)
```

### Cleanup

```bash
# Remove sessions older than 30 days (automatic on server startup)
python3 -c "
from api.session_manager import SessionManager
sm = SessionManager()
deleted = sm.cleanup_old_sessions(days=30)
print(f'Deleted {deleted} old sessions')
"
```

### Inspect Sessions

```bash
# View active sessions
curl http://localhost:8080/api/sessions | jq .

# Output:
# {
#   "total": 3,
#   "sessions": [
#     {
#       "session_id": "mobile-jarvis-abc123",
#       "agent_type": "claude",
#       "message_count": 15,
#       "created_at": "2025-10-27T12:00:00Z",
#       "last_activity": "2025-10-27T15:30:00Z"
#     },
#     ...
#   ]
# }
```

---

## Troubleshooting

### Issue: Server won't start

**Symptom:** `ImportError: No module named 'session_manager'`

**Solution:**
```bash
# Ensure api/__init__.py exists
touch api/__init__.py

# Or run from capsule root
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
python3 api/server_persistent.py
```

### Issue: BridgeHub not found

**Symptom:** `Error: BridgeHub not found at /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js`

**Solution:**
```bash
# Verify BridgeHub exists
ls -l /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js

# If missing, rebuild BridgeHub
cd /Users/Ty/BuilderOS/tools/bridgehub
npm install
npm run build
```

### Issue: Node.js not available

**Symptom:** `Error: Node.js not found`

**Solution:**
```bash
# Install Node.js (if not installed)
brew install node

# Verify Node.js
node --version
```

### Issue: Sessions not persisting

**Symptom:** Session history lost after reconnect

**Solution:**
```bash
# Check database exists and is writable
ls -l api/sessions.db

# Check database contents
sqlite3 api/sessions.db "SELECT session_id, last_activity FROM sessions;"

# Check server logs for persistence errors
# Look for "💾 Session persisted" log messages
```

### Issue: iOS app can't connect

**Symptom:** WebSocket connection fails

**Solution:**
```bash
# 1. Verify server is running
curl http://localhost:8080/api/health

# 2. Check port is open
lsof -ti:8080

# 3. Check iOS app baseURL matches
# Should be: http://localhost:8080 (or Mac's IP address)

# 4. Verify API key in iOS app matches server
# Server: "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3"
```

---

## Performance Considerations

### Memory Usage

- **In-Memory Sessions:** Sessions from last 7 days loaded into memory
- **Estimated Memory:** ~1MB per 100 messages (~10KB per message)
- **Mitigation:** Cleanup job removes old sessions

### Database Size

- **Growth Rate:** ~10KB per message
- **Estimated Size:** 1000 messages = ~10MB
- **Mitigation:** Auto-cleanup after 30 days

### BridgeHub Latency

- **Subprocess Spawn:** ~100-300ms overhead
- **Claude Code Response:** 1-5 seconds (depending on complexity)
- **Total Latency:** Similar to desktop Claude Code experience

---

## Next Steps

### Phase 2 Enhancements (Future)

1. **Agent Task Tracking**
   - Track agent execution status
   - Show progress in iOS UI
   - Push notifications on completion

2. **Multi-Device Real-time Sync**
   - WebSocket broadcast to all connected devices
   - Real-time session updates

3. **Voice Integration**
   - Voice input → transcription → session
   - TTS responses from BridgeHub

4. **Capsule Context Loading**
   - Associate sessions with capsules
   - Load capsule-specific context

5. **Offline Mode**
   - Queue messages when offline
   - Sync when connection restored

---

## Summary

**Migration Complexity:** Low
**iOS Changes:** Minimal (add 2 fields to message JSON)
**Backend Changes:** Complete rewrite (but backward compatible)
**Risk Level:** Low (old server preserved as backup)
**Recommended Approach:** Test on development device first, then production

**Key Benefits:**
✅ Full conversation history
✅ Agent coordination
✅ Context awareness (CLAUDE.md)
✅ Session persistence
✅ Multi-device support
✅ Reconnection resilience

**Migration Time Estimate:**
- Backend setup: 10 minutes
- iOS app changes: 30 minutes
- Testing: 1-2 hours
- **Total:** ~2-3 hours

---

**End of Migration Guide**

For questions or issues, refer to:
- Architecture: `docs/SESSION_PERSISTENCE_ARCHITECTURE.md`
- Communication Analysis: `MOBILE_COMMUNICATION_ARCHITECTURE.md`
