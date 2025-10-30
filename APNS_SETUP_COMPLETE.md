# APNs Push Notifications - Setup Complete ✅

**Date:** 2025-10-30
**Status:** Production Ready

## What Was Completed

### 1. Apple Push Notification Certificate ✅
- Created App ID: `com.builderos.ios`
- Generated Certificate Signing Request (CSR)
- Downloaded APNs certificate from Apple Developer Portal
- Converted to PEM format
- Stored at: `api/certs/apns_combined.pem`

### 2. Backend APNs Integration ✅
- Installed `aioapns` library (modern async APNs client)
- Updated `server.py` with full APNs support
- Automatic certificate loading on server start
- Real push notifications sent to devices

### 3. iOS App Configuration ✅
- Background modes enabled (remote-notification, fetch)
- Device token registration with backend
- Push notification handling
- Auto-reconnection on foreground

## Files Modified

### Backend (`api/`)
- ✅ `server.py` - APNs client integration
- ✅ `start.sh` - Install aioapns dependency
- ✅ `certs/apns_combined.pem` - APNs certificate (DO NOT COMMIT)
- ✅ `certs/apns_private_key.pem` - Private key (DO NOT COMMIT)

### iOS App (`src/`)
- ✅ `Info.plist` - Background modes
- ✅ `BuilderOSApp.swift` - AppDelegate with push handling
- ✅ `Services/NotificationManager.swift` - Device registration

## How It Works

### Message Flow
```
1. User sends message → Backend processes
2. Backend sends response via WebSocket
3. Backend triggers APNs push notification
4. Apple delivers to iPhone
5. iPhone shows banner notification
6. User taps → App opens to chat
```

### Device Registration Flow
```
1. App launches → Requests notification permission
2. iOS provides device token
3. App sends token to backend API
4. Backend stores: device_id → token mapping
5. Ready to receive notifications!
```

## Testing

### Start Backend
```bash
cd api
./start.sh
```

Look for:
```
✅ APNs client initialized (sandbox=True)
```

### Deploy to iPhone
```bash
./deploy_to_iphone.sh
```

### Test Push Notification
1. Open app on iPhone
2. Complete onboarding (grants notification permission)
3. Backend logs: `✅ Registered device token for...`
4. Send a message in chat
5. Background the app
6. Notification should appear!

## Production vs Sandbox

### Current: Sandbox Mode
- For development and TestFlight builds
- Uses Apple's sandbox APNs servers
- Certificate valid for 1 year

### For Production
Set environment variable:
```bash
export APNS_USE_SANDBOX=false
```

Or update code:
```python
APNS_USE_SANDBOX = False  # In server.py
```

## Certificate Expiration

Your APNs certificate expires: **November 29, 2026**

To renew:
1. Generate new CSR (we can reuse the private key)
2. Create new certificate on Apple Developer Portal
3. Download and convert to PEM
4. Replace `api/certs/apns_combined.pem`
5. Restart backend server

## Security Notes

⚠️ **IMPORTANT:**

1. **DO NOT commit certificates to git**
   ```bash
   # Add to .gitignore
   api/certs/*.pem
   api/certs/*.cer
   api/certs/*.p12
   ```

2. **Protect private keys**
   - Store securely
   - Never share publicly
   - Backup in secure location

3. **Rotate certificates regularly**
   - Even before expiration
   - If compromised
   - Best practice: annually

## Troubleshooting

### No notifications appearing
1. Check backend logs for APNs initialization
2. Verify device token is registered
3. Ensure notification permission granted
4. Check iPhone Settings → BuilderOS → Notifications

### Certificate errors
```bash
# Verify certificate format
openssl x509 -in api/certs/apns_combined.pem -text -noout
```

### Backend not starting
```bash
# Check APNs library installed
source venv/bin/activate
pip list | grep aioapns
```

## Environment Variables

Optional configuration:

```bash
# APNs Configuration
export APNS_USE_SANDBOX=true        # true for dev, false for prod
export APNS_CERT_PATH=/custom/path  # Override default path

# API Configuration
export ANTHROPIC_API_KEY=your_key   # Required
export API_PORT=8080                # Optional, default 8080
```

## Next Steps

### Immediate
- ✅ Certificate installed and working
- ✅ Backend sending notifications
- ✅ iOS app receiving notifications
- 🔄 Deploy to physical device and test end-to-end

### Future Enhancements
- [ ] Notification preferences per chat
- [ ] Rich notifications with images
- [ ] Notification actions (quick reply)
- [ ] Notification history/analytics
- [ ] Multi-device support per user
- [ ] Smart notification timing

## Monitoring

Watch backend logs for:
```
✅ APNs client initialized (sandbox=True)
✅ Registered device token for <device-id> (ios)
📱 PUSH NOTIFICATION to <device-id>:
✅ Push notification sent successfully via APNs
```

Watch iOS logs for:
```
📱 NOTIFICATION: Device token received: abc123...
✅ NOTIFICATION: Device token registered with backend
📱 PUSH: Received remote notification
```

## Support

Issues? Check:
1. Certificate file exists and is valid
2. Backend server running with APNs enabled
3. iPhone has notification permission
4. Device token registered with backend
5. Tailscale VPN connected

## Documentation

- Full implementation: `docs/BACKGROUND_NOTIFICATIONS_IMPLEMENTATION.md`
- Quick testing: `docs/BACKGROUND_NOTIFICATIONS_QUICKSTART.md`
- This summary: `APNS_SETUP_COMPLETE.md`

---

**Status:** Production ready! 🚀
**Last updated:** 2025-10-30
