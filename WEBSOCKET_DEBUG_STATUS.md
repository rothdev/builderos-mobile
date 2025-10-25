# WebSocket Authentication Issue - Debug Status

## Current State (October 25, 2025 - 3:05 PM)

**Symptom:** iOS app shows "Connected" status but chat doesn't work. Server logs show WebSocket connections opening and immediately closing without receiving the API key.

##  What's Working

✅ iOS app successfully creates WebSocket connection
✅ iOS app successfully calls `connect()` function
✅ iOS app shows "Connected" green indicator
✅ Backend server accepts WebSocket connections
✅ Backend has correct API key loaded from `.env` file
✅ API key is correctly initialized in iOS Keychain

## What's NOT Working

❌ Server never receives the API key message from iOS app
❌ Authentication handshake never completes
❌ Messages cannot be sent

## Evidence

### Server Logs Pattern
```
INFO: WebSocket /api/claude/ws [accepted]
INFO: connection open
INFO: connection closed
```
**Analysis:** Server accepts connection, waits for API key message, times out, closes connection. No debug logs showing "Received API key" ever appear.

### iOS App Behavior
- Shows "Connected" status with green indicator
- No error messages in UI
- `connect()` function completes without throwing errors
- Code reaches line where it sets `isConnected = true`

**Analysis:** This means iOS code successfully:
1. Created WebSocket
2. Resumed WebSocket
3. Sent API key (or thinks it did)
4. Received "authenticated" response (or thinks it did)
5. Received "ready" JSON message (or thinks it did)

## Root Cause Hypothesis

The iOS app is calling `send()` before the WebSocket is fully in the "open" state. URLSessionWebSocketTask queues messages but may not transmit them if the socket closes before reaching the open state.

## Latest Code Changes

### Added WebSocket State Logging
File: `src/Services/ClaudeAgentService.swift` lines 98-114

```swift
// Check WebSocket state before sending
if let ws = webSocket {
    print("📊 WebSocket state before send: \(ws.state.rawValue)")
    // 0 = connecting, 1 = open, 2 = closing, 3 = closed
}

print("📤 Sending API key (first 8 chars: \(String(apiKey.prefix(8)))...)...")

do {
    try await send(text: apiKey)
    print("✅ API key sent to WebSocket")

    // Verify state after send
    if let ws = webSocket {
        print("📊 WebSocket state after send: \(ws.state.rawValue)")
    }
} catch {
    // Error handling...
}
```

**Expected output:**
- State = 0 (connecting) → **BUG: Sending before connection open**
- State = 1 (open) → **Correct: Should work**
- State = 2/3 (closing/closed) → **BUG: Connection already dead**

## Debugging Challenges

### iOS Simulator Log Capture Issues
- `simctl log stream` with emoji grep filters not capturing print() statements
- `simctl launch --console` doesn't show print() output
- Background log processes timing out before capturing relevant logs

**Why this matters:** Can't verify the WebSocket state values without seeing the logs.

## Next Steps

1. **Install and run latest build** (has state logging)
2. **Use Xcode Console** (more reliable than simctl for iOS logs)
3. **Check WebSocket state values** in logs
4. **If state = 0 (connecting):**
   - Add explicit wait for state == 1 before sending
   - Use KVO to observe state changes
   - Add retry logic for send operations

5. **If state = 1 (open):**
   - Issue is elsewhere (server-side timeout? Message format?)
   - Check network layer (Wireshark/Charles proxy)

## Files Modified Today

1. `src/BuilderOSApp.swift` - Added `APIConfig.loadSavedConfiguration()` call
2. `src/Services/APIConfig.swift` - No changes (already had load function)
3. `src/Services/ClaudeAgentService.swift` - Added comprehensive logging
4. `src/Views/ClaudeChatView.swift` - Enhanced error logging
5. `/Users/Ty/BuilderOS/api/.env` - Created with production API key
6. Server restarted multiple times with correct environment loading

## Backend Issue (Separate)

**Warning in server logs:**
```
/Users/Ty/BuilderOS/api/routes/claude_agent.py:89: RuntimeWarning:
coroutine 'ClaudeSDKClient.query' was never awaited
```

**Issue:** Line 89 calls `self.client.query(message)` without `await`
**Impact:** Separate from WebSocket auth issue, but needs fixing
**Fix:** Change to `await self.client.query(message)`

## Build Info

**Latest Build:** October 25, 2025 3:05 PM
**Build Path:** `/Users/Ty/Library/Developer/Xcode/DerivedData/BuilderOS-cyfwtkynlidjqialncespvsfvptf/Build/Products/Debug-iphonesimulator/BuilderOS.app`
**Build Status:** ✅ SUCCESS

## Test Environment

- **Simulator:** iPhone (booted)
- **iOS Version:** 17+
- **Backend Server:** Running on localhost:8080
- **WebSocket URL:** ws://localhost:8080/api/claude/ws
- **API Key:** Correctly configured in both iOS Keychain and server .env

## Summary

The core issue is that the iOS app's WebSocket send() operation is not successfully transmitting the API key to the server. The state logging added in the latest build should reveal whether this is a timing issue (sending before socket is open) or something else.

**Recommended Next Action:** Install latest build and check iOS console logs for WebSocket state values (📊 emojis).
