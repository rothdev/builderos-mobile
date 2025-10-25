# Phase 3: Testing & Validation Guide

**Date:** October 25, 2025
**Status:** Backend Ready - iOS Testing Required

---

## 🎯 Overview

**Phase 1 & 2:** ✅ Complete (Backend + iOS implementation)
**Phase 3:** ⏳ In Progress (Testing & Validation)

We've successfully implemented the Claude Agent SDK integration. Now we need to validate it works end-to-end from the iOS app.

---

## ✅ What's Been Validated (Backend)

### 1. SDK Installation ✅
- Claude Agent SDK v0.1.5 installed
- Correct API identified: `ClaudeSDKClient` and `query()`
- Basic query test: **PASSED** ✅

### 2. API Server Status ✅
- Server running at: `http://localhost:8080`
- Main health: ✅ Operational
- Claude Agent health: ✅ Operational

**Health Check Results:**
```json
{
  "service": "claude_agent",
  "status": "operational",
  "sdk_available": true,
  "using_subscription": true,
  "capsule": "/Users/Ty/BuilderOS/capsules/builderos-mobile",
  "context_sources": ["project"],
  "agents_available": 29,
  "mcp_servers": "auto-loaded from ~/.claude/mcp.json"
}
```

### 3. Subscription Authentication ✅
- No ANTHROPIC_API_KEY in environment
- SDK using Max 20x subscription (not API billing)
- Authentication test: **PASSED** ✅

### 4. Backend API Fix ✅
- Updated `routes/claude_agent.py` to use correct SDK API
- Changed from non-existent `ClaudeAgent` → `ClaudeSDKClient`
- WebSocket endpoint ready at `/api/claude/ws`

---

## ⏳ What Needs Testing (iOS)

### Test 1: iOS Connection to Backend
**Goal:** Verify iOS app connects to WebSocket endpoint

**Steps:**
1. Open Xcode: `open src/BuilderOS.xcodeproj`
2. Run on iPhone 17 simulator (Cmd+R)
3. Go to **Terminal** tab
4. Switch to **"Chat Terminal"** mode
5. Toggle ON: **"Use Claude Agent SDK"**
6. Look for connection status:
   - 🟢 Green = Connected ✅
   - 🔴 Red = Failed ❌

**Expected Result:**
- Green connection indicator
- Ready message appears

**If Failed:**
- Check Xcode console for errors
- Check API server logs: `tail -f /Users/Ty/BuilderOS/api/server.log`

---

### Test 2: Basic Message Exchange
**Goal:** Verify messages send and Claude responds

**Steps:**
1. In iOS app, type: "Hello, what can you help me with?"
2. Tap send
3. Wait for response

**Expected Result:**
- User message appears (blue bubble, right side)
- Loading indicator: "Claude is thinking..."
- Claude response appears (gray bubble, left side)
- Response is real content (not mock)

**If Failed:**
- Check Xcode console for JSON parsing errors
- Check server logs for WebSocket errors
- Verify API key is correct (Settings tab)

---

### Test 3: CLAUDE.md Context Loading
**Goal:** Verify Claude has BuilderOS Mobile context

**Test Message:**
```
"What capsule are you running in? What's this app about?"
```

**Expected Response:**
Claude should mention:
- Running in "builderos-mobile" capsule
- iOS app for remote BuilderOS access
- Native Swift + SwiftUI
- Cloudflare Tunnel architecture

**If Failed:**
- Check `setting_sources` in backend code
- Verify CLAUDE.md exists at capsule root
- Check server logs for context loading

---

### Test 4: Agent Delegation
**Goal:** Verify Claude can delegate to BuilderOS agents

**Test Message:**
```
"What agents are available in BuilderOS? Can you delegate work to them?"
```

**Expected Response:**
Claude should list agents like:
- 📱 Mobile Dev (iOS/Swift development)
- 🎨 Frontend Dev (React/Next.js)
- 🏛️ Backend Dev (APIs/databases)
- And explain how delegation works

**Test Delegation:**
```
"I need to add a new feature to the chat view. Can Mobile Dev help?"
```

**Expected Response:**
- Claude explains it will delegate to Mobile Dev
- May show agent working indicator

**If Failed:**
- Agents may not be available in SDK mode
- Check server logs for agent initialization

---

### Test 5: Quick Actions
**Goal:** Verify quick action buttons work

**Steps:**
1. Tap **"📊 Status"** button
2. Wait for response

**Expected Result:**
- Claude provides BuilderOS system status
- Real data (capsules, git status, etc.)

**Try Other Actions:**
- **🔧 Tools** - Should list available tools
- **📱 Capsules** - Should list capsules
- **📈 Metrics** - Should provide system metrics
- **🤖 Agents** - Should list agents

---

### Test 6: MCP Server Access
**Goal:** Verify Claude can use MCP servers

**Test Message:**
```
"What MCP servers do you have access to?"
```

**Expected Response:**
List of MCP servers like:
- n8n-mcp (workflow automation)
- context7 (documentation lookup)
- shadcn-ui (UI components)
- builder-memory (knowledge graph)

**Test MCP Usage:**
```
"Use context7 to look up Swift documentation for URLSession"
```

**Expected Response:**
- Claude uses context7 MCP
- Returns Swift URLSession documentation

**If Failed:**
- MCP servers may not load in SDK mode
- Check MCP config location
- Check server logs for MCP initialization

