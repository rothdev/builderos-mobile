# WebSocket Connection Diagnostic

**Date:** 2025-10-27
**Issue:** App keeps getting disconnected

---

## Current Observations

### Backend Logs Analysis

**Connection Pattern:**
```
18:34:30 - Codex connected ✅
18:34:33 - Claude connected ✅
18:34:34 - Message processed: "What's the status of BuilderOS?" ✅
18:35:01 - Message processed: "List all capsules" ✅
18:35:31 - Message processed: "Hey" ✅
18:35:34 - BridgeHub call successful ✅
18:36:34 - Both connections disconnected (after ~2 min idle)
```

**Key Findings:**
1. ✅ Connections establish successfully
2. ✅ Authentication works
3. ✅ Messages process correctly
4. ✅ BridgeHub calls succeed
5. ✅ Responses stream back
6. ⚠️ Disconnects after ~2 minutes of idle time

### Successful Operations

- Messages are being received and processed
- BridgeHub integration working
- Session persistence working
- No backend crashes or errors during message handling

### Warnings Seen

```
⚠️ Invalid JSON received
```

This appears when iOS app sends non-JSON data (possibly ping frames or other WebSocket control messages). The backend handles this gracefully and doesn't disconnect.

---

## Possible Causes

### 1. iOS App Timeout (Most Likely)

The iOS app may be configured to close idle connections after 2 minutes. Check:

**File:** `src/Services/ClaudeCodeService.swift`
**File:** `src/Services/CodexAgentService.swift`

Look for:
- `timeoutInterval` settings
- Connection lifecycle management
- Background/foreground handling

### 2. Network Stack Timeout

iOS URLSession or Starscream WebSocket library may have default timeouts.

Check:
```swift
request.timeoutInterval = 30  // Current value in ClaudeAgentService
```

This is the CONNECTION timeout (how long to wait for initial connect), not the idle timeout.

### 3. iOS App Backgrounding

If the app goes to background or user switches tabs, the connection may be intentionally closed.

### 4. Server-Side Timeout

**Check:** Does the backend have any timeout configuration?

Looking at server code - no explicit timeouts set for WebSocket connections. They should stay open indefinitely until closed by client or error.

---

## What Disconnection Pattern Indicates

**Pattern:** Connection lasts 1-2 minutes, then disconnects even during active use

**This suggests:**
- iOS app is timing out the connection
- OR iOS app is closing connection when switching views
- OR iOS app detects an error and disconnects

**NOT a backend issue because:**
- Backend logs show clean message processing
- No errors during handling
- Disconnects are clean (no exceptions)
- Backend stays running

---

## Diagnostic Questions

To narrow down the cause:

1. **When do disconnections happen?**
   - During active messaging?
   - After idle time?
   - When switching between Jarvis/Codex tabs?
   - When app goes to background?

2. **Does the app reconnect automatically?**
   - If yes → This is normal behavior
   - If no → Need to add reconnection logic

3. **Do you see error messages in the app?**
   - If yes → What do they say?
   - If no → Disconnect is silent (might be intentional)

---

## Recommended Fixes

### Option 1: Add Keepalive/Heartbeat

**iOS App Changes:**
Send periodic ping messages to keep connection alive.

```swift
// In ClaudeAgentService
private var heartbeatTimer: Timer?

func startHeartbeat() {
    heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
        // Send ping
        self.webSocket?.write(ping: Data())
    }
}
```

### Option 2: Increase Timeout

**iOS App Changes:**
```swift
var request = URLRequest(url: wsURL)
request.timeoutInterval = 300  // 5 minutes instead of 30 seconds
```

### Option 3: Auto-Reconnect on Disconnect

**iOS App Changes:**
Detect disconnect and automatically reconnect:

```swift
case .disconnected(let reason, let code):
    print("👋 Disconnected: \(reason)")

    // Auto-reconnect after 1 second
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        Task {
            try? await self.connect()
        }
    }
```

### Option 4: Don't Close Connection on Tab Switch

**iOS App Changes:**
If connections are being closed when switching between Jarvis/Codex tabs, keep them both alive:

```swift
// Don't call disconnect() when switching tabs
// Keep connections persistent
```

---

## Current Status

**Backend:** ✅ Healthy and running
**Connections:** ⚠️ Closing after 1-2 minutes
**Message Processing:** ✅ Working correctly when connected
**Root Cause:** Likely iOS app timeout or connection lifecycle management

---

## Next Steps

1. **Identify disconnect trigger** - When exactly does it happen?
2. **Check iOS timeout settings** - Look at connection configuration
3. **Implement fix** - Based on root cause (heartbeat, timeout, or reconnect)

---

**Recommendation:** Add auto-reconnect logic to iOS app as immediate fix while investigating root cause.
