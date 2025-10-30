# Background Updates & Push Notifications Implementation

**Status:** ✅ Implemented
**Date:** 2025-10-30
**Version:** 1.0

## Overview

BuilderOS Mobile now supports background updates and push notifications for real-time message alerts when the app is not in the foreground.

## Features Implemented

### 1. Background Modes
- ✅ Remote notifications (`remote-notification`)
- ✅ Background fetch (`fetch`)
- ✅ Background task scheduling
- ✅ Network authentication (for VPN persistence)

### 2. Push Notifications
- ✅ Device token registration with backend
- ✅ Local notification delivery for new messages
- ✅ Notification handling when app is backgrounded
- ✅ Badge management
- ✅ Notification tap handling

### 3. Background Fetch
- ✅ Periodic background refresh (every 15 minutes minimum)
- ✅ Modern BGTaskScheduler API
- ✅ Legacy background fetch API (for iOS compatibility)
- ✅ Background sync placeholder (ready for implementation)

## Architecture

### iOS App Components

#### 1. Info.plist Configuration
**Location:** `src/Info.plist`

Added background modes:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>network-authentication</string>
    <string>processing</string>
    <string>remote-notification</string>
    <string>fetch</string>
</array>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.builderos.ios.refresh</string>
</array>
```

#### 2. AppDelegate (BuilderOSApp.swift)
**Location:** `src/BuilderOSApp.swift`

Handles:
- Background task registration
- Background fetch scheduling
- Remote notification reception
- Device token management

Key methods:
- `registerBackgroundTasks()` - Register BGTaskScheduler tasks
- `scheduleBackgroundRefresh()` - Schedule next background refresh
- `handleBackgroundRefresh()` - Execute background sync
- `didReceiveRemoteNotification()` - Handle push notifications

#### 3. NotificationManager
**Location:** `src/Services/NotificationManager.swift`

Enhanced with:
- `sendMessageNotification(from:preview:)` - Send local notification for new messages
- `registerDeviceToken()` - Register device with backend API
- Device token storage and management

### Backend Components

#### 1. Device Token Storage
**Location:** `api/server.py`

In-memory storage for device tokens:
```python
device_tokens: Dict[str, Dict] = {}
```

Format:
```python
{
    "device_id": {
        "token": "abc123...",
        "platform": "ios",
        "registered_at": "2025-10-30T..."
    }
}
```

#### 2. Notification Endpoints

**POST /api/notifications/register**
- Registers device token for push notifications
- Requires X-API-Key header authentication
- Stores device_id, token, and platform

Request:
```json
{
    "device_token": "abc123...",
    "platform": "ios",
    "device_id": "device-uuid"
}
```

Response:
```json
{
    "success": true,
    "message": "Device token registered successfully"
}
```

#### 3. Push Notification Helper
**Function:** `send_push_notification()`

Currently logs notifications (placeholder for APNs integration).

In production, would use:
- PyAPNs2 library
- Apple Push Notification service (APNs)
- Proper certificates and authentication keys

## Message Flow

### When App is in Foreground
1. WebSocket connection active
2. Messages received in real-time
3. UI updates immediately
4. No push notifications needed

### When App is Backgrounded
1. WebSocket may disconnect (iOS limitation)
2. Backend sends silent push notification
3. iOS wakes app briefly
4. App triggers local notification
5. User sees banner/alert
6. App reconnects WebSocket when foregrounded

### Push Notification Payload
```json
{
    "type": "new_message",
    "sender": "Claude",
    "preview": "Here's the response to your question...",
    "timestamp": 1234567890
}
```

## Testing

### Test Local Notifications
Use the test methods in NotificationManager:
```swift
await NotificationManager.shared.sendMessageNotification(
    from: "Claude",
    preview: "Test notification message"
)
```

### Test Background Fetch
Use Xcode debugger:
1. Run app in simulator
2. Debug → Simulate Background Fetch
3. Check console logs for "🔄 BACKGROUND: Performing background fetch"

### Test Push Notifications
1. Run on physical device (push notifications don't work in simulator)
2. Background the app
3. Send message through WebSocket
4. Should receive notification banner

## Production Setup Required

### Apple Push Notification Service (APNs)

To enable actual push notifications in production:

1. **Create APNs Certificate**
   - Log in to Apple Developer Portal
   - Go to Certificates, Identifiers & Profiles
   - Create new APNs certificate for `com.builderos.ios`
   - Download certificate and convert to .pem format

2. **Install PyAPNs2**
   ```bash
   pip install apns2
   ```

3. **Update Backend Code**

   Replace the placeholder in `send_push_notification()` with:
   ```python
   from apns2.client import APNsClient
   from apns2.payload import Payload

   client = APNsClient('/path/to/cert.pem', use_sandbox=True)
   payload = Payload(
       alert={"title": title, "body": body},
       custom=data,
       badge=1,
       sound="default"
   )
   client.send_notification(device_info['token'], payload, 'com.builderos.ios')
   ```

4. **Update for Production**
   - Set `use_sandbox=False` for production APNs
   - Use production certificate
   - Update bundle identifier if changed

## Current Limitations

1. **No Actual APNs Integration**
   - Backend logs notifications instead of sending them
   - Requires APNs certificate setup for production

2. **In-Memory Token Storage**
   - Device tokens stored in memory only
   - Lost on server restart
   - Should use database (SQLite/PostgreSQL) in production

3. **No Notification History**
   - No tracking of sent notifications
   - No delivery confirmation
   - No retry logic for failed sends

4. **Simple Device Mapping**
   - No user-to-device mapping
   - No multi-device support per user
   - No device preferences/settings

## Future Enhancements

### Near-term
- [ ] Implement actual APNs integration
- [ ] Persistent device token storage (database)
- [ ] User-to-device mapping
- [ ] Notification preferences (enable/disable per chat)

### Long-term
- [ ] Rich notifications (with images/attachments)
- [ ] Notification actions (quick reply)
- [ ] Notification grouping/threading
- [ ] Notification history and analytics
- [ ] Multi-device sync
- [ ] Smart notification timing (don't disturb hours)

## Environment Variables

Required for production:
```bash
# Apple Push Notification Service
APNS_CERT_PATH=/path/to/cert.pem
APNS_USE_SANDBOX=true  # false for production

# Optional
APNS_TEAM_ID=your_team_id
APNS_KEY_ID=your_key_id
APNS_KEY_PATH=/path/to/key.p8  # Alternative to certificate
```

## Files Modified

### iOS App
- ✅ `src/Info.plist` - Added background modes and task identifiers
- ✅ `src/BuilderOSApp.swift` - Added AppDelegate with background handlers
- ✅ `src/Services/NotificationManager.swift` - Added message notifications and device registration

### Backend
- ✅ `api/server.py` - Added notification endpoints and helpers

### Documentation
- ✅ `docs/BACKGROUND_NOTIFICATIONS_IMPLEMENTATION.md` - This file

## References

- [Apple: Pushing Background Updates to Your App](https://developer.apple.com/documentation/usernotifications/pushing_background_updates_to_your_app)
- [Apple: BGTaskScheduler](https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler)
- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)
- [PyAPNs2 Documentation](https://github.com/Pr0Ger/PyAPNs2)

## Support

For issues or questions:
1. Check console logs for error messages
2. Verify Info.plist configuration
3. Ensure device token is registered
4. Check backend server logs
5. Verify Tailscale VPN connectivity

---

*Implementation completed: 2025-10-30*
*Last updated: 2025-10-30*
