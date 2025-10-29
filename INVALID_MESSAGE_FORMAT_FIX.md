# Invalid Message Format Error - Fixed

## Problem
Users were seeing "Error: Invalid message format" message bubble appearing in brand new Claude or Codex chats immediately upon opening, before sending any messages.

## Root Cause
During WebSocket connection handshake, the app was attempting to decode all received messages as `ClaudeResponse`/`CodexResponse` JSON structures, even system/handshake messages:

1. **Connection flow:**
   - Client sends: API key
   - Server responds: "authenticated" (plain text)
   - Client sends: Session config JSON `{"working_directory": "/Users/Ty/BuilderOS"}`
   - Server may respond: Echo of config or confirmation (non-ClaudeResponse format)
   - Server sends: `{"type": "ready", ...}` (ClaudeResponse format)

2. **The bug:**
   - When server echoed session config or sent any non-ClaudeResponse message
   - `JSONDecoder().decode(ClaudeResponse.self, ...)` would fail
   - Original code was adding "Invalid message format" error to `messages` array
   - This error appeared in the UI immediately

## Solution
Modified `handleReceivedText()` in both `ClaudeAgentService.swift` and `CodexAgentService.swift`:

### Key Changes:

**1. Added connection phase detection:**
```swift
if authenticationComplete {
    // After connection complete - show errors to user
    let errorMsg = ClaudeChatMessage(
        text: "Error: Invalid message format",
        isUser: false
    )
    messages.append(errorMsg)
} else {
    // During connection phase - just log, don't show UI error
    print("Still in connection phase, ignoring unparseable message")
}
```

**2. Added session config echo handling:**
```swift
// Handle session config confirmation (server may echo back the config we sent)
if text.contains("working_directory") && !authenticationComplete {
    print("Received session config confirmation/echo, ignoring")
    return
}
```

**3. Added comprehensive debug logging:**
```swift
print("🔍 [DEBUG] handleReceivedText called with: \(text.prefix(200))")
print("🔍 [DEBUG] Current message count: \(messages.count)")
print("🔍 [DEBUG] isLoading: \(isLoading), authComplete: \(authenticationComplete), authReceived: \(authenticationReceived)")
```

## Expected Behavior After Fix

### Before Connection Complete (`authenticationComplete == false`)
- ✅ "authenticated" → handled, no UI message
- ✅ Session config echo → handled, no UI message
- ✅ Any other unparseable message → logged, no UI message
- ✅ "ready" JSON → decoded successfully, sets `authenticationComplete = true`

### After Connection Complete (`authenticationComplete == true`)
- ✅ Valid ClaudeResponse JSON → processed normally
- ✅ Invalid/malformed messages → error shown to user (correct behavior)

## Files Modified
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/src/Services/ClaudeAgentService.swift` (lines 577-632)
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/src/Services/CodexAgentService.swift` (lines 461-512)

## Testing Instructions

### Test 1: New Claude Chat
1. Build and run app on simulator
2. Tap "New Chat" button
3. Select "Claude Agent"
4. Verify: Chat window opens with NO error messages
5. Verify: Empty state or welcome message shown
6. Send a test message: "Hello"
7. Verify: Response appears normally

### Test 2: New Codex Chat
1. Tap "New Chat" button
2. Select "Codex CLI"
3. Verify: Chat window opens with NO error messages
4. Verify: Empty state shown
5. Send a test message: "ls"
6. Verify: Response appears normally

### Test 3: Multiple New Chats
1. Create 5 new Claude chats in succession
2. Verify: NONE show "Invalid message format" error
3. Create 5 new Codex chats in succession
4. Verify: NONE show "Invalid message format" error

### Test 4: Error Messages Still Work (Post-Connection)
1. Create new chat and wait for connection
2. Manually trigger invalid response from server (if possible)
3. Verify: Error message DOES appear (correct behavior for actual errors)

## Debug Logs to Monitor
When testing, watch Xcode console for these log lines:

```
🔍 [DEBUG] handleReceivedText called with: ...
🔍 [DEBUG] Current message count: 0
🔍 [DEBUG] isLoading: false, authComplete: false, authReceived: false
✅ Authentication successful! Received 'authenticated' confirmation
📋 Received session config confirmation/echo, ignoring
✅ Claude Agent ready: ...
🔍 [DEBUG] Still in connection phase, ignoring unparseable message
```

## Success Criteria
- ✅ No "Invalid message format" errors in brand new chats
- ✅ Connection handshake completes silently
- ✅ First message bubble only appears after user sends something
- ✅ Error messages still work for actual malformed messages during active chat
- ✅ Both Claude and Codex chats work correctly

## Build Command
```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src
xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## Status
- [x] Root cause identified
- [x] Fix implemented in ClaudeAgentService
- [x] Fix implemented in CodexAgentService
- [x] Debug logging added
- [x] Code reviewed for correctness
- [ ] Tested on simulator
- [ ] Multiple chat tests completed
- [ ] User acceptance test passed

---
**Fixed:** October 28, 2025
**Files:** ClaudeAgentService.swift, CodexAgentService.swift
**Issue:** Invalid message format error in brand new chats
**Resolution:** Distinguish connection phase from chat phase in message handling
