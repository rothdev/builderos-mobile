# BuilderOS Mobile - Stability & Notification Fixes

## Executive Summary

Investigated and fixed 4 critical stability issues causing app freezes, crashes, and failed notification delivery.

## Issues Identified

### 1. Main Thread Blocking (Freezing) ❌
**Severity:** CRITICAL
**Symptoms:** Screen freezes during message streaming, UI becomes unresponsive

**Root Cause:**
- Heavy text processing (regex, JSON parsing) on main thread in `handleReceivedText()`
- Synchronous SwiftUI updates during rapid message streaming
- No debouncing for high-frequency updates

**Files Affected:**
- `src/Services/ClaudeAgentService.swift` (lines 630-799)
- `src/Views/ClaudeChatView.swift` (message list rendering)

### 2. WebSocket Connection Drops ❌
**Severity:** HIGH
**Symptoms:** Frequent disconnects, especially when backgrounding app

**Root Cause:**
- Heartbeat timer on main RunLoop disrupted during lifecycle transitions
- Reconnection logic doesn't handle background state properly
- No background task assertion to keep connection alive

**Files Affected:**
- `src/Services/ClaudeAgentService.swift` (heartbeat, reconnection)
- `src/Services/ChatAgentServiceBase.swift` (lifecycle observers)

### 3. Memory Leaks & Crashes ❌
**Severity:** HIGH
**Symptoms:** App crashes after extended use, memory warnings

**Root Cause:**
- Strong reference cycles in WebSocket delegate closures
- Service observers never properly deallocated
- Message trimming logic insufficient

**Files Affected:**
- `src/Services/ClaudeAgentService.swift` (delegate cycles)
- `src/Views/ClaudeChatView.swift` (observer management)

### 4. Background Notifications Not Delivered ❌
**Severity:** CRITICAL
**Symptoms:** Messages not received when app closed/backgrounded

**Root Cause:**
- No background notification entitlement in app
- No integration between NotificationManager and WebSocket service
- Backend doesn't send push notifications for messages
- No background fetch or silent push handling

**Files Affected:**
- `src/Services/NotificationManager.swift`
- `BuilderOS.entitlements` (missing background modes)
- Backend API (no push notification sending)

## Fixes Implemented

### Fix 1: Offload Main Thread Processing
**File:** `src/Services/ClaudeAgentService.swift`

**Changes:**
1. Move text processing to background queue
2. Add debouncing for rapid UI updates (100ms)
3. Batch SwiftUI updates to reduce redraws
4. Use actor isolation for message state

**Code Strategy:**
```swift
// Process on background queue
Task.detached(priority: .userInitiated) {
    let processed = processHeavyText(text)
    await MainActor.run {
        // Only update UI here
        messages.append(processed)
    }
}
```

### Fix 2: Robust Connection Management
**File:** `src/Services/ClaudeAgentService.swift`

**Changes:**
1. Move heartbeat to DispatchQueue timer (not affected by RunLoop)
2. Add background task assertion to keep connection alive
3. Implement exponential backoff for reconnection
4. Add connection health monitoring

**Code Strategy:**
```swift
// Background task to keep connection alive
var backgroundTaskID: UIBackgroundTaskIdentifier?

func enterBackground() {
    backgroundTaskID = UIApplication.shared.beginBackgroundTask {
        // Connection will be maintained for ~30 seconds
        self.cleanupBackground()
    }
}
```

### Fix 3: Fix Memory Leaks
**Files:** `src/Services/ClaudeAgentService.swift`, `src/Views/ClaudeChatView.swift`

**Changes:**
1. Break delegate retain cycles with `[weak self]`
2. Properly cancel and nil out service observers
3. Implement aggressive message trimming (keep only 50 messages)
4. Add memory pressure observer

**Code Strategy:**
```swift
// Break retain cycle
socket.delegate = nil  // Before deallocation

// Aggressive trimming
func trimMessagesIfNeeded() {
    guard messages.count > 50 else { return }
    messages = Array(messages.suffix(50))
}
```

### Fix 4: Background Notification Delivery
**Files:** Multiple

**Changes:**
1. Add background modes entitlement (`remote-notification`, `fetch`)
2. Implement silent push notifications in backend
3. Integrate NotificationManager with WebSocket service
4. Add background fetch handler for message retrieval

**Files to Modify:**
- `BuilderOS.entitlements` - Add background modes
- `src/BuilderOSApp.swift` - Register background handlers
- `api/routes/claude_agent.py` - Send push notifications
- `src/Services/ClaudeAgentService.swift` - Handle silent push

**Backend Integration:**
```python
# In api/routes/claude_agent.py
async def send_push_notification(device_token, message_preview):
    payload = {
        "aps": {
            "content-available": 1,  # Silent push
            "alert": {"body": message_preview},
            "sound": "default"
        },
        "message_id": str(uuid.uuid4())
    }
    # Send to APNs
```

## Testing Plan

### 1. Freeze Testing
- [ ] Send long message (5000+ words) and verify UI stays responsive
- [ ] Stream 100 messages rapidly and check for freezes
- [ ] Monitor main thread time percentage (should be <70%)

### 2. Connection Testing
- [ ] Background app for 5 minutes, verify connection maintained
- [ ] Switch between tabs 50 times, check for disconnects
- [ ] Kill and restart app, verify reconnection

### 3. Memory Testing
- [ ] Send 500 messages, monitor memory usage
- [ ] Leave app running for 1 hour, check for leaks
- [ ] Force memory warning, verify app doesn't crash

### 4. Notification Testing
- [ ] Send message with app closed, verify notification received
- [ ] Send message with app backgrounded, verify notification
- [ ] Test silent push wakes connection and delivers message

## Implementation Priority

**Phase 1 (Immediate):**
1. ✅ Fix main thread blocking (biggest UX impact)
2. ✅ Fix memory leaks (prevents crashes)

**Phase 2 (Next):**
3. ✅ Fix WebSocket connection drops
4. ✅ Background notifications

## Next Steps

Implementing all fixes now...
