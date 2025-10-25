# Deploy PTY Terminal to iPhone - Quick Guide

## Prerequisites (30 seconds)

1. **Mac API Server Running:**
   ```bash
   cd /Users/Ty/BuilderOS/api && ./server_mode.sh
   ```
   ✅ Should see: "Server running on http://0.0.0.0:8080"

2. **Tailscale Connected (Both Devices):**
   - Mac: `tailscale status | grep 100.66.202.6`
   - iPhone: Tailscale app shows connected

3. **iPhone Connected to Mac:**
   - USB cable plugged in
   - OR both on same WiFi network

## Deploy (3 options)

### Option 1: Xcode GUI (Easiest) ⭐

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src
open BuilderOS.xcodeproj
```

In Xcode:
1. Select your iPhone from device dropdown (top toolbar)
2. Press **Cmd+R** (or click Play button)
3. Wait for build and install (~30 seconds)
4. App launches automatically

### Option 2: Command Line (Faster)

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src

# Build and install
xcodebuild -project BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -destination 'platform=iOS,name=Ty's iPhone' \
  -allowProvisioningUpdates \
  install
```

### Option 3: Install Without Running

```bash
# Just install the app (doesn't launch it)
xcodebuild -project BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -destination 'platform=iOS,name=Ty's iPhone' \
  -allowProvisioningUpdates \
  archive -archivePath build/BuilderOS.xcarchive

xcodebuild -exportArchive \
  -archivePath build/BuilderOS.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist
```

## First Launch Setup

1. **Open BuilderOS app** on iPhone

2. **Onboarding (if first time):**
   - Tap "Get Started"
   - **Tunnel URL:** `http://100.66.202.6:8080`
   - **API Key:** `1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3`
   - Tap "Connect"

3. **Navigate to Terminal Tab:**
   - Tap "Terminal" icon (bottom tab bar)

## Testing (2 minutes)

### Test 1: Connection Status
✅ **Expected:** Green "CONNECTED" indicator (top of screen)
❌ **If red:** See troubleshooting below

### Test 2: Live Output
1. On Mac terminal:
   ```bash
   echo "Hello from Claude Code!"
   ```

2. On iPhone: Check terminal displays:
   ```
   Hello from Claude Code!
   ```

### Test 3: Colors & Formatting
1. On Mac:
   ```bash
   ls --color=always
   ```

2. On iPhone: Verify colored output appears

### Test 4: Multi-Line Output
1. On Mac:
   ```bash
   for i in {1..10}; do
     echo "Line $i"
     sleep 0.5
   done
   ```

2. On iPhone: Watch lines appear in real-time

### Test 5: ANSI Codes
1. On Mac:
   ```bash
   echo -e "\033[1;32mGreen Bold\033[0m"
   echo -e "\033[1;31mRed Bold\033[0m"
   echo -e "\033[1;34mBlue Bold\033[0m"
   ```

2. On iPhone: Verify colors display correctly

### Test 6: Reconnection
1. Turn on Airplane Mode on iPhone
2. Wait 5 seconds (status should turn red)
3. Turn off Airplane Mode
4. Wait 10 seconds (should auto-reconnect to green)

## Troubleshooting

### "DISCONNECTED" Red Indicator

**Quick Fix:**
```bash
# On Mac - verify API server
curl http://localhost:8080/api/health

# Should return: {"status": "healthy", ...}

# If not running:
cd /Users/Ty/BuilderOS/api && ./server_mode.sh
```

**Check Tailscale:**
```bash
# Mac
tailscale status | grep 100.66.202.6

# Should show: 100.66.202.6 (active)
```

**Manual Reconnect:**
- Tap circular arrow button (top right)

### No Output Appearing

**Verify WebSocket:**
```bash
# On Mac terminal
wscat -c ws://100.66.202.6:8080/api/terminal/ws

# Type API key when prompted:
1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3

# Should see: "authenticated"
```

**Test PTY Output:**
```bash
# In wscat session, type:
echo "test output"

# Should see output immediately
```

### Build Failed

**Common Causes:**

