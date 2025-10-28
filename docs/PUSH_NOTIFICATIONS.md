# Push Notifications Implementation

## Overview

BuilderOS Mobile now supports push notifications to alert users when agent jobs complete on the Mac. This implementation includes:

- ✅ User notification permission flow
- ✅ Local notification testing (MVP)
- ✅ Foundation for future APNs integration
- ✅ Settings UI for testing notifications

## Architecture

### Components

**1. NotificationManager.swift**
- Singleton service managing all notification operations
- Handles permission requests and device token registration
- Provides test notification methods for MVP
- Implements UNUserNotificationCenterDelegate for notification handling

**2. BuilderOSApp.swift**
- Configures notification delegate on app launch
- Requests notification permissions automatically
- Handles APNs device token callbacks (ready for future backend)

**3. BuilderOS.entitlements**
- Declares `aps-environment` for push notification capability
- Required for both local and remote notifications

**4. SettingsView.swift (DEBUG mode only)**
- Test UI for triggering local notifications
- Shows permission status and device token
- Quick test buttons for common notification types

## Current Implementation (MVP)

### Phase 1: Local Notifications ✅

**What works NOW:**
- Request notification permission on first launch
- Send local test notifications
- Handle notification taps (opens app)
- Display notifications in foreground and background
- Sound and badge support

**Testing:**
1. Launch app → permission dialog appears
2. Grant permission
3. Open Settings tab
4. Scroll to "NOTIFICATIONS (TESTING)" section (DEBUG builds only)
5. Tap test buttons:
   - "Build Complete ✅"
   - "Tests Passed ✅"
   - "Deployment Complete 🚀"
6. Notifications appear immediately

**Test Commands:**
```swift
// From anywhere with NotificationManager access:
await notificationManager.sendBuildCompleteNotification()
await notificationManager.sendTestsPassedNotification()
await notificationManager.sendDeploymentCompleteNotification()

// Custom notification:
await notificationManager.sendTestNotification(
    title: "Agent Job Complete",
    body: "Your task has finished successfully"
)
```

## Future Implementation (APNs Backend)

### Phase 2: Backend Integration (Not Yet Implemented)

**Required Backend Work:**

**1. Device Token Registration API**
```
POST /api/notifications/register
Authorization: Bearer {api_key}

Body:
{
    "device_token": "abc123...",
    "platform": "ios"
}
```

**2. Job Completion Webhook**
When BuilderOS agent jobs complete, send push notification:
```
POST to APNs with payload:
{
    "aps": {
        "alert": {
            "title": "Build Complete ✅",
            "body": "iOS app built successfully in 45 seconds"
        },
        "sound": "default",
        "badge": 1
    },
    "job_id": "build-1234",
    "job_type": "build",
    "status": "success"
}
```

**3. iOS App Changes (Already Ready)**
The app already handles device token registration:
```swift
// In BuilderOSApp.swift - already implemented
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    // Device token is captured and logged
    // TODO: Send to backend API
}
```

### Phase 3: Production Setup Checklist

**When ready for APNs:**

**Apple Developer Portal:**
- [ ] Enable Push Notifications for App ID
- [ ] Create APNs certificate or key
- [ ] Update provisioning profile with push capability
- [ ] Change entitlements from `development` to `production`

**Backend Setup:**
- [ ] Store APNs credentials (key or certificate)
- [ ] Implement device token registration endpoint
- [ ] Implement push notification sending logic
- [ ] Add job completion hooks to trigger notifications

**iOS App:**
- [ ] Update NotificationManager to send device token to backend
- [ ] Add error handling for registration failures
- [ ] Implement deep linking for notification taps
- [ ] Add notification categories for actions

