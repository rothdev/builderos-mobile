# Device-Specific Error Investigation Instructions

## Status

**Build completed with enhanced diagnostic logging.**

The app now includes comprehensive device-specific logging that will help identify the root cause of the "Invalid message format" error that appears on physical device but NOT in simulator.

## What Was Added

### Enhanced Logging in `ClaudeAgentService.swift`

1. **Environment Detection**
   - Logs whether app is running on SIMULATOR or PHYSICAL DEVICE
   - Helps identify platform-specific differences

2. **Message Details**
   - Full message text and length
   - UTF-8 encoding verification
   - Hexadecimal byte dump of received data
   - JSON structure analysis (valid JSON vs. invalid JSON)

3. **Protocol Message Detection**
   - Identifies known protocol messages (ready, authenticated, error:*)
   - Detects config echoes (working_directory)
   - Reports which messages are being ignored vs. processed

## Testing Procedure

### Step 1: Prepare Log Capture

**Terminal 1: Capture Simulator Logs**
```bash
# Start simulator log capture
xcrun simctl spawn "iPhone 17" log stream \
  --predicate 'process == "BuilderOS"' \
  --style compact > /tmp/simulator_test.log 2>&1 &

echo "Simulator logging to /tmp/simulator_test.log"
```

**Terminal 2: Capture Device Logs**
```bash
# Start device log capture
/tmp/capture_device_logs.sh

# OR manually:
xcrun devicectl device info logs \
  --device 00008110-00111DCC0A31801E \
  stream \
  --predicate 'processImagePath CONTAINS "BuilderOS"' \
  > /tmp/device_test.log 2>&1 &

echo "Device logging to /tmp/device_test.log"
```

### Step 2: Test Simulator (Baseline)

1. **Launch app in simulator**
   - App is already installed on iPhone 17 simulator
   - Just open it from simulator home screen

2. **Navigate to Claude Chat**
   - Go to "Agent Chat" tab
   - Tap "New Chat" button

3. **Create new chat**
   - Send a simple message: "Hello"
   - Observe: Should work fine, no errors

4. **Stop simulator log capture**
   ```bash
   killall -9 log
   ```

5. **Review simulator logs**
   ```bash
   grep -E "(DEBUG|Environment|handleReceivedText|Invalid|message format)" /tmp/simulator_test.log
   ```

### Step 3: Test Physical Device (Find the Issue)

1. **Install app to device**
   - Build is ready in Xcode
   - Deploy to "Roth iPhone" (already built)
   - OR: Open `src/BuilderOS.xcodeproj` in Xcode, select "Roth iPhone", click Run

2. **Navigate to Claude Chat**
   - Go to "Agent Chat" tab
   - Tap "New Chat" button

3. **Create new chat**
   - Send a simple message: "Hello"
   - **Observe: "Invalid message format" error will appear** ❌

4. **Stop device log capture**
   ```bash
   killall -9 devicectl
   ```

5. **Review device logs**
   ```bash
   grep -E "(DEBUG|Environment|handleReceivedText|Invalid|message format)" /tmp/device_test.log
   ```

### Step 4: Compare Logs

**Expected Difference:**

The device logs will show exactly what message is being received that causes the error. Look for:

```
🔍 [DEBUG] Environment: PHYSICAL DEVICE
🔍 [DEBUG] handleReceivedText called
🔍 [DEBUG] Full text: [UNEXPECTED MESSAGE HERE]
⚠️ Failed to decode message as JSON
🔍 [DEBUG] Message IS valid JSON but not ClaudeResponse structure
```

**Key Questions to Answer:**

1. **What message text appears on device but not simulator?**
   - Look for the "Full text:" line in device logs
   - Compare with simulator logs

2. **Is it valid JSON or not?**
   - Check if log says "Message IS valid JSON but not ClaudeResponse structure"
   - OR "Message is NOT valid JSON at all"

3. **When does it occur?**
   - After "authenticated" message?
   - After "ready" message?
   - After first user message?

4. **What's the hex dump?**
   - Check "Text bytes (hex):" line
   - Might reveal hidden characters or encoding issues

## Example of What to Look For

### Good (Simulator):
```
🔍 [DEBUG] Environment: SIMULATOR
🔍 [DEBUG] handleReceivedText called
🔍 [DEBUG] Full text: {"type":"ready","session_id":"abc123"}
```

### Bad (Device) - Example scenarios:

**Scenario A: Extra Cloudflare header**
```
🔍 [DEBUG] Environment: PHYSICAL DEVICE
🔍 [DEBUG] handleReceivedText called
🔍 [DEBUG] Full text: CF-RAY: abc123-SJC
⚠️ Failed to decode message as JSON
🔍 [DEBUG] Message is NOT valid JSON at all
```

**Scenario B: Different JSON structure from tunnel**
```
🔍 [DEBUG] Environment: PHYSICAL DEVICE
🔍 [DEBUG] handleReceivedText called
🔍 [DEBUG] Full text: {"tunnel":"cloudflare","type":"ready","session_id":"abc123"}
⚠️ Failed to decode message as JSON
🔍 [DEBUG] Message IS valid JSON but not ClaudeResponse structure
🔍 [DEBUG] JSON structure: {tunnel = cloudflare; type = ready; "session_id" = abc123;}
```

**Scenario C: Timing/race condition**
```
🔍 [DEBUG] Environment: PHYSICAL DEVICE
🔍 [DEBUG] handleReceivedText called
🔍 [DEBUG] Full text: ready
🔍 [DEBUG] authenticationComplete: true
🔍 [DEBUG] Message is NOT valid JSON at all
```

## What to Report Back

**Once you've captured both logs, provide:**

1. **The exact "Full text:" from device logs** when error occurs
2. **Whether it's valid JSON or not** (from debug output)
3. **The hex bytes** if text looks suspicious
4. **Any differences** in message sequence between device and simulator

**Example report:**
```
Device receives this message that simulator doesn't:
"CF-RAY: 8d4f3e2c1b0a9876-SJC"

This is a Cloudflare header being sent as a WebSocket message.
The fix needed: Filter out Cloudflare metadata messages.
```

## Quick Test Command

**One-liner to test and capture logs:**

```bash
# Simulator test
open -a Simulator && \
xcrun simctl spawn "iPhone 17" log stream --predicate 'process == "BuilderOS"' 2>&1 | \
grep -E "(DEBUG|Environment|handleReceivedText|Invalid)" | tee /tmp/sim_test.log

# Device test (in another terminal)
xcrun devicectl device info logs --device 00008110-00111DCC0A31801E stream \
--predicate 'processImagePath CONTAINS "BuilderOS"' 2>&1 | \
grep -E "(DEBUG|Environment|handleReceivedText|Invalid)" | tee /tmp/device_test.log
```

## Files Modified

- `src/Services/ClaudeAgentService.swift` - Enhanced diagnostic logging
- `src/Utilities/AnimationComponents.swift` - Added to Xcode project
- `/tmp/capture_device_logs.sh` - Log capture helper script

## Next Steps After Log Capture

Once you've identified the culprit message:

1. **Share the logs** - Paste relevant log lines
2. **I'll implement the fix** - Handle the device-specific message properly
3. **Test fix on both platforms** - Verify simulator still works AND device error is gone
4. **Document the root cause** - Update this file with solution

---

**Ready to test!** Follow steps 1-4 above, then share what you find in the device logs.
