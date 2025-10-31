# Claude Context Fix for BuilderOS Mobile App

## Problem
Claude chat in the BuilderOS mobile app was responding without proper identity or context:
- Claude didn't know it was Jarvis (Ty's Number-2 assistant)
- Claude didn't know it was in the BuilderOS system
- Claude gave incorrect paths (e.g., "/home/user" instead of "/Users/Ty/BuilderOS")
- Claude had no BuilderOS context or capabilities awareness

## Root Cause
The mobile API server (`/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server.py`) was making direct Anthropic API calls **without a system prompt**:

```python
# BEFORE (broken)
response = anthropic_client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[
        {"role": "user", "content": content}  # ← NO SYSTEM PROMPT!
    ],
    stream=True
)
```

## Solution Implemented

### 1. Added System Prompt Builder Function
Created `build_system_prompt()` function that includes:
- **Jarvis Identity**: "You are Jarvis, Ty's Number-2, second-in-command..."
- **BuilderOS Context**: System purpose, working directory, platform (macOS)
- **Autonomous Execution Principle**: Guidelines for decision vs. execution
- **Mobile Context**: Response format guidance for mobile interface

### 2. Updated Claude Message Handler
Modified `handle_claude_message()` to include system prompt:

```python
# AFTER (fixed)
async def handle_claude_message(content: str, working_directory: str = "/Users/Ty/BuilderOS"):
    # Build system prompt with Jarvis identity and context
    system_prompt = build_system_prompt(working_directory)

    response = anthropic_client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=4096,
        system=system_prompt,  # ← ADDED SYSTEM PROMPT
        messages=[
            {"role": "user", "content": content}
        ],
        stream=True
    )
```

### 3. Enhanced WebSocket Handler
Updated `claude_websocket_handler()` to:
- Set default working directory: `/Users/Ty/BuilderOS`
- Send ready message with Jarvis identity
- Include BuilderOS system context in responses
- Pass working_directory to message handler

### 4. Updated Ready Message
Changed from generic "Claude Agent connected" to:
```json
{
    "type": "ready",
    "content": "Jarvis activated. BuilderOS mobile interface ready.",
    "identity": "Jarvis",
    "working_directory": "/Users/Ty/BuilderOS",
    "system": "BuilderOS"
}
```

## Files Modified
- `/Users/Ty/BuilderOS/capsules/builderos-mobile/api/server.py`
  - Added `build_system_prompt()` function (lines 76-121)
  - Updated `handle_claude_message()` to include system prompt (lines 155-182)
  - Updated `claude_websocket_handler()` protocol documentation and ready message (lines 200-261)

## Testing
To verify the fix works:

1. **Open BuilderOS mobile app** on iOS
2. **Navigate to Claude chat**
3. **Ask identity questions**:
   - "Who are you?" → Should respond "I'm Jarvis, Ty's Number-2..."
   - "What directory are you in?" → Should respond "/Users/Ty/BuilderOS"
   - "What system are you running on?" → Should mention BuilderOS and macOS

## Expected Behavior (After Fix)
✅ Claude knows it's Jarvis
✅ Claude knows it's in BuilderOS system
✅ Claude provides correct macOS paths
✅ Claude understands its role as Ty's chief of staff
✅ Claude has full BuilderOS context and capabilities awareness

## Server Restart
API server restarted with new context:
```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile/api
source venv/bin/activate
nohup python3 server.py > /tmp/builderos_api_new.log 2>&1 &
```

Server is running on:
- **HTTP**: http://localhost:8080
- **WebSocket (Claude)**: ws://localhost:8080/api/claude/ws
- **WebSocket (Codex)**: ws://localhost:8080/api/codex/ws

---

**Date Fixed**: 2025-10-30
**Fixed By**: Jarvis (Mobile Development Specialist)
**Issue Type**: Missing system context in API calls
**Impact**: High - Core identity and context restoration
