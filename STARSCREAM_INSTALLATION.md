# Starscream WebSocket Implementation - Installation Guide

## Overview
Replacing broken URLSessionWebSocketTask with Starscream library to fix Claude Agent WebSocket connection.

## Prerequisites
- ✅ Root cause identified (URLSessionWebSocketTask doesn't transmit messages)
- ✅ Server verified working (Python test client successful)
- ✅ Starscream implementation ready (`ClaudeAgentService_Starscream.swift`)

## Installation Steps

### Step 1: Add Starscream Package (Xcode GUI)

1. Open Xcode project:
   ```bash
   cd /Users/Ty/BuilderOS/capsules/builderos-mobile
   open src/BuilderOS.xcodeproj
   ```

2. In Xcode:
   - Select **BuilderOS** project in navigator (left sidebar)
   - Select **BuilderOS** target
   - Click **Package Dependencies** tab
   - Click **+** button (bottom left)

3. Add Starscream:
   - **Search**: `https://github.com/daltoniam/Starscream`
   - **Dependency Rule**: Up to Next Major Version
   - **Version**: 4.0.8
   - Click **Add Package**

4. Select target:
   - ✅ Check **BuilderOS** target
   - Click **Add Package**

### Step 2: Replace ClaudeAgentService.swift

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src/Services

# Backup old version
cp ClaudeAgentService.swift ClaudeAgentService_URLSession_BACKUP.swift

# Replace with Starscream version
cp ClaudeAgentService_Starscream.swift ClaudeAgentService.swift
```

### Step 3: Build and Test

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile

# Build
xcodebuild -project src/BuilderOS.xcodeproj -scheme BuilderOS -destination 'generic/platform=iOS Simulator' build

# Install
xcrun simctl install booted "/Users/Ty/Library/Developer/Xcode/DerivedData/BuilderOS-cyfwtkynlidjqialncespvsfvptf/Build/Products/Debug-iphonesimulator/BuilderOS.app"

# Launch
xcrun simctl launch booted com.ty.builderos

# Monitor server logs for authentication
tail -f /Users/Ty/BuilderOS/api/server.log | grep -E "(WebSocket|handler|Waiting|Received|authenticated)"
```

### Step 4: Verify Success

**Expected iOS logs:**
```
✅ Starscream: WebSocket connected
📤 Sending API key (first 8 chars: 1da15f45...)...
✅ API key sent to WebSocket
📬 Starscream: Received text: authenticated
✅ Authentication successful!
```

**Expected server logs:**
```
INFO: WebSocket /api/claude/ws [accepted]
🎯 WebSocket handler invoked
✅ WebSocket accepted
⏳ Waiting for API key from client...
📬 Received first message from client
INFO: Received API key: 1da15f45...89061a3 (length: 64)
INFO: Client authenticated successfully
✅ Claude Agent ready: Claude Agent session initialized with full BuilderOS context
```

## Key Differences: URLSessionWebSocketTask vs Starscream

| Feature | URLSessionWebSocketTask | Starscream |
|---------|------------------------|------------|
| Message transmission | ❌ Broken (silently queues) | ✅ Reliable |
| Connection events | Limited callbacks | Full delegate pattern |
| Error handling | Minimal | Comprehensive |
| ping/pong | Manual | Built-in |
| Production use | Not recommended | Industry standard (7.6k+ stars) |

## Troubleshooting

### Build Error: "No such module 'Starscream'"
**Solution:** Package not added correctly. Repeat Step 1 in Xcode.

### Build Error: Module compiled with Swift X.X but Y.Y
**Solution:** Clean build folder:
```bash
xcodebuild clean -project src/BuilderOS.xcodeproj -scheme BuilderOS
```

### Connection still fails
**Solution:** Check server is running:
```bash
cd /Users/Ty/BuilderOS/api
./server_mode.sh status
```

### API key empty error
**Solution:** Re-initialize Keychain:
```swift
// In BuilderOSApp.init()
APIConfig.loadSavedConfiguration()  // Should already be there
```

## Rollback (If Needed)

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/src/Services

# Restore old version
cp ClaudeAgentService_URLSession_BACKUP.swift ClaudeAgentService.swift

# Remove Starscream package via Xcode:
# Project > Package Dependencies > Select Starscream > Click "-"
```

## Files Modified

- ✅ `src/Services/ClaudeAgentService.swift` - Replaced with Starscream implementation
- ✅ `src/BuilderOS.xcodeproj/project.pbxproj` - Added Starscream package reference (via Xcode)

## Next Steps After Installation

1. Test basic connection (Chat tab → connect)
2. Send test message ("Hello")
3. Verify Claude Agent responds
4. Test reconnection (disconnect → connect)
5. Test error handling (kill server → check UI)

## Success Criteria

- ✅ App connects successfully (green indicator)
- ✅ Server receives API key (logs show authentication)
- ✅ Ready message received (full BuilderOS context)
- ✅ Can send messages
- ✅ Claude Agent responds
- ✅ Connection persists (no auto-disconnect)
