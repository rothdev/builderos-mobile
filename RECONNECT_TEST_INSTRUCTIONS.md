# iOS Reconnect Button Test Instructions

## Status: Ready for Testing

**Date**: October 29, 2025
**Device**: Roth iPhone (00008110-00111DCC0A31801E)
**Build Status**: ✅ Deployed successfully with comprehensive logging

---

## What Was Done

1. **Enhanced Logging Added** (Mobile Dev agent)
   - Comprehensive logging in `ChatAgentServiceBase.swift:209-300`
   - Tracks every step of reconnection flow
   - Shows service counts, connection states, and errors

2. **App Rebuilt and Deployed**
   - Fresh build with all logging enhancements
   - Successfully installed on your iPhone
   - Ready to test

---

## How to Test

### Option 1: Quick Manual Test

1. Open BuilderOS app on your iPhone
2. Open a Claude or Codex chat (this creates services in memory)
3. Go to Settings or Dashboard
4. Press the **Reconnect** button
5. Watch for the "Disconnected" → "Connected" transition

### Option 2: Detailed Test with Log Capture

**Use the automated log capture script I created:**

```bash
/tmp/capture_reconnect_logs.sh
```

This will:
- Start capturing device logs
- Tell you to press the reconnect button
- Save all reconnection-related logs to a timestamped file
- Highlight key patterns to look for

**To run it:**
```bash
bash /tmp/capture_reconnect_logs.sh
```

---

## What to Look For in Logs

### If Reconnection WORKS:
```
🔄🔄🔄 RECONNECT ALL CALLED
📊 Active Claude services: 1
📊 Active Codex services: 0
🔄 RECONNECTING Claude service #1
   ⚡ Calling disconnect()...
   ⚡ Calling connect()...
   ✅ Claude service reconnected successfully!
🎉🎉🎉 RECONNECTION COMPLETE
```

### If Reconnection FAILS:
```
🔄🔄🔄 RECONNECT ALL CALLED
📊 Active Claude services: 0
📊 Active Codex services: 0
⚠️⚠️⚠️ NO ACTIVE CHAT SERVICES TO RECONNECT
   Tip: Open a chat screen first to establish connections
```

Or:
```
🔄🔄🔄 RECONNECT ALL CALLED
📊 Active Claude services: 1
⚡ Calling disconnect()...
⚡ Calling connect()...
⚠️ Already connected to Claude Agent  ← PROBLEM: Guard clause blocking reconnection
❌ Failed to reconnect Claude service
```

---

## Testing Workflow

### Scenario 1: Services Exist (Expected Success)
1. Open BuilderOS app
2. **Open a Claude chat** (creates ClaudeAgentService in memory)
3. Backend restarts or connection drops
4. Press reconnect button
5. **Expected**: Services disconnect then reconnect successfully

### Scenario 2: No Services (Expected Warning)
1. Open BuilderOS app
2. **Don't open any chat screens**
3. Press reconnect button
4. **Expected**: "NO ACTIVE CHAT SERVICES TO RECONNECT" message

### Scenario 3: Stale Connection State (The Bug We're Hunting)
1. Open BuilderOS app
2. Open a Claude chat (connection established)
3. Backend restarts (app doesn't detect disconnect immediately)
4. Press reconnect button
5. **If bug still exists**: "Already connected" guard clause blocks reconnection
6. **If bug is fixed**: Force disconnect clears state, reconnection succeeds

---

## After Testing

### If It Works:
Great! The fix is working. Test multi-message conversations to verify the original "returncode" error is also resolved.

### If It Doesn't Work:
1. Share the captured logs (check `/tmp/reconnect_test_*.log`)
2. I'll analyze the logs to identify the root cause
3. Look for these specific patterns:
   - Was `reconnectAll()` actually called?
   - How many services were active?
   - Did disconnect execute?
   - Did connect execute?
   - What error occurred?

---

## Manual Log Viewing (Alternative)

If the automated script doesn't work, you can view logs manually:

```bash
# Stream logs and watch for reconnection attempts
xcrun devicectl device info logs --device 00008110-00111DCC0A31801E stream \
  --predicate 'processImagePath CONTAINS "BuilderOS"' | \
  grep -E "(RECONNECT|reconnect|🔄|⚡|✅|❌)"
```

Press Ctrl+C to stop.

---

## Quick Reference

**Log capture script**: `/tmp/capture_reconnect_logs.sh`
**Device ID**: `00008110-00111DCC0A31801E`
**Key files with logging**:
- `src/Services/ChatAgentServiceBase.swift:209-300`
- `src/Views/SettingsView.swift:110-135`
- `src/Views/DashboardView.swift:126-153`

**Backend health check**: `curl http://localhost:8080/api/health`

---

Ready to test! Let me know what you see and I'll analyze the logs to fix any remaining issues.