1. **Code Signing:**
   - Xcode → BuilderOS target → Signing & Capabilities
   - Select your Apple ID team
   - Check "Automatically manage signing"

2. **Device Trust:**
   - iPhone → Settings → General → Device Management
   - Trust your developer certificate

3. **Swift Package Dependencies:**
   ```bash
   # Clean and rebuild
   cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src
   xcodebuild clean -project BuilderOS.xcodeproj -scheme BuilderOS
   xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS \
     -destination 'platform=iOS,name=Ty's iPhone' build
   ```

### "Invalid API Key" Error

**Fix:**
1. Open Settings tab in app
2. Tap "API Key"
3. Enter: `1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3`
4. Tap "Save"
5. Go back to Terminal tab

### Terminal Shows Garbage Characters

**This should NOT happen with SwiftTerm.**

If it does:
1. Force quit app (swipe up)
2. Relaunch
3. If persists, check Mac API server logs:
   ```bash
   tail -f /Users/Ty/BuilderOS/api/logs/server.log
   ```

## Performance Tips

### Battery Optimization

The terminal auto-disconnects when:
- App goes to background
- Screen locks
- iPhone sleeps

Auto-reconnects when:
- App returns to foreground
- Screen unlocks

### Network Usage

**Minimal bandwidth:**
- Only text data transmitted
- ~1-5 KB/sec during active output
- ~0.1 KB/sec when idle (heartbeat)

**Works on:**
- ✅ WiFi (best performance)
- ✅ 5G/LTE (good performance)
- ✅ 4G (acceptable performance)
- ⚠️ 3G (slow, may lag)

## Usage Tips

### Monitoring Long Tasks

1. **Start task on Mac:**
   ```bash
   claude build-capsule my-project
   ```

2. **Monitor from iPhone:**
   - Open BuilderOS app
   - Terminal tab shows live progress
   - Can leave and return - keeps streaming

### Multiple Sessions

Currently single session only. To switch contexts:

1. **On Mac:** Exit current shell (Ctrl+D)
2. **On iPhone:** Watch session end
3. **On Mac:** Start new shell
4. **On iPhone:** New session begins

### Saving Output

**Take Screenshot:**
- iPhone: Volume Up + Power button
- Saves terminal output for reference

**Future:** Copy/paste support coming

## Advanced: Custom Commands

Want to run specific commands remotely?

### Method 1: Server-Side Script

Create shortcut on Mac:

```bash
# /Users/Ty/bin/status.sh
#!/bin/bash
echo "=== BuilderOS Status ==="
cd /Users/Ty/BuilderOS
git status
echo ""
echo "=== Capsules ==="
ls -1 capsules/
echo ""
echo "=== System ==="
uptime
```

Run from Mac, view on iPhone:
```bash
~/bin/status.sh
```

### Method 2: Future: Send Commands

Coming soon:
- Text input field in terminal view
- Send commands directly from iPhone
- Interactive shell session

## Next Steps

### Phase 2 Features (Optional)

1. **Command Input:**
   - On-screen keyboard
   - Send commands from iPhone

2. **Multiple Sessions:**
   - Tab support
   - Named sessions

3. **Enhanced UX:**
   - Font size adjustment
   - Color scheme selection
   - Screenshot/recording

4. **Notifications:**
   - Push when command completes
   - Alert on errors

## Quick Commands

```bash
# Restart API server
cd /Users/Ty/BuilderOS/api && ./server_mode.sh

# Check Tailscale
tailscale status

# Test WebSocket
wscat -c ws://100.66.202.6:8080/api/terminal/ws

# View API logs
tail -f /Users/Ty/BuilderOS/api/logs/server.log

# Rebuild iOS app
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src
xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS \
  -destination 'platform=iOS,name=Ty's iPhone' install
```

## Status

✅ **Implementation Complete**
✅ **Build Verified**
🚀 **Ready to Deploy**

---

**Time to Deploy:** ~3 minutes
**Time to Test:** ~2 minutes
**Total Time:** ~5 minutes

Open Xcode, press Cmd+R, and start monitoring BuilderOS from your iPhone! 🎉