---

### Test 7: Streaming Responses
**Goal:** Verify response streaming works

**Test Message:**
```
"Write a detailed explanation of how this iOS app works"
```

**Expected Behavior:**
- Loading indicator appears
- Response chunks stream in (word by word or sentence by sentence)
- No long delay before first word appears

**If Failed:**
- Check WebSocket streaming implementation
- Verify JSON parsing handles chunks correctly

---

### Test 8: Error Handling
**Goal:** Verify graceful error handling

**Tests:**
1. **Disconnect Server:**
   - Stop API: `./server_mode.sh stop`
   - Try sending message
   - Expected: Red connection indicator, error message

2. **Reconnect:**
   - Restart API: `./server_mode.sh start`
   - Connection should auto-restore (or manual reconnect)

3. **Invalid Message:**
   - Send empty message
   - Expected: No crash, graceful handling

---

## 📊 Phase 3 Checklist

### Backend Validation ✅
- [x] SDK installed correctly
- [x] Health endpoint operational
- [x] Subscription auth verified
- [x] WebSocket endpoint ready
- [x] Code fixed to use correct API

### iOS Validation (Pending Your Testing)
- [ ] App connects to WebSocket
- [ ] Messages send successfully
- [ ] Claude responses received
- [ ] CLAUDE.md context loads
- [ ] Agent delegation works
- [ ] MCP servers accessible
- [ ] Quick actions functional
- [ ] Streaming responses work
- [ ] Error handling graceful
- [ ] Reconnection works

---

## 🧪 How to Test

### Start Backend
```bash
cd /Users/Ty/BuilderOS/api
./server_mode.sh status  # Check if running
# If not running:
./server_mode.sh start
```

### Start iOS App
```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile
open src/BuilderOS.xcodeproj
```

In Xcode:
1. Select iPhone 17 simulator
2. Press **Cmd+R** to run
3. Wait for app to launch

### Run Tests
Follow the test scenarios above (Test 1-8) in order.

### Monitor Logs
**Xcode Console:** Debug area (bottom panel)
**Server Logs:** `tail -f /Users/Ty/BuilderOS/api/server.log`

---

## 🐛 Known Issues & Workarounds

### Issue 1: MCP Config Location
**Problem:** SDK expects MCP config at `~/.claude/mcp.json`
**Actual:** BuilderOS uses `/Users/Ty/BuilderOS/.mcp.json`

**Status:** May affect MCP server loading

**Workaround:**
```bash
# Create symlink if needed
ln -s /Users/Ty/BuilderOS/.mcp.json ~/.claude/mcp.json
```

### Issue 2: Voice Input Disabled
**Problem:** VoiceManager not integrated into BuilderOS target

**Status:** Commented out in ClaudeChatView

**Workaround:** Use text input only for now

### Issue 3: Plain Text Rendering
**Problem:** No markdown or code syntax highlighting

**Status:** Basic text bubbles only

**Workaround:** Acceptable for initial testing, enhance later

---

## 🎯 Success Criteria

**Phase 3 Complete When:**
1. ✅ iOS app connects to backend
2. ✅ Messages send/receive correctly
3. ✅ Claude has full BuilderOS context
4. ✅ Responses are real (not mock)
5. ⚠️ Agent delegation verified (if possible in SDK mode)
6. ⚠️ MCP servers accessible (if config loads)
7. ✅ Quick actions work
8. ✅ Error handling graceful

**Minimum for Success:** Items 1-4 and 7-8 working

---

## 📈 Next Steps After Phase 3

### If All Tests Pass ✅
1. Test on real iPhone (over Cloudflare Tunnel)
2. Test on cellular network
3. Add voice input integration
4. Add markdown rendering
5. Deploy to TestFlight

### If Tests Fail ❌
1. Review Xcode console errors
2. Review server logs
3. Debug WebSocket connection
4. Verify JSON message format
5. Fix identified issues

---

## 📝 Test Results Template

**Copy this and fill out as you test:**

```
# Phase 3 Test Results

**Date:** [DATE]
**Tester:** Ty
**Environment:** iOS Simulator (iPhone 17)

## Backend Status
- API Server: [ ] Running / [ ] Not Running
- Health Check: [ ] Passed / [ ] Failed
- Subscription Auth: [ ] Verified / [ ] Failed

## iOS Tests
1. Connection: [ ] ✅ / [ ] ❌ - Notes: _______
2. Message Exchange: [ ] ✅ / [ ] ❌ - Notes: _______
3. Context Loading: [ ] ✅ / [ ] ❌ - Notes: _______
4. Agent Delegation: [ ] ✅ / [ ] ❌ - Notes: _______
5. Quick Actions: [ ] ✅ / [ ] ❌ - Notes: _______
6. MCP Access: [ ] ✅ / [ ] ❌ - Notes: _______
7. Streaming: [ ] ✅ / [ ] ❌ - Notes: _______
8. Error Handling: [ ] ✅ / [ ] ❌ - Notes: _______

## Issues Found
- [Issue 1 description]
- [Issue 2 description]

## Overall Status
[ ] All tests passed - Ready for real device testing
[ ] Some tests failed - Needs debugging
[ ] Major issues - Needs significant fixes
```

---

**Ready to test!** 🚀

Start with Test 1 (iOS Connection) and work through the list. Report any failures and we'll debug together.

---

*Created by Jarvis - October 25, 2025*
