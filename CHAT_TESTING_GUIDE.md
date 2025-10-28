# BuilderOS Mobile - Chat Connection Testing Guide

## Overview

This guide covers testing the new Chat tab functionality with Claude and Codex WebSocket agents.

## Root Cause Summary

**Problem:** Chat services showed as disconnected despite claiming connection.

**Root Cause:** No backend WebSocket server implemented - iOS services were configured correctly but trying to connect to non-existent endpoints.

**Solution:** Created Python WebSocket server (`api/server.py`) with Claude and Codex endpoints.

## Quick Start (10 minutes)

### 1. Setup API Server (First Time)

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/api
./setup.sh
```

This creates virtual environment and installs dependencies.

### 2. Set Anthropic API Key

```bash
# Add to ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-api03-..."

# Or set for current session
export ANTHROPIC_API_KEY="sk-ant-api03-..."

# Verify it's set
echo $ANTHROPIC_API_KEY
```

### 3. Start API Server

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/api
./start.sh
```

You should see:
```
🚀 Starting BuilderOS Mobile API Server
✅ Starting server on http://localhost:8080
🔌 WebSocket endpoints:
   - ws://localhost:8080/api/claude/ws
   - ws://localhost:8080/api/codex/ws
```

**Keep this terminal open!** Server logs will appear here.

### 4. Configure iOS App for Testing

**For Simulator Testing:**

Edit `src/Services/APIConfig.swift`, line 12:

```swift
// Change from production:
static var tunnelURL = "https://api.builderos.app"

// To localhost:
static var tunnelURL = "http://localhost:8080"
```

**For Device Testing:**

1. Find Mac's local IP:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
   # Example: 192.168.1.123
   ```

2. Edit `APIConfig.swift`:
   ```swift
   static var tunnelURL = "http://192.168.1.123:8080"  // Use your IP
   ```

3. Ensure iPhone and Mac on same WiFi network

### 5. Build and Run iOS App

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
open src/BuilderOS.xcodeproj
```

In Xcode:
1. Select iPhone 16 Pro simulator (or your device)
2. Press Cmd+R to build and run
3. Wait for app to launch

## Testing Checklist

### ✅ Test 1: Connection Status (2 min)

**Expected:** Lightning bolt icon turns green when connected

**Steps:**
1. Launch app
2. Tap Chat tab (second tab)
3. Observe top-right corner lightning bolt

**Success Criteria:**
- Lightning bolt is **green** within 2-3 seconds
- No red error indicator
- Connection happens automatically on app launch

**If Failed:**
- Check server terminal for connection logs
- Check Xcode console for iOS connection errors
- Verify API endpoint: `curl http://localhost:8080/api/health`

**Server Logs (Expected):**
```
🔵 Claude WebSocket connection established
✅ WebSocket authenticated
```

**iOS Logs (Expected):**
```
🔵 Starting connection for Claude...
✅ Claude connection successful!
```

### ✅ Test 2: Send Basic Message (2 min)

**Expected:** Message sends and receives Claude response

**Steps:**
1. Ensure lightning bolt is green
2. Type in input field: "Hello Claude!"
3. Press send button (up arrow) or Return

**Success Criteria:**
- User message appears in chat history (right-aligned, cyan/pink gradient)
- Loading indicator shows (3 animated dots)
- Claude response appears (left-aligned, gray background)
- Response streams in chunks
- Loading indicator disappears when complete

**If Failed:**
- Check send button is enabled (not grayed out)
- Verify connection is still active (green lightning bolt)
- Check server terminal for message receipt
- Check Xcode console for send errors

**Server Logs (Expected):**
```
📬 Claude received: Hello Claude!...
```

**iOS Logs (Expected):**
```
📤 Sending message: Hello Claude!
📬 Starscream: Received text: {"type":"message"...
```

### ✅ Test 3: Multiple Messages (3 min)

**Expected:** Can send multiple messages in sequence

**Steps:**
1. Send: "What is BuilderOS?"
2. Wait for complete response
3. Send: "List all capsules"
4. Wait for complete response
5. Send: "Show system metrics"
6. Wait for complete response

**Success Criteria:**
- All 3 messages send successfully
- All 3 responses received completely
- Chat history shows all messages in order
- No connection drops
- No frozen UI

**If Failed:**
- Check if isLoading state is properly reset
- Verify WebSocket connection stays open
- Check for memory issues (Xcode Debug Navigator)

### ✅ Test 4: Quick Actions (2 min)

**Expected:** Quick action chips send pre-defined messages

**Steps:**
1. Scroll horizontally in quick actions row
2. Tap "Status" chip
3. Wait for response
4. Tap "Tools" chip
5. Wait for response
6. Tap "Capsules" chip
7. Wait for response

