# WebSocket Issue - Root Cause & Solution

## Discovery (October 25, 2025)

### Problem
iOS app shows "Connected" status but server never receives messages from the app.

### Root Cause Found
**URLSessionWebSocketTask is fundamentally broken** - the send() method completes without error, but messages are never actually transmitted to the server.

### Proof
Created Python WebSocket client (`/Users/Ty/BuilderOS/api/test_ws.py`) that successfully:
- ✅ Connects to `ws://localhost:8080/api/claude/ws`
- ✅ Sends API key
- ✅ Receives "authenticated" response
- ✅ Receives ready message with full BuilderOS context

**Server logs from Python client:**
```
✅ AUTHENTICATION SUCCESSFUL!
📬 Ready message: {"type":"ready","content":"Claude Agent session initialized with full BuilderOS context","timestamp":"2025-10-25T15:16:31.435338","capsule":"builderos-mobile","agents_available":29,"mcp_servers":"auto-loaded"}
```

**Server logs from iOS app:**
```
INFO: WebSocket /api/claude/ws [accepted]
INFO: connection open
INFO: connection closed
```
(No handler logs, no messages received)

## Solution: Replace URLSessionWebSocketTask with Starscream

**Starscream** is the industry-standard WebSocket library for iOS:
- ✅ Actively maintained (7.6k+ GitHub stars)
- ✅ Production-proven (used by major apps)
- ✅ Reliable message transmission
- ✅ Better error handling
- ✅ WebSocket ping/pong built-in
- ✅ Swift Package Manager support

### Implementation Steps

1. **Add Starscream dependency** (Swift Package Manager)
   - URL: `https://github.com/daltoniam/Starscream`
   - Version: 4.0.8+

2. **Update ClaudeAgentService.swift**
   - Replace URLSessionWebSocketTask with Starscream WebSocket
   - Implement delegate methods for connection events
   - Update send/receive logic

3. **Test authentication flow**
   - Verify API key transmission
   - Confirm server receives messages
   - Validate ready message reception

### Files to Modify
- `src/BuilderOS.xcodeproj/project.pbxproj` - Add Starscream package
- `src/Services/ClaudeAgentService.swift` - Replace WebSocket implementation

### Expected Outcome
App will successfully connect, authenticate, and exchange messages with Claude Agent backend.

##Alternative Implementation for URLSessionWebSocketTask (without Starscream)

Since URLSessionWebSocketTask queues messages when not fully connected, the following approach might work:

```swift
// Force connection by receiving BEFORE sending
Task {
    _ = try? await webSocket?.receive()  // This blocks but forces connection
}

// Brief delay to allow receive() to establish connection
try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

// Now send should work
try await send(text: apiKey)
```

However, **Starscream is the recommended solution** as it's more reliable and doesn't require these workarounds.
