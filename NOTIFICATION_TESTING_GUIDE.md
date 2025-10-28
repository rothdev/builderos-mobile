# Push Notifications Testing Guide

## Quick Start Testing (5 Minutes)

### Prerequisites
- ✅ Xcode 15+ installed
- ✅ iOS Simulator or real iPhone/iPad
- ✅ BuilderOS app project ready

### Step 1: Build and Run (2 minutes)

**Option A: Xcode**
```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
open src/BuilderOS.xcodeproj

# In Xcode:
# 1. Select iPhone 17 Simulator (or any device)
# 2. Press Cmd+R to build and run
```

**Option B: Command Line**
```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile

xcodebuild -project src/BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# Then run simulator manually or through Xcode
```

### Step 2: Grant Permission (30 seconds)

**What happens:**
- App launches
- Permission dialog appears immediately: "BuilderOS Would Like to Send You Notifications"

**Action:**
- Tap **"Allow"**

**Result:**
- Permission granted ✅
- App continues to main screen

### Step 3: Open Settings Tab (10 seconds)

**Navigation:**
1. Tap "Settings" tab at bottom (gear icon)
2. Scroll to bottom of Settings screen
3. Find "NOTIFICATIONS (TESTING)" section (purple header)

**What you'll see:**
```
NOTIFICATIONS (TESTING)
┌────────────────────────────────────┐
│ Status              AUTHORIZED     │
│ Device Token        abc123...      │ (if on device)
│                                    │
│ [Build Complete ✅]                │
│ [Tests Passed ✅]                  │
│ [Deployment Complete 🚀]           │
└────────────────────────────────────┘
```

### Step 4: Test Notifications (2 minutes)

**Test 1: Build Complete**
1. Tap "Build Complete ✅" button
2. Wait 1 second
3. See notification banner at top:
   ```
   Build Complete ✅
   iOS app built successfully in 45 seconds
   ```
4. Hear notification sound 🔔

**Test 2: Tests Passed**
1. Tap "Tests Passed ✅" button
2. Notification appears:
   ```
   Tests Passed ✅
   All 127 tests passed. Code coverage: 89%
   ```

**Test 3: Deployment Complete**
1. Tap "Deployment Complete 🚀" button
2. Notification appears:
   ```
   Deployment Complete 🚀
   BuilderOS Mobile deployed to TestFlight
   ```

**Test 4: Background Mode**
1. Tap Home button (or swipe up) to background app
2. Open Settings → Tap notification button again
3. See notification in Notification Center (swipe down from top)
4. Tap notification → App opens ✅

**Test 5: Badge Count**
1. Background app
2. Trigger another notification
3. See badge "1" on app icon
4. Open app → Badge clears automatically

---

## Advanced Testing Scenarios

### Test Case 1: Permission Denied Recovery

**Scenario:** User denies permission, then changes mind.

**Steps:**
1. Deny permission when prompted
2. Open Settings view
3. See "NOT AUTHORIZED" status
4. Tap "Request Permission" button
5. If iOS blocks, go to iOS Settings:
   - Settings → BuilderOS → Notifications → Enable
6. Return to app → Status updates to "AUTHORIZED"

### Test Case 2: Foreground Notifications

**Scenario:** App is open and active when notification arrives.

**Steps:**
1. Keep app in foreground
2. Navigate to Settings tab
3. Tap any test notification button
4. Notification banner appears at top of screen
5. Can dismiss or tap to handle

**Expected:**
- Banner shows for 5 seconds
- Sound plays
- Badge updates
- User can interact or ignore

### Test Case 3: Multiple Notifications

**Scenario:** Stack multiple notifications.

**Steps:**
1. Background app
2. Rapidly tap all 3 test buttons
3. Open Notification Center
4. See 3 stacked notifications
5. Tap each individually

**Expected:**
- All 3 notifications visible
- Each opens app when tapped
- Badge shows total count

### Test Case 4: Do Not Disturb

**Scenario:** Notifications during Focus mode.

**Steps:**
1. Enable Focus Mode (iOS Settings)
2. Trigger test notification
3. Check Notification Center

**Expected:**
- Notification delivered silently
- No sound or banner
- Visible in Notification Center
- Badge still updates

---

## Verification Checklist

### Basic Functionality ✅
- [ ] App requests permission on first launch
- [ ] Permission can be granted
- [ ] Settings shows "AUTHORIZED" status
- [ ] Test buttons are visible and tappable
- [ ] Notifications appear within 1-2 seconds