**Success Criteria:**
- Each chip sends its associated message
- Responses received for all quick actions
- Quick actions work same as manual typing

**Quick Action Messages:**
- Status: "What's the status of BuilderOS?"
- Tools: "Show me available tools"
- Capsules: "List all capsules"
- Metrics: "Show system metrics"
- Agents: "List available agents"

### ✅ Test 5: Tab Switching (2 min)

**Expected:** Connection persists when switching tabs

**Steps:**
1. Send message to Claude
2. While response is streaming, switch to Dashboard tab
3. Wait 2 seconds
4. Switch back to Chat tab

**Success Criteria:**
- Connection stays active (green lightning bolt)
- Chat history preserved
- Can continue sending messages immediately

**If Failed:**
- Check if services are being destroyed on tab change
- Verify service instances are stored correctly
- Check onChange handlers

### ✅ Test 6: Clear Chat (2 min)

**Expected:** Can clear chat history

**Steps:**
1. Send 2-3 messages to build history
2. Tap trash icon (top-right, next to lightning bolt)
3. Tap "Clear All" in confirmation dialog

**Success Criteria:**
- Confirmation dialog appears
- After confirming, all messages cleared
- Can send new message successfully
- New conversation starts fresh

**If Failed:**
- Check if clearMessages() is called
- Verify persistence is also cleared
- Check if UI updates after clear

### ✅ Test 7: Connection Recovery (3 min)

**Expected:** Connection recovers after server restart

**Steps:**
1. Send successful message
2. Stop API server (Ctrl+C in terminal)
3. Try to send another message
4. Observe lightning bolt turns red
5. Restart API server (`./start.sh`)
6. Tap lightning bolt to reconnect
7. Send another message

**Success Criteria:**
- Error shown when server stops
- Lightning bolt turns red
- Manual reconnect works
- Messages work after reconnect

**If Failed:**
- Check reconnection logic
- Verify error handling
- Check if WebSocket cleanup is proper

### ✅ Test 8: Codex Tab (1 min)

**Expected:** Can create Codex tab and connect

**Steps:**
1. Tap "+" button in tab bar
2. Select "Codex" provider
3. New tab created with Codex label
4. Observe connection status

**Success Criteria:**
- Codex tab created
- Connection attempts (may fail - placeholder implementation)
- Can switch between Claude and Codex tabs

**Note:** Codex currently returns placeholder responses. Full BridgeHub integration needed.

## Performance Tests

### Memory Usage

**Expected:** < 100MB app memory

**Steps:**
1. Open Xcode → Debug Navigator → Memory
2. Send 20+ messages
3. Monitor memory usage
4. Clear chat
5. Verify memory is freed

**Success Criteria:**
- Memory stays under 100MB
- Memory freed after clearing chat
- No leaks detected

### Response Latency

**Expected:**
- First response chunk: < 2 seconds
- Complete response: < 10 seconds (for typical message)

**Steps:**
1. Note timestamp before sending
2. Send message
3. Note timestamp of first response chunk
4. Note timestamp when complete

**Success Criteria:**
- First chunk arrives quickly (< 2s)
- Streaming feels real-time
- No long pauses between chunks

### UI Responsiveness

**Expected:** 60fps, no lag

**Steps:**
1. Send message with long response
2. While streaming, scroll chat history
3. Try to send another message while loading
4. Switch tabs during streaming

**Success Criteria:**
- Scrolling smooth at 60fps
- UI never freezes
- Can interact during streaming
- Tab switching instant

## Debug Logging

### Server Side

Watch terminal where `./start.sh` is running:

```
✅ Starting server on http://localhost:8080
🔵 Claude WebSocket connection established
✅ WebSocket authenticated
📬 Claude received: Hello Claude!...
```

### iOS Side

Watch Xcode console (Cmd+Shift+Y):

```
🔵 Starting connection for Claude...
📋 WebSocket created with Starscream
▶️ WebSocket connecting...
✅ WebSocket connected!
🔑 Retrieved API key from Keychain (length: 64)
📤 Sending API key (first 8 chars: 1da15f45)...
✅ API key sent to WebSocket
✅ Authentication successful!
✅ Successfully connected and authenticated!
📤 Sending message: Hello Claude!
📬 Starscream: Received text: {"type":"message","content":"Hello...
```

## Common Issues & Solutions

### Issue 1: Lightning Bolt Stays Red

**Symptoms:**
- Connection indicator red
- Status shows "Disconnected" or "Error"
- Can't send messages

