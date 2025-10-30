# Background Notifications - Quick Start Guide

**Ready to test background notifications!**

## What Was Added

✅ **Background Capabilities**
- Remote notifications for push alerts
- Background fetch for periodic updates
- Background task scheduling
- Automatic reconnection when returning to foreground

✅ **Push Notifications**
- iPhone notifications when new messages arrive
- Works when app is backgrounded or locked
- Badge updates and sound alerts
- Tap notification to open app

✅ **Backend Support**
- Device token registration endpoint
- Notification sending on message completion
- Support for both Claude and Codex agents

## Quick Test (Local Notifications)

### Test 1: Local Notification
Run this in the app (in SettingsView or add a test button):

```swift
Task {
    await NotificationManager.shared.sendMessageNotification(
        from: "Claude",
        preview: "This is a test notification message!"
    )
}
```

You should see a banner notification immediately.

### Test 2: Background Fetch
1. Run app in Xcode
2. Go to Debug menu → Simulate Background Fetch
3. Check Xcode console for: `🔄 BACKGROUND: Performing background fetch`

### Test 3: Background/Foreground Transitions
1. Send a chat message
2. Background the app (home button/swipe up)
3. Wait a few seconds
4. Return to app
5. Check logs for auto-reconnection

## Testing on Physical Device

### Prerequisites
1. **Physical iPhone** (notifications don't work in simulator)
2. **Tailscale VPN** running on both Mac and iPhone
3. **Backend server** running (`api/start.sh`)

### Steps
1. Deploy app to iPhone:
   ```bash
   ./deploy_to_iphone.sh
   ```

2. Launch app on iPhone and complete onboarding

3. App will automatically:
   - Request notification permissions
   - Register device token with backend
   - Schedule background refresh

4. Test notification:
   - Start a chat with Claude
   - Background the app
   - Send a message
   - Should receive notification banner

## Backend Notification Flow

When a message is sent through Claude or Codex:

1. **Message Processing**
   - User sends message via WebSocket
   - Backend processes with Claude/Codex API
   - Response is streamed back

2. **Notification Trigger**
   - On completion, backend sends push notification
   - All registered devices receive notification
   - App shows banner if backgrounded

3. **App Response**
   - If foregrounded: message appears in UI
   - If backgrounded: notification banner appears
   - Tap banner: app opens to chat

## Logs to Watch

### iOS App Logs
```
📱 NOTIFICATION: Permission granted
📱 NOTIFICATION: Device token received: abc123...
✅ NOTIFICATION: Device token registered with backend
🔄 BACKGROUND: Performing background fetch
```

### Backend Logs
```
✅ Registered device token for device-uuid (ios)
   Total registered devices: 1
📱 PUSH NOTIFICATION to device-uuid:
   Title: New message from Claude
   Body: Here's the response...
   Token: abc123...
```

## Troubleshooting

### No Notification Permission
- Go to iPhone Settings → BuilderOS → Notifications
- Enable "Allow Notifications"

### Device Token Not Registering
- Check backend is running and accessible
- Verify Tailscale VPN is connected
- Check API key matches in Settings

### No Notifications When Backgrounded
1. Verify app has notification permission
2. Check device token is registered (backend logs)
3. Ensure backend is sending notifications (check logs)
4. Test with local notification first

### Background Fetch Not Working
- Only works on physical device
- iOS controls timing (not immediate)
- Use Xcode simulator for testing

## Production Setup (Optional)

For actual APNs push notifications (not just local notifications):

### 1. Get APNs Certificate
```bash
# From Apple Developer Portal
# Download certificate for com.builderos.ios
# Convert to .pem format
```

### 2. Install PyAPNs2
```bash
cd api
pip install apns2
```

### 3. Update Backend
Replace placeholder in `api/server.py`:
```python
# Uncomment and configure APNs client
from apns2.client import APNsClient
from apns2.payload import Payload

client = APNsClient('/path/to/cert.pem', use_sandbox=True)
# ... see code comments for full implementation
```

### 4. Set Environment Variables
```bash
export APNS_CERT_PATH=/path/to/cert.pem
export APNS_USE_SANDBOX=true
```

## What Notifications Look Like

### Banner (when backgrounded)
```
┌────────────────────────────────┐
│ BuilderOS              now  ✕  │
├────────────────────────────────┤
│ New message from Claude        │
│ Here's the response to your... │
└────────────────────────────────┘
```

### Lock Screen
```
┌────────────────────────────────┐
│ 📱 BuilderOS                   │
│ New message from Claude        │
│ Here's the response to your... │
│                            now │
└────────────────────────────────┘
```

## Files Modified

### iOS App
- `src/Info.plist` - Background modes
- `src/BuilderOSApp.swift` - AppDelegate with background handlers
- `src/Services/NotificationManager.swift` - Message notifications

### Backend
- `api/server.py` - Notification endpoints and sending

### Documentation
- `docs/BACKGROUND_NOTIFICATIONS_IMPLEMENTATION.md` - Full details
- `docs/BACKGROUND_NOTIFICATIONS_QUICKSTART.md` - This guide

## Next Steps

1. ✅ Test local notifications
2. ✅ Verify device registration
3. ✅ Test background/foreground transitions
4. 🔄 Deploy to physical device
5. 🔄 Test end-to-end notifications
6. 🔄 (Optional) Set up APNs for production

## Support

Issues? Check:
1. Console logs (iOS and backend)
2. Notification permissions in iPhone Settings
3. Tailscale VPN connectivity
4. Backend server is running
5. Device token is registered

---

*Quick Start Guide - 2025-10-30*
