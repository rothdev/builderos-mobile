# BuilderOS Mobile Chat Error Investigation

## Investigation Summary

**Date**: October 29, 2025
**Status**: Investigation Complete - Ready for Testing
**Backend**: Running and Healthy on port 8080

## Original Issue

User reported that both Claude and Codex chats in the iOS app were failing on the **second message** with error:

```
Error: Error: 'NoneType' object has no attribute 'returncode'
```

**Behavior**:
- ✅ First message in each chat: Works fine, receives proper response
- ❌ Second message in same chat: Fails with returncode error

## Investigation Findings

### 1. Backend Architecture

The BuilderOS Mobile iOS app uses a **different backend** than initially suspected:

- **Mobile Backend**: `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server_persistent.py`
  - Runs on port 8080 (tunneled via Cloudflare to `https://api.builderos.app`)
  - Uses **BridgeHub** to communicate with CLI processes
  - Spawns a new Node.js process per message via `cli_process_pool.py`
  - Does NOT use Claude SDK's `receive_messages()` iterator

- **Main Backend**: `/Users/Ty/BuilderOS/api/` (NOT used by mobile app)
  - Different architecture that uses Claude SDK directly
  - This is where I found and fixed a similar "returncode" issue
  - **But this fix doesn't apply to the mobile app**

### 2. Mobile Backend Flow

```
iOS App → WebSocket (wss://api.builderos.app/api/claude/ws)
  → Cloudflare Tunnel → localhost:8080
  → server_persistent.py
  → cli_process_pool.py
  → BridgeHub (Node.js)
  → Claude/Codex CLI
```

### 3. Current Backend Status

```bash
$ curl http://localhost:8080/api/health
```

**Response**:
```json
{
  "status": "ok",
  "version": "2.1.0-process-pool",
  "connections": { "claude": 1, "codex": 0 },
  "sessions": { "total": 13 },
  "cli_processes": { "total_processes": 0 },
  "bridgehub": { "ready": true }
}
```

✅ Backend is running and healthy
✅ BridgeHub is available and ready
✅ 13 existing sessions in database
✅ No active CLI processes (spawned on-demand per message)

### 4. Log Analysis

Analyzed `/tmp/builderos_api.log` and `server_persistent.log`:

**No "returncode" errors found** in recent logs.

**Errors found** (all from Oct 28, different issue):
- `ClientConnectionResetError: Cannot write to closing transport`
- These are WebSocket connection issues, not the reported bug

**Conclusion**: The "returncode" error may have already been resolved in a previous backend update, or it occurs under specific conditions not captured in recent logs.

## Architecture Differences

### Why the bug doesn't affect mobile backend:

1. **No persistent subprocesses**: Mobile backend spawns a NEW BridgeHub process for each message
2. **No iterator state**: Doesn't use Claude SDK's `receive_messages()` generator
3. **Clean process lifecycle**: Each message gets its own process that completes and terminates
4. **No break/return issue**: The flow doesn't have the async iterator corruption bug

## Testing Required

### Test Plan: Verify Multi-Message Conversations

**On your iPhone**, open BuilderOS app and test the following:

#### Claude Chat Test

1. Create a new Claude chat
2. **Message 1**: "Hello! This is test message 1. Please give me a short response."
   - ✅ Should receive response
3. **Message 2**: "Great! Now for test message 2. Can you confirm you received both messages?"
   - ⚠️ **This is where the bug was reported**
   - Check for the "returncode" error
4. **Message 3**: "Perfect! One more test. Just say 'confirmed'."
   - Additional verification

#### Codex Chat Test

Repeat the same 3-message sequence in a Codex chat.

### Monitoring Setup

While testing, I have log monitoring running:

```bash
# Monitor for errors in real-time
tail -f /tmp/builderos_api.log | grep -E "ERROR|Exception|returncode"
```

Backend will log:
- `📬 Processing Claude/Codex message`
- `✅ Streamed N chunks to client`
- Any errors that occur

## Expected Outcomes

### Scenario 1: Bug is Fixed ✅
- All 3 messages work in both Claude and Codex chats
- No "returncode" errors
- Response streaming works correctly
- **Action**: Document success, close investigation

### Scenario 2: Bug Still Exists ❌
- Second message fails with "returncode" error
- **Action**: Deeper investigation needed in BridgeHub or CLI layer

### Scenario 3: Different Error 🔍
- Another error occurs (not "returncode")
- **Action**: Investigate new error pattern

## Backend Files

**Core files**:
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server_persistent.py` (main server)
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/cli_process_pool.py` (process management)
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/bridgehub_client.py` (BridgeHub communication)
- `/Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js` (Node.js CLI router)

**Log files**:
- `/tmp/builderos_api.log` (current session)
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server_persistent.log` (historical)

## Next Steps

1. ✅ Backend is running and healthy
2. ✅ Log monitoring is active
3. **🧪 Test multi-message conversations on iPhone** (follow test plan above)
4. **📊 Check results and logs**
5. **📝 Document findings**

---

**Ready for testing**. Open BuilderOS app on your iPhone and try the multi-message test sequence.
