# BuilderOS Mobile - Quick Start Guide

## Your iPhone is Ready! 🎉

The BuilderOS Mobile app is installed on your iPhone and connected to your backend server.

---

## What's Working Right Now

✅ **App Installed:** BuilderOS app on your iPhone home screen
✅ **Backend Connected:** Server running at https://api.builderos.app
✅ **Claude Chat:** Ready to accept messages (1 connection active)
✅ **Session Persistence:** Your chats will be preserved per session

---

## How to Use the App

### 1. Open the App
Tap the **BuilderOS** icon on your iPhone home screen

### 2. Chat with Jarvis (Claude Agent)
- Navigate to the Claude tab
- Type a message: "Hello Jarvis, what can you help me with?"
- Watch the streaming response appear in real-time
- Your conversation is preserved for this session

### 3. Check Connection Status
- Look for the connection indicator in the UI
- Green = Connected to backend
- The app uses your Cloudflare Tunnel for secure communication

---

## Testing Checklist

Try these to verify everything works:

- [ ] **Basic Chat:** Send "Hello" to Claude and get a response
- [ ] **Streaming:** Watch responses appear character-by-character
- [ ] **Session Persistence:** Send messages, force quit app, reopen - chat history should be there
- [ ] **Network Switch:** Switch between WiFi and cellular, verify reconnection
- [ ] **Multiple Messages:** Send several messages in a row

---

## Troubleshooting

### App Won't Connect
1. Check your internet connection (WiFi or cellular)
2. Verify server is running: `curl https://api.builderos.app/api/health`
3. Restart the app

### Messages Not Sending
1. Check connection status indicator
2. Try force quitting and reopening the app
3. Check server logs: `curl http://localhost:8080/api/health | jq .`

### App Crashes
1. Rebuild and redeploy:
   ```bash
   cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src
   xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS -configuration Debug \
     -destination 'platform=iOS,name=Roth iPhone' clean build
   xcrun devicectl device install app --device 'Roth iPhone' \
     /Users/Ty/Library/Developer/Xcode/DerivedData/BuilderOS-cyfwtkynlidjqialncespvsfvptf/Build/Products/Debug-iphoneos/BuilderOS.app
   xcrun devicectl device process launch --device 'Roth iPhone' com.ty.builderos
   ```

---

## Quick Commands (for Development)

### Check Server Status
```bash
curl -s https://api.builderos.app/api/health | jq .
```

### View Active Connections
```bash
curl -s http://localhost:8080/api/health | jq '.connections'
```

### Restart Backend Server
```bash
# Stop current server (find PID)
lsof -i :8080 | grep LISTEN | awk '{print $2}' | xargs kill

# Start new server
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
python3 api/server_persistent.py
```

### Redeploy App to iPhone
```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src
xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS -configuration Debug \
  -destination 'platform=iOS,name=Roth iPhone' clean build
xcrun devicectl device install app --device 'Roth iPhone' \
  /Users/Ty/Library/Developer/Xcode/DerivedData/BuilderOS-cyfwtkynlidjqialncespvsfvptf/Build/Products/Debug-iphoneos/BuilderOS.app
xcrun devicectl device process launch --device 'Roth iPhone' com.ty.builderos
```

---

## What's Next?

### Near-Term Enhancements
1. **Codex Agent Chat:** Complete BridgeHub integration for Codex responses
2. **Session Storage:** Move from in-memory to SQLite/Redis for persistence across server restarts
3. **Multi-Tab Terminal:** Complete multi-tab UI for concurrent sessions
4. **Voice Input:** Add speech-to-text for hands-free messaging

### Future Features
- Push notifications for task completion
- Offline mode with local caching
- iOS Shortcuts integration
- Widget support for quick status checks
- Siri integration for voice commands

---

## Feedback & Issues

As you use the app, note any:
- **Bugs:** Crashes, connection issues, UI problems
- **UX Feedback:** Confusing flows, missing features, desired improvements
- **Performance:** Slow responses, laggy UI, memory issues

Share feedback by asking Jarvis to "log feedback for mobile app" with details.

---

## Support Resources

- **Deployment Report:** `/Users/Ty/BuilderOS/capsules/builderos-mobile/DEPLOYMENT_REPORT.md`
- **Backend Server:** `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server_persistent.py`
- **iOS Source:** `/Users/Ty/BuilderOS/capsules/builderos-mobile/src/`
- **Xcode Project:** `/Users/Ty/BuilderOS/capsules/builderos-mobile/src/BuilderOS.xcodeproj`

---

**🎉 Enjoy your BuilderOS Mobile experience!**

*Last updated: 2025-10-27*
