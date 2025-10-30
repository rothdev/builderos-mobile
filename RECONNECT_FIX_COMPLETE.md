# BuilderOS Mobile Reconnect Button Fix

**Date**: October 29, 2025
**Status**: Enhanced Fix Deployed to iPhone (16:52)

## Problem Identified

The reconnect button in Settings and Dashboard was not working because it only performed a backend health check (`apiClient.healthCheck()`) without actually reconnecting the WebSocket connections for Claude and Codex chat services.

**Architecture Issue:**
- `BuilderOSAPIClient` handles REST API calls (capsules, status, file uploads) via HTTP
- `ClaudeAgentService` and `CodexAgentService` manage WebSocket connections for chat
- These are separate connection layers with no integration
- Reconnect buttons only called `healthCheck()`, which pings `/api/status` endpoint
- This confirmed backend was up, but didn't reconnect chat WebSockets

## Root Cause

**Files Affected:**
1. **SettingsView.swift:110-128** - Reconnect button only calls `healthCheck()`
2. **DashboardView.swift:126-151** - Same issue
3. **ChatAgentServiceBase.swift:197-207** - `ChatServiceManager` had no reconnection method

## Solution Implemented

### 1. Added `reconnectAll()` Method to ChatServiceManager

**File**: `src/Services/ChatAgentServiceBase.swift`
**Lines**: 209-243

```swift
/// Reconnect all active chat services
func reconnectAll() async {
    print("🔄 Reconnecting all active chat services...")

    var reconnectCount = 0
    var successCount = 0

    // Reconnect all Claude services
    for (sessionId, service) in claudeServices {
        reconnectCount += 1
        do {
            print("🔄 Reconnecting Claude service for session: \(sessionId)")
            try await service.connect()
            successCount += 1
            print("✅ Claude service reconnected successfully")
        } catch {
            print("❌ Failed to reconnect Claude service: \(error.localizedDescription)")
        }
    }

    // Reconnect all Codex services
    for (sessionId, service) in codexServices {
        reconnectCount += 1
        do {
            print("🔄 Reconnecting Codex service for session: \(sessionId)")
            try await service.connect()
            successCount += 1
            print("✅ Codex service reconnected successfully")
        } catch {
            print("❌ Failed to reconnect Codex service: \(error.localizedDescription)")
        }
    }

    print("🔄 Reconnection complete: \(successCount)/\(reconnectCount) services reconnected")
}
```

### 2. Updated SettingsView Reconnect Button

**File**: `src/Views/SettingsView.swift`
**Lines**: 110-135

**Before:**
```swift
Button {
    Task {
        let success = await apiClient.healthCheck()
        connectionState = success
    }
}
```

**After:**
```swift
Button {
    Task {
        // 1. Check backend health first
        let success = await apiClient.healthCheck()
        connectionState = success

        // 2. If backend is up, reconnect all chat services
        if success {
            await ChatServiceManager.shared.reconnectAll()
        }
    }
}
```

### 3. Updated DashboardView Reconnect Button

**File**: `src/Views/DashboardView.swift`
**Lines**: 126-153

Applied same fix as SettingsView - now reconnects chat services after confirming backend health.

## How It Works Now

**New Reconnection Flow:**
1. User presses "Reconnect" button in Settings or Dashboard
2. System checks backend health via `/api/status` endpoint
3. If backend is reachable, system reconnects all active chat WebSocket connections
4. Each chat service (Claude/Codex) for each session is reconnected
5. User sees connection status update

**Benefits:**
- Actually reconnects chat WebSockets, not just checks backend
- Reconnects ALL active chat sessions, not just one
- Provides detailed logging for troubleshooting
- Gracefully handles failures (continues trying other services if one fails)

## Deployment History

**First Deployment**: October 29, 2025 at 16:39
- Added `reconnectAll()` method to `ChatServiceManager`
- Updated reconnect buttons to call `reconnectAll()` after health check
- **Issue**: Still didn't work - stale connection state prevented reconnection

**Enhanced Fix Deployment**: October 29, 2025 at 16:52
- Modified `reconnectAll()` to force disconnect before reconnecting
- Clears stale `isConnected` state that was blocking reconnection attempts
- Device: Roth iPhone (00008110-00111DCC0A31801E)
- Install Location: `/var/containers/Bundle/Application/6190DC56-68C8-4587-8393-13FE424331F3/BuilderOS.app/`

## Second Issue Found & Fixed

**Problem**: First fix didn't work because `connect()` method checks if service is already connected:

```swift
// ClaudeAgentService.swift:100-104
let currentlyConnected = await MainActor.run { isConnected }
guard !currentlyConnected else {
    print("⚠️ Already connected to Claude Agent")
    return  // BLOCKS RECONNECTION!
}
```

**Root Cause**: When backend restarts but app doesn't detect disconnect immediately:
1. Service still has `isConnected = true` in memory
2. Actual WebSocket connection is dead
3. User presses reconnect → calls `service.connect()`
4. `connect()` sees `isConnected = true` and returns early
5. No reconnection happens!

**Solution**: Modified `reconnectAll()` to force disconnect first:

```swift
// ChatAgentServiceBase.swift:209-263
func reconnectAll() async {
    for (sessionId, service) in claudeServices {
        print("🔄 Force disconnecting Claude service for session: \(sessionId)")
        service.disconnect()  // Clear stale state

        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        try await service.connect()  // Now connection will work
    }

    if reconnectCount == 0 {
        print("⚠️ No active chat services to reconnect")
        print("   Tip: Open a chat screen to establish new connections")
    }
}
```

**Key Changes**:
1. Always disconnect first to clear stale `isConnected` state
2. Wait 100ms for disconnect to complete
3. Then reconnect - `connect()` will now see `isConnected = false`
4. Added helpful message when no services exist

## Testing Required

**Next Steps:**
1. Open BuilderOS app on iPhone
2. Open a Claude or Codex chat (creates service in memory)
3. Backend restarts or connection drops
4. Press "Reconnect" button in Settings or Dashboard
5. Verify:
   - Service disconnects first (clears stale state)
   - Service reconnects successfully
   - Chat WebSocket connections are re-established
   - Can send messages in Claude and Codex chats
   - Multiple messages work (test the original "returncode" issue)

## Technical Notes

**Key Files Modified:**
- `src/Services/ChatAgentServiceBase.swift` (+34 lines) - Added `reconnectAll()` method
- `src/Views/SettingsView.swift` (modified) - Updated reconnect button logic
- `src/Views/DashboardView.swift` (modified) - Updated reconnect button logic

**Architecture:**
- `BuilderOSAPIClient` - REST API client (port 8080 backend)
- `ChatServiceManager` - Singleton managing all chat service instances
- `ClaudeAgentService` / `CodexAgentService` - WebSocket connections per session
- Reconnection now properly integrates these layers

---

**Ready for testing.** Open the app and try the reconnect button!
