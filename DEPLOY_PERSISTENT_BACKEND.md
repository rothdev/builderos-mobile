# Deploy Session-Persistent Backend

**Current Status:** Old stateless server running on port 8080
**Action Required:** Switch to new persistent server for iOS session support

---

## Quick Deploy (2 minutes)

```bash
# 1. Stop old server
pkill -f "python.*server.py"

# 2. Verify port is free
lsof -ti:8080
# (Should return nothing)

# 3. Start new persistent server
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
python3 api/server_persistent.py
```

**Expected Output:**
```
============================================================
🚀 BuilderOS Mobile API Server v2.0 (Session-Persistent)
============================================================
📡 Listening on http://localhost:8080
🔌 WebSocket endpoints:
   - ws://localhost:8080/api/claude/ws (Jarvis)
   - ws://localhost:8080/api/codex/ws (Codex)
💾 Session database: api/sessions.db
📚 Active sessions: 0
============================================================
```

---

## Verification

**1. Check health endpoint:**
```bash
curl http://localhost:8080/api/health | python3 -m json.tool
```

**Expected Response:**
```json
{
  "status": "ok",
  "version": "2.0.0-persistent",
  "connections": {
    "claude": 0,
    "codex": 0
  },
  "sessions": {
    "total": 0,
    "by_agent": {"claude": 0, "codex": 0}
  },
  "bridgehub": {
    "bridgehub_exists": true,
    "node_available": true,
    "ready": true
  }
}
```

**Key indicators of persistent server:**
- `"version": "2.0.0-persistent"`
- `"sessions"` object present
- `"bridgehub"` health check present

**2. Test iOS app connection:**
1. Build iOS app in Xcode
2. Run on simulator
3. Connect to Jarvis
4. Send test message
5. Check server logs for session creation

---

## What Changed

**Old Server (server.py):**
- Stateless message processing
- No conversation history
- Direct Anthropic API calls
- No agent coordination

**New Server (server_persistent.py):**
- ✅ Session persistence (SQLite)
- ✅ Full conversation history
- ✅ BridgeHub integration
- ✅ Agent delegation support
- ✅ CLAUDE.md context loading
- ✅ Multi-device session sharing

---

## Troubleshooting

### Issue: Port 8080 already in use

**Symptom:** `OSError: [Errno 48] Address already in use`

**Solution:**
```bash
# Find process using port
lsof -ti:8080

# Kill it
kill $(lsof -ti:8080)

# Or force kill
kill -9 $(lsof -ti:8080)
```

### Issue: BridgeHub not found

**Symptom:** `Error: BridgeHub not found`

**Solution:**
```bash
# Verify BridgeHub exists
ls -l /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js

# If missing, rebuild
cd /Users/Ty/BuilderOS/tools/bridgehub
npm install
npm run build
```

### Issue: Node.js not available

**Symptom:** `Error: Node.js not found`

**Solution:**
```bash
# Check Node.js
which node

# If missing
brew install node
```

### Issue: Sessions not persisting

**Symptom:** Conversation history lost after reconnect

**Solution:**
```bash
# Check database exists
ls -l api/sessions.db

# Verify database is writable
sqlite3 api/sessions.db "SELECT COUNT(*) FROM sessions;"

# Check server logs for persistence messages
# Look for "💾 Session persisted" lines
```

---

## iOS App Testing

After deploying persistent backend:

**1. Multi-turn conversation:**
```
You: "My name is Ty"
Jarvis: "Nice to meet you, Ty!"
You: "What's my name?"
Jarvis: "Your name is Ty."
```

**2. Session persistence:**
```
You: "Remember: the code is 1234"
(Close app)
(Reopen app)
You: "What's the code?"
Jarvis: "The code is 1234"
```

**3. Check console logs:**
```
📋 Claude session ID: ABC123-jarvis
📱 Device ID: ABC123
📤 JSON with session fields: {...}
```

---

## Rollback (If Needed)

If issues occur, revert to old server:

```bash
# 1. Stop new server
pkill -f "python.*server_persistent.py"

# 2. Start old server
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
python3 api/server.py
```

**Note:** iOS app will still work with old server, but:
- No conversation history
- No agent coordination
- Context lost between messages

---

## Make it Persistent (LaunchAgent)

To start persistent server automatically on Mac boot:

```bash
# Create LaunchAgent plist
cat > ~/Library/LaunchAgents/com.builderos.mobile-backend.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.builderos.mobile-backend</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server_persistent.py</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/Ty/BuilderOS/capsules/builderos-mobile</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server.err</string>
</dict>
</plist>
EOF

# Load LaunchAgent
launchctl load ~/Library/LaunchAgents/com.builderos.mobile-backend.plist

# Verify it's running
launchctl list | grep builderos
```

**Manage LaunchAgent:**
```bash
# Stop
launchctl unload ~/Library/LaunchAgents/com.builderos.mobile-backend.plist

# Start
launchctl load ~/Library/LaunchAgents/com.builderos.mobile-backend.plist

# Check status
launchctl list | grep builderos
```

---

## Summary

**Current State:** ❌ Old stateless server running
**Required State:** ✅ New persistent server running
**Estimated Deploy Time:** 2 minutes
**Rollback Time:** 1 minute

**Next Steps:**
1. Deploy persistent backend (commands above)
2. Test iOS app with new backend
3. Verify session persistence works
4. (Optional) Set up LaunchAgent for auto-start

---

**Deployment Ready:** ✅ All files in place
**Testing Checklist:** See `MIGRATION_GUIDE.md`
**Architecture Docs:** See `SESSION_PERSISTENCE_ARCHITECTURE.md`