**Diagnosis:**
```bash
# Check if server is running
curl http://localhost:8080/api/health

# Should return:
# {"status":"ok","version":"1.0.0",...}

# Test WebSocket endpoint
wscat -c ws://localhost:8080/api/claude/ws
# (Install: npm install -g wscat)
```

**Solutions:**
1. Ensure API server is running (`./start.sh`)
2. Check ANTHROPIC_API_KEY is set
3. Verify APIConfig.swift has correct URL
4. Check firewall settings
5. Try restarting both server and app

### Issue 2: Send Button Disabled

**Symptoms:**
- Send button (up arrow) is grayed out
- Can't send messages
- Input field works but button won't enable

**Diagnosis:**
- Check `canSend` computed property
- Verify `isConnected` is true
- Ensure text field is not empty
- Check `isLoading` is false

**Solutions:**
1. Ensure connection (green lightning bolt)
2. Type at least one character
3. Wait for any pending responses to complete
4. Check Xcode console for state issues

### Issue 3: Messages Send But No Response

**Symptoms:**
- Message appears in chat
- Loading indicator shows
- No response ever comes
- Loading indicator never stops

**Diagnosis:**
- Check server terminal for errors
- Verify ANTHROPIC_API_KEY is valid
- Check iOS console for WebSocket errors
- Test API key directly:

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model":"claude-sonnet-4-5-20250929",
    "max_tokens":100,
    "messages":[{"role":"user","content":"Hello"}]
  }'
```

**Solutions:**
1. Verify API key: `echo $ANTHROPIC_API_KEY | cut -c1-10`
2. Check Anthropic account status/billing
3. Check server logs for Anthropic API errors
4. Restart server with fresh API key

### Issue 4: UI Doesn't Update

**Symptoms:**
- Messages sent but don't appear
- Response received but doesn't show
- Lightning bolt doesn't change color
- UI frozen or unresponsive

**Diagnosis:**
- Check if `@Published` properties updating
- Verify view is observing service
- Ensure updates on Main thread

**Solutions:**
1. Verify `ChatAgentServiceBase` is `ObservableObject`
2. Ensure updates wrapped in `@MainActor`
3. Check service instance not being recreated
4. Look for force-unwrap crashes in console

### Issue 5: WebSocket Disconnects Immediately

**Symptoms:**
- Connects briefly then disconnects
- "Disconnected" status right after "Connecting"
- No response to messages

**Diagnosis:**
- Check authentication flow
- Verify API key sent as first message
- Check server authentication timeout (10s)

**Solutions:**
1. Verify mobile API key matches server's `VALID_API_KEY`
2. Check authentication happens before first message
3. Look for "error:invalid_api_key" in logs
4. Increase authentication timeout if network slow

### Issue 6: ANTHROPIC_API_KEY Not Found

**Symptoms:**
- Server won't start
- Error: "ANTHROPIC_API_KEY not set"

**Solutions:**

**Option 1: Add to shell config (permanent)**
```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-..."' >> ~/.zshrc
source ~/.zshrc
```

**Option 2: Set for current session (temporary)**
```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
./start.sh
```

**Option 3: Inline with command (one-time)**
```bash
ANTHROPIC_API_KEY="sk-ant-api03-..." ./start.sh
```

## Production Testing (Later)

### With Cloudflare Tunnel

1. **Start tunnel:**
   ```bash
   cloudflared tunnel --url http://localhost:8080
   ```

2. **Update APIConfig.swift:**
   ```swift
   static var tunnelURL = "https://api.builderos.app"
   ```

3. **Test on real device:**
   - Build on iPhone
   - Test with cellular data
   - Verify works with Proton VPN on both devices

## Success Criteria

- ✅ Connection status indicator works correctly
- ✅ Messages send and receive successfully
- ✅ UI updates in real-time during streaming
- ✅ Tab switching preserves connection
- ✅ Connection recovers after server restart
- ✅ Quick actions work
- ✅ Clear chat functionality works
- ✅ No memory leaks
- ✅ Works on simulator and device
- ✅ Performance is smooth (60fps)

## Next Steps After Testing

1. ✅ Fix any issues found
2. 🔄 Add Codex integration via BridgeHub
3. 🔄 Add message persistence across app launches
4. 🔄 Add unit tests for services
5. 🔄 Add UI tests for chat flow
6. 🔄 Deploy to TestFlight
7. 🔄 Submit to App Store

## Documentation

- **API Documentation:** `api/README.md`
- **API Setup:** `api/setup.sh`
- **API Startup:** `api/start.sh`
- **WebSocket Protocol:** `api/README.md` (Protocol section)
- **Server Implementation:** `api/server.py`

---

**Happy Testing! 💬**

If you encounter issues not covered here, check server logs + iOS console logs for detailed error messages.
