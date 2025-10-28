# TTS Mobile Session Fix (Option 1)

## Problem
When using mobile chat (Jarvis or Codex), the TTS hook on macOS was still triggering and playing audio on the Mac instead of the iPhone. The user wanted TTS to only play on macOS for desktop Claude Code sessions, not for mobile sessions.

## Solution
Implemented Option 1: Disable macOS TTS for mobile requests while preserving it for desktop sessions.

### Changes Made

#### 1. TTS Hook (`~/.claude/simple_tts_hook_fast.py`)
Added environment variable check at the start of `main()`:

```python
def main():
    """Main entry point."""
    log_debug("TTS client started")

    # Skip TTS for mobile sessions (Option 1: preserve macOS TTS for desktop)
    if os.environ.get("BUILDEROS_MOBILE_SESSION") == "true":
        log_debug("Mobile session detected, skipping TTS (playing on iOS)")
        return

    # ... rest of TTS hook continues
```

#### 2. BridgeHub Spawn CLI (`tools/bridgehub/dist/lib/spawn_cli.js`)

**Modified `spawnClaude()` to detect mobile sessions:**
```javascript
async function spawnClaude(prompt, timeoutMs, visibility = 'summary') {
    // ... existing code ...

    // Detect mobile sessions and set environment variable to skip TTS
    const isMobileSession = prompt.includes('"source":"builderos_mobile"') ||
                            prompt.includes('"source": "builderos_mobile"');
    return spawnCLI('claude', args, timeoutMs, visibilityOptions, isMobileSession);
}
```

**Modified `spawnCLI()` to set environment variable:**
```javascript
async function spawnCLI(command, args, timeoutMs, visibility, isMobileSession = false) {
    // ... existing code ...

    // Prepare environment variables
    const env = { ...process.env };
    if (isMobileSession) {
        env.BUILDEROS_MOBILE_SESSION = 'true';
    }

    // Spawn with environment
    const child = spawn(command, args, {
        stdio: ['ignore', 'pipe', 'pipe'],
        shell: false,
        env
    });
    // ...
}
```

## How It Works

1. Mobile backend sends requests with `"source": "builderos_mobile"` in metadata
2. BridgeHub detects this in the request payload when spawning Claude Code
3. BridgeHub sets `BUILDEROS_MOBILE_SESSION=true` environment variable
4. Claude Code spawns with this environment variable
5. TTS hook checks for this variable and exits early if present
6. macOS TTS is skipped for mobile sessions
7. Desktop Claude Code sessions (no environment variable) still get TTS

## Testing

To verify the fix works:
1. Send a message from iOS mobile app (Jarvis or Codex chat)
2. TTS should NOT play on macOS
3. Use desktop Claude Code
4. TTS SHOULD play on macOS

Check logs:
```bash
tail -f ~/.claude/tts_client.log
```

Look for: `Mobile session detected, skipping TTS (playing on iOS)`

## Future Enhancement (Option 3)

Later, we will implement iOS native TTS using AVSpeechSynthesizer so responses play directly on the iPhone instead of just skipping macOS TTS.

## Files Modified
- `~/.claude/simple_tts_hook_fast.py` - Added mobile session detection
- `tools/bridgehub/dist/lib/spawn_cli.js` - Set environment variable for mobile sessions

## Date
2025-10-28 16:53
