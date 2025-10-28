# Dashboard Connection Status UI Fix

## Problem
Dashboard and Settings screens showed "DISCONNECTED" despite:
- Health check API calls succeeding (200 OK responses)
- Chat functionality working correctly
- Backend logs confirming successful connections

## Root Cause
SwiftUI `@Published` property wrapper only fires change notifications when a property's value actually changes. If `isConnected` was already `true` from a previous health check, setting it to `true` again did not trigger UI updates.

## Solution
Force a toggle to ensure `@Published` always fires:

```swift
if httpResponse.statusCode == 200 {
    // Force toggle if already true
    if isConnected {
        isConnected = false
    }
    isConnected = true
    return true
}
```

This ensures SwiftUI views receive change notifications on every successful health check, not just the first one.

## Files Modified
- `src/Services/BuilderOSAPIClient.swift:356-366` - Added forced toggle logic
- `src/Views/DashboardView.swift:20` - Added debug logging for body renders
- `src/Views/SettingsView.swift:25` - Added debug logging for body renders
- `src/Services/BuilderOSAPIClient.swift:17-21` - Added didSet observer for connection changes

## Testing
1. Backend logs confirm `/api/status` returns 200 OK
2. App makes health check requests on Dashboard view load
3. Property toggle ensures UI updates show "CONNECTED" state

## Date
2025-10-28 16:36
