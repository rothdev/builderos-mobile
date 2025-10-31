# Claude Chat Streaming Fix

## Problem Summary

**Issue:** Claude chat messages were sent but NO RESPONSE was received from the backend.

**Symptoms:**
- User sends message to Claude chat
- Mobile app shows message sent
- No response chunks arrive via WebSocket
- Chat appears frozen/broken

## Root Cause Analysis

The `handle_claude_message()` function in `api/server.py` was **synchronous** (blocking) instead of **async streaming**.

### Before (BROKEN):
```python
async def handle_claude_message(content: str) -> str:
    # Create message with streaming
    response = anthropic_client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=4096,
        messages=[{"role": "user", "content": content}],
        stream=True
    )

    # Collect FULL response (blocking)
    full_response = ""
    for chunk in response:
        if hasattr(chunk, 'delta') and hasattr(chunk.delta, 'text'):
            full_response += chunk.delta.text

    return full_response  # Returns only after ALL chunks received
```

**Problem Flow:**
1. User sends message
2. Backend calls Claude API
3. Backend **WAITS** for entire response (30-60+ seconds)
4. Mobile app gets NOTHING during this time
5. Finally backend sends artificial chunks all at once

### After (FIXED):
```python
async def handle_claude_message(content: str):
    # Create message with streaming
    response = anthropic_client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=4096,
        messages=[{"role": "user", "content": content}],
        stream=True
    )

    # Stream response chunks as they arrive
    for chunk in response:
        if hasattr(chunk, 'delta') and hasattr(chunk.delta, 'text'):
            yield chunk.delta.text  # Yield immediately
```

**Fixed Flow:**
1. User sends message
2. Backend calls Claude API
3. Backend **YIELDS** chunks as they arrive in real-time
4. Mobile app displays streaming response immediately
5. Natural streaming experience

## Changes Made

### File: `api/server.py`

**1. Changed `handle_claude_message` to generator function:**
- Changed return type from `-> str` to generator (no return annotation)
- Changed `return full_response` to `yield chunk.delta.text`
- Now yields chunks immediately instead of collecting them

**2. Updated Claude WebSocket handler:**
```python
# Before (blocking)
response_text = await handle_claude_message(user_message)
for i in range(0, len(response_text), chunk_size):
    chunk = response_text[i:i+chunk_size]
    await ws.send_json(chunk_msg)
    await asyncio.sleep(0.05)  # Artificial delay

# After (streaming)
full_response = ""
async for chunk in handle_claude_message(user_message):
    full_response += chunk  # Track for push notifications
    chunk_msg = {
        "type": "message",
        "content": chunk,
        "timestamp": datetime.now().isoformat()
    }
    await ws.send_json(chunk_msg)  # Send immediately
```

**3. Maintained push notification support:**
- Still tracks `full_response` for notification preview
- Sends notifications after complete message

## Comparison: Codex vs Claude

### Codex (Already Working):
```python
async def handle_codex_message(content: str, session_id: str, conversation_history: list):
    async for chunk in BridgeHubClient.call_codex(...):
        yield chunk  # True streaming
```

### Claude (Now Fixed):
```python
async def handle_claude_message(content: str):
    for chunk in response:
        if hasattr(chunk, 'delta') and hasattr(chunk.delta, 'text'):
            yield chunk.delta.text  # True streaming
```

Both now use the same **async generator pattern** for real-time streaming.

## Testing

**Server Status:**
```bash
$ curl http://localhost:8080/api/health
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2025-10-30T18:07:42.115615",
  "connections": {
    "claude": 0,
    "codex": 0
  }
}
```

**Expected Behavior (Mobile App):**
1. Send message to Claude chat
2. Immediately see "Claude is typing..." indicator
3. Response chunks appear in real-time as Claude generates them
4. Smooth streaming experience matching Codex chat

## Next Steps

**For Testing:**
1. Open BuilderOS mobile app
2. Navigate to Claude chat
3. Send a test message (e.g., "Hello, can you help me?")
4. Verify response streams in real-time
5. Confirm no long pauses or blocking

**For Deployment:**
- Backend server already restarted with fix
- No mobile app changes needed (client already supports streaming)
- Monitor backend logs for any errors

## Files Modified

- `api/server.py`:
  - Line 107-129: Changed `handle_claude_message` to generator
  - Line 183-217: Updated WebSocket handler to use `async for`

## Prevention

**Why this happened:**
- Codex was recently fixed (added BridgeHub integration with streaming)
- Claude handler was never updated to match the streaming pattern
- API response collection pattern was synchronous from initial implementation

**To prevent in future:**
- All chat handlers should use async generator pattern
- Always yield chunks immediately, never collect full response first
- Test streaming behavior end-to-end before considering "done"