**Testing:**
- [ ] Test on real device (Simulator doesn't support APNs)
- [ ] Test with development APNs
- [ ] Verify notifications arrive on locked screen
- [ ] Test notification tap navigation
- [ ] Verify badge updates correctly

## Code Reference

### Request Permission
```swift
// Automatic on app launch
// Or manually:
await NotificationManager.shared.requestAuthorization()
```

### Send Test Notification (Local)
```swift
await NotificationManager.shared.sendTestNotification(
    title: "Job Complete",
    body: "Your task finished successfully"
)
```

### Check Permission Status
```swift
// Reactive property - updates UI automatically
@EnvironmentObject var notificationManager: NotificationManager

Text(notificationManager.isAuthorized ? "Authorized" : "Not Authorized")
```

### Handle Notification Tap
```swift
// Already implemented in NotificationManager
func handleNotificationTap(_ response: UNNotificationResponse) {
    let userInfo = response.notification.request.content.userInfo
    // TODO: Navigate to relevant screen based on userInfo
}
```

## Notification Types

### Planned Job Completion Notifications

**Build Jobs:**
- "Build Complete ✅" - Successful build
- "Build Failed ❌" - Build error with details
- "Build Cancelled ⚠️" - User cancelled build

**Test Jobs:**
- "Tests Passed ✅" - All tests successful
- "Tests Failed ❌" - Test failures with count
- "Coverage Updated 📊" - Code coverage report

**Deployment Jobs:**
- "Deployment Complete 🚀" - Successful deploy
- "Deployment Failed ❌" - Deploy error
- "App Live 🎉" - App successfully published

**Agent Jobs:**
- "Agent Complete" - Generic job completion
- "Research Complete 🔍" - Research results ready
- "Automation Complete 🤖" - Workflow finished

## Security Considerations

**Device Token Storage:**
- Device tokens stored in memory only (not persisted)
- Sent to backend API over HTTPS
- Associated with API key for authentication

**Notification Content:**
- Avoid sensitive data in notification body
- Use generic messages for lock screen
- Store details in app, navigate on tap

**Privacy:**
- User can deny permission (app still works)
- Notifications are opt-in
- Clear indication of what notifications do

## Troubleshooting

### "Permission Denied"
- Settings → BuilderOS → Notifications → Enable
- May need to reinstall app to trigger permission dialog again

### "Notifications Don't Appear"
- Check permission status in Settings tab
- Check Do Not Disturb is off
- Check notification preview settings (iOS Settings)

### "Badge Doesn't Update"
- Badge requires notification permission
- Badge updates via `setBadgeCount()` API (iOS 17+)

### "Device Token Not Generated"
- Device tokens only work on real devices (not Simulator)
- Requires valid provisioning profile with push capability
- Check console logs for registration errors

## Testing Checklist

**MVP Testing (Current):**
- [x] App requests permission on launch
- [x] Local notifications appear
- [x] Notifications show in foreground
- [x] Notifications show in background
- [x] Tapping notification opens app
- [x] Sound plays with notification
- [x] Badge updates (iOS 17+ API)

**APNs Testing (Future):**
- [ ] Device token registered with backend
- [ ] Remote push notifications received
- [ ] Notifications include job details
- [ ] Deep linking to relevant screen
- [ ] Notifications work with app terminated

## Resources

- [Apple Push Notifications Guide](https://developer.apple.com/documentation/usernotifications)
- [APNs Overview](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html)
- [Testing Local Notifications](https://developer.apple.com/documentation/usernotifications/testing-notifications)
- [Badge Count API (iOS 17+)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/4024916-setbadgecount)

## Next Steps

1. **Test Local Notifications** ✅ (MVP complete)
   - Request permission
   - Trigger test notifications
   - Verify UI and behavior

2. **Design Backend API** (Future)
   - Device token registration endpoint
   - Job completion webhook integration
   - APNs integration

3. **Implement Deep Linking** (Future)
   - Navigate to specific screens from notification tap
   - Handle notification payload data
   - Open to relevant job details

4. **Production Setup** (Future)
   - Create APNs key in Apple Developer Portal
   - Update entitlements to production
   - Deploy backend notification service
   - Test on real devices with TestFlight

---

**Implementation Status:** ✅ MVP Complete (Local Notifications)
**Next Phase:** Backend APNs Integration (Future Work)
**Last Updated:** October 26, 2025
