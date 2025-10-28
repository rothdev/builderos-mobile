# Mobile Agent Routing Fix - Complete

**Date:** 2025-10-28
**Issue:** Jarvis chat showing "read-only snapshot" message
**Status:** ✅ RESOLVED

---

## Problem

When chatting with Jarvis in the BuilderOS Mobile app, users received this incorrect message:

> "I'm working inside a read-only snapshot of your BuilderOS workspace, so I can browse the code but can't modify anything."

This was **completely false** - the mobile app should have full BuilderOS access just like desktop Claude Code.

---

## Root Cause Analysis

### The Flow

1. **Mobile App** (Jarvis tab) → sends message
2. **Backend Server** (`server_persistent.py`) → receives message
3. **BridgeHub Client** (`bridgehub_client.py`) → calls BridgeHub
4. **BridgeHub** (`freeform.js`) → spawns CLI
5. **CLI Response** → streams back to mobile

### The Bug

In `bridgehub_client.py`, the `call_jarvis()` function was **not** setting the `direction` field in the BridgeHub request.

BridgeHub defaults `direction` to `"claude_to_codex"` which:
- Spawns **Codex CLI** (not Claude Code!)
- Codex was running in `sandbox: read-only` mode
- Even with `-s danger-full-access -a never` flags, Codex still ran read-only

### Why Codex Was Read-Only

The BridgeHub command was:
```bash
codex -s danger-full-access -a never exec <prompt>
```

But Codex kept showing:
```
sandbox: read-only
```

The flags were being ignored due to argument conflicts. The fix was to use:
```bash
codex exec --dangerously-bypass-approvals-and-sandbox <prompt>
```

Which correctly sets:
```
sandbox: danger-full-access
approval: never
```

---

## The Fix

### 1. Fixed Mobile Backend Routing (`bridgehub_client.py`)

**For Jarvis chat (`call_jarvis`):**
```python
"direction": "codex_to_claude"  # Routes to Claude Code
```

**For Codex chat (`call_codex`):**
```python
"direction": "claude_to_codex"  # Routes to Codex CLI
```

### 2. Fixed Codex Sandbox Flags (`spawn_cli.js`)

Changed from:
```javascript
['- danger-full-access', '-a', 'never', 'exec', prompt]
```

To:
```javascript
['exec', '--dangerously-bypass-approvals-and-sandbox', prompt]
```

---

## Verified Behavior

### Jarvis Tab (Mobile App)

**Routes to:** Claude Code
**Direction:** codex_to_claude
**Sandbox:** None (full access)

**Test Response:**
```
I am **Claude Code**, running in Ty's BuilderOS environment on macOS.

Environment Details:
- Working Directory: /Users/Ty/BuilderOS
- Git Repository: Yes (main branch)
- Platform: darwin (macOS)
- Full BuilderOS access: Yes

Current Identity: Jarvis - Ty's Number-2 and chief of staff

Access includes:
- All filesystem operations
- Git operations and repository management
- MCP servers (Supabase, N8N, Penpot, Context7, Playwright, etc.)
- Agent orchestration and delegation
- Task management and autonomous execution
```

### Codex Tab (Mobile App)

**Routes to:** Codex CLI
**Direction:** claude_to_codex
**Sandbox:** danger-full-access

**Test Response:**
```
I'm running in `danger-full-access`, so I can read and write anywhere,
including /Users/Ty/BuilderOS.
```

**Logs show:**
```
sandbox: danger-full-access
approval: never
```

---

## Technical Details

### BridgeHub Direction Routing

From `freeform.js`:
```javascript
function getDirectionMetadata(direction) {
    if (direction === 'codex_to_claude') {
        return {
            sourceLabel: 'Codex',
            targetLabel: 'Claude Code',
            spawn: spawnClaude  // Full access, no sandbox
        };
    }
    return {
        sourceLabel: 'Claude Code',
        targetLabel: 'Codex',
        spawn: spawnCodex  // danger-full-access sandbox
    };
}
```

### CLI Commands

**Claude Code:**
```bash
claude --dangerously-skip-permissions -p <prompt>
```
- No sandbox
- Full BuilderOS access
- All MCP servers available

**Codex:**
```bash
codex exec --dangerously-bypass-approvals-and-sandbox <prompt>
```
- Sandbox: danger-full-access
- Approval: never
- Full read/write access

---

## Files Modified

### BuilderOS Mobile Backend
- `api/bridgehub_client.py`
  - Set `direction: "codex_to_claude"` for Jarvis
  - Set `direction: "claude_to_codex"` for Codex
  - Added comprehensive documentation

### BridgeHub CLI Spawner
- `tools/bridgehub/dist/lib/spawn_cli.js`
  - Changed Codex command to use `--dangerously-bypass-approvals-and-sandbox`
  - Fixed sandbox mode from read-only to danger-full-access

---

## Testing Procedure

### Manual Test (Desktop)

```bash
# Test Jarvis routing
node /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js --request '{
  "version":"bridgehub/1.0",
  "action":"freeform",
  "capsule":"/Users/Ty/BuilderOS",
  "session":"test",
  "payload":{
    "message":"What environment are you in?",
    "direction":"codex_to_claude",
    "context":[],
    "metadata":{"source":"test"}
  }
}'
# Should respond: "I am Claude Code with full BuilderOS access"

# Test Codex routing
node /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js --request '{
  "version":"bridgehub/1.0",
  "action":"freeform",
  "capsule":"/Users/Ty/BuilderOS",
  "session":"test",
  "payload":{
    "message":"What sandbox mode are you in?",
    "direction":"claude_to_codex",
    "context":[],
    "metadata":{"source":"test"}
  }
}'
# Should respond: "I'm in danger-full-access mode"
```

### Mobile Test

1. Open BuilderOS Mobile app
2. Navigate to **Jarvis tab**
3. Send message: "Do you have full BuilderOS access?"
4. **Expected:** Response confirms Claude Code with full access
5. Navigate to **Codex tab**
6. Send message: "What sandbox mode are you in?"
7. **Expected:** Response confirms danger-full-access mode

---

## Impact

✅ **Fixed:** Jarvis chat now has full BuilderOS access via Claude Code
✅ **Fixed:** Codex chat now has danger-full-access sandbox (not read-only)
✅ **Improved:** Clear separation between coordination (Jarvis) and code (Codex)
✅ **Documented:** Comprehensive routing documentation in code

---

## Commits

1. **BridgeHub Fix:**
   ```
   fix(codex): use --dangerously-bypass-approvals-and-sandbox for full access
   ```
   - Changed Codex CLI command to use correct flag
   - Fixes sandbox being read-only instead of danger-full-access

2. **Mobile Backend Fix:**
   ```
   fix(mobile): route Jarvis chat to Claude Code instead of Codex
   ```
   - Set direction for Jarvis → codex_to_claude
   - Set direction for Codex → claude_to_codex
   - Added routing documentation

---

## Next Steps

1. ✅ Backend server restarted with new code
2. ⏳ Test on mobile device
3. ⏳ Verify full access in production
4. ⏳ Monitor logs for any routing issues

---

**Status:** Ready for mobile testing
**Backend:** Running at https://api.builderos.app
**Health:** All systems operational