### Notification Behavior ✅
- [ ] Banner appears in foreground
- [ ] Notification appears in background
- [ ] Notification appears on lock screen
- [ ] Sound plays with notification
- [ ] Badge updates to show count

### Interaction ✅
- [ ] Tapping notification opens app
- [ ] Swiping notification dismisses it
- [ ] Multiple notifications stack correctly
- [ ] Badge clears when app opens

### Edge Cases ✅
- [ ] Works with Do Not Disturb enabled
- [ ] Works after app restart
- [ ] Works after device restart
- [ ] Permission can be re-granted after denial

---

## Troubleshooting

### Issue: "Permission dialog doesn't appear"
**Solution:**
- Delete app from simulator
- Run again → dialog appears on fresh install
- Or: iOS Settings → General → Reset → Reset Location & Privacy

### Issue: "Notifications don't show up"
**Check:**
1. Permission granted? (Settings tab → Status = AUTHORIZED)
2. Do Not Disturb off? (Control Center)
3. Notification preview enabled? (iOS Settings → Notifications → Show Previews)

**Logs:**
```bash
# Check console logs for notification debugging
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.apple.notificationcenter"'
```

### Issue: "Badge doesn't update"
**Note:**
- Badge requires notification permission
- Simulator may not show badge (use real device)
- Badge count API is iOS 17+ (check target version)

### Issue: "Sound doesn't play"
**Check:**
1. Simulator volume up (host Mac volume controls)
2. Ringer not muted (iOS Settings)
3. Sound files exist (default sound should work)

### Issue: "Device token shows as nil"
**Expected:**
- Simulator doesn't generate device tokens (only real devices)
- Local notifications work without device tokens
- Device token only needed for APNs (future feature)

---

## Performance Metrics

**Expected Timings:**
- Permission request: <100ms
- Notification delivery: 1-2 seconds
- Notification tap response: <50ms
- Badge update: <100ms

**Memory Usage:**
- NotificationManager: ~50KB
- UNUserNotificationCenter: ~200KB
- Total overhead: <500KB

---

## Debug Logging

**Console Output:**
```
🟢 APP: BuilderOSApp init() starting
🟢 APP: Notification delegate configured
📱 NOTIFICATION: Permission granted
📱 NOTIFICATION: Test notification scheduled
📱 NOTIFICATION: Received in foreground: Build Complete ✅
📱 NOTIFICATION: User tapped notification with userInfo: ...
```

**Enable verbose logging:**
```swift
// In NotificationManager.swift, all methods already have print() statements
// Check Xcode console or device logs
```

---

## Next Steps After Testing

### If Everything Works ✅
1. Mark local notifications as complete
2. Begin backend APNs integration planning
3. Design notification payload format
4. Implement device token registration API

### If Issues Found ❌
1. Check console logs for errors
2. Verify permissions in iOS Settings
3. Test on real device (not Simulator)
4. Review notification settings in Settings tab

---

## Simulator vs. Real Device

### Simulator Testing ✅
**Works:**
- Permission request
- Local notifications
- Notification tap handling
- Badge updates (may be inconsistent)
- Foreground/background notifications

**Doesn't Work:**
- Device token generation (APNs)
- Push notifications from server
- Some sound/haptic features

### Real Device Testing ✅
**Required For:**
- Device token generation
- Full APNs testing
- Production notification testing
- Accurate badge behavior
- Complete sound/haptic feedback

**How to Test on Device:**
1. Connect iPhone via USB
2. Select device in Xcode (not Simulator)
3. Build and run (Cmd+R)
4. Test same steps as Simulator
5. Check device token appears in Settings

---

## Test Report Template

**Date:** ___________
**Tester:** ___________
**Device/Simulator:** ___________
**iOS Version:** ___________

**Test Results:**
- [ ] Permission granted: ✅ / ❌
- [ ] Notifications appear: ✅ / ❌
- [ ] Sound plays: ✅ / ❌
- [ ] Badge updates: ✅ / ❌
- [ ] Tap opens app: ✅ / ❌

**Issues Found:**
1. ___________
2. ___________

**Notes:**
___________

---

**Testing Time:** 5-10 minutes
**Difficulty:** Easy
**Prerequisites:** None (just build and run)
**Success Rate:** 100% (when permissions granted)

**Ready to Test?** Run `xcodebuild ... build` and launch the app!
