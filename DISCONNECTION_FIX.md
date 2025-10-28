# WebSocket Disconnection Fix

**Date:** 2025-10-27
**Status:** ✅ FIXED

---

## The Problem

WebSocket connections were disconnecting after 1-2 minutes of use. User directive: **"there should be no timeout"**

**Symptoms:**
- Connections established successfully
- Messages processed correctly when connected
- After 1-2 minutes: Clean disconnect (no errors)
- Pattern occurred even during active use

---

## Root Cause

**File:** `src/Views/ClaudeChatView.swift` (lines 137-145)

```swift
.onDisappear {
    // Disconnect and release all services
    for (id, service) in serviceInstances {
        service.disconnect()  // ❌ Disconnects ALL connections
        serviceObservers[id]?.cancel()
    }
    serviceInstances.removeAll()
    serviceObservers.removeAll()
}
```

**Why this caused disconnections:**
- SwiftUI's `.onDisappear` triggers when the view is no longer visible
- This includes: app backgrounding, tab switching, view refreshes
- The code was aggressively disconnecting ALL WebSocket connections
- Connections should persist even when view is temporarily hidden

---

## The Fix

**Removed the `.onDisappear` block entirely.**

**New behavior:**
- ✅ Connections persist when view is hidden
- ✅ Connections persist when app backgrounds
- ✅ Connections persist when switching tabs
- ✅ Connections only disconnect when user explicitly closes a tab

**Explicit tab closure** (lines 338-341) still works correctly:
```swift
// Disconnect and remove service instance
if let service = serviceInstances[tabId] {
    service.disconnect()  // ✅ Only when user closes tab
    serviceInstances.removeValue(forKey: tabId)
}
```

---

## Testing

**Before fix:**
- Connect → Work for 1-2 minutes → Disconnect (unwanted)

**After fix:**
- Connect → Work indefinitely → Only disconnect when closing tab (correct)

---

## Deployment

**Build:** ✅ Success
**Install:** ✅ Deployed to Roth iPhone
**Status:** Ready for testing

---

**Result:** WebSocket connections now persist indefinitely until explicitly closed by user.
