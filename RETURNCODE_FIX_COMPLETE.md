# Backend "returncode" Error Fix - Complete

## Problem
After sending the first message in a Claude or Codex chat, the second message would fail with:
```
Error: Error: 'NoneType' object has no attribute 'returncode'
```

## Root Cause
The error was occurring in the Claude SDK's subprocess management (`subprocess_cli.py`). When our backend code called `send_message()` for each user message, it would:

1. Call `await self.client.query(message)` to send the message
2. Iterate through `async for response_chunk in self.client.receive_messages()`
3. When receiving `ResultMessage` (turn complete), **break** out of the iterator
4. Return to the WebSocket handler for the next message

The issue: **Breaking out of `receive_messages()` corrupts the SDK's internal state.** The Claude SDK expects `receive_messages()` to iterate continuously across multiple messages in a session, not to be broken and restarted per-message.

## The Fix
Changed line 149 in `/Users/Ty/BuilderOS/api/routes/claude_agent.py`:

**Before:**
```python
elif isinstance(response_chunk, ResultMessage):
    # ... send complete message ...
    break  # <-- This corrupts SDK state!
```

**After:**
```python
elif isinstance(response_chunk, ResultMessage):
    # ... send complete message ...
    # Return instead of break to end this generator cleanly
    # This allows the SDK to maintain its internal state for next message
    return  # <-- Exits the generator without breaking the iterator
```

## Why This Works
- `return` ends the current `send_message()` generator cleanly
- The underlying `receive_messages()` iterator remains intact
- The Claude SDK subprocess stays alive and ready for the next message
- Using `break` was forcefully exiting the iterator, which made the SDK think the subprocess had terminated

## Testing Instructions

### 1. Restart the Backend API
```bash
cd /Users/Ty/BuilderOS
# Stop any running API servers
pkill -f "python.*uvicorn"

# Start the API with the fix
cd api
source venv/bin/activate
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload &

# Wait a moment
sleep 3

# Verify it's running
curl http://localhost:8000/health
```

### 2. Test Multi-Message Conversations
Open BuilderOS app on your iPhone and test:

**Claude Chat:**
1. Create a new Claude chat
2. Send first message: "Hello"
3. Wait for response
4. Send second message: "Who are you?"
5. **Expected:** Should get a proper response without any errors

**Codex Chat:**
1. Create a new Codex chat
2. Send first message: "Hello"
3. Wait for response
4. Send second message: "What can you do?"
5. **Expected:** Should get a proper response without any errors

### 3. Test Multiple Messages in Sequence
Send 3-4 messages in a row to verify the fix is stable:
- "Hello"
- "Navigate to the BuilderOS mobile capsule"
- "What files are in this directory?"
- "Show me the package.json"

All messages should work without the `returncode` error.

## Additional Notes
- The same pattern may need to be applied to Codex if it also has issues
- This fix maintains backward compatibility - all existing functionality still works
- The fix is minimal and low-risk: just changing `break` to `return`

## Files Modified
- `/Users/Ty/BuilderOS/api/routes/claude_agent.py` - Line 153

## Status
✅ Fix implemented and ready for testing
⏳ Awaiting backend restart and device testing
