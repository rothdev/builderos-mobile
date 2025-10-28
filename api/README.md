# BuilderOS Mobile API Server

WebSocket-based API server for BuilderOS Mobile iOS app, providing real-time chat with Claude and Codex agents.

## Features

- **WebSocket Support**: Real-time bidirectional communication
- **Claude Integration**: Direct connection to Claude API with streaming responses
- **Codex Integration**: Placeholder for BridgeHub integration
- **Authentication**: Bearer token authentication for security
- **Health Checks**: Status and health endpoints for monitoring

## Quick Start

### 1. Setup

```bash
./setup.sh
```

This will:
- Create a Python virtual environment
- Install required dependencies (aiohttp, anthropic)
- Check for ANTHROPIC_API_KEY

### 2. Configure API Key

You need an Anthropic API key. Set it in your environment:

```bash
# Add to ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-api03-..."

# Or set for current session
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

### 3. Start Server

```bash
./start.sh
```

Server starts on `http://localhost:8080`

## API Endpoints

### HTTP Endpoints

#### Health Check
```
GET /api/health
```

Response:
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2025-10-26T10:30:00",
  "connections": {
    "claude": 2,
    "codex": 0
  }
}
```

#### System Status
```
GET /api/status
```

Response:
```json
{
  "status": "running",
  "version": "1.0.0",
  "uptime": 3600,
  "health": "ok",
  "timestamp": "2025-10-26T10:30:00"
}
```

### WebSocket Endpoints

#### Claude Agent
```
WS ws://localhost:8080/api/claude/ws
```

**Protocol:**

1. **Connect** - WebSocket handshake
2. **Authenticate** - Send API key as first message:
   ```
   1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3
   ```
3. **Receive** - Server responds with:
   ```json
   "authenticated"
   ```
4. **Ready** - Server sends ready message:
   ```json
   {
     "type": "ready",
     "content": "Claude Agent connected",
     "timestamp": "2025-10-26T10:30:00"
   }
   ```
5. **Send Message** - Client sends:
   ```json
   {
     "content": "What's the status of BuilderOS?"
   }
   ```
6. **Receive Response** - Server streams back:
   ```json
   {
     "type": "message",
     "content": "BuilderOS is running...",
     "timestamp": "2025-10-26T10:30:00"
   }
   ```
   (Multiple messages as response streams)
7. **Complete** - Server sends:
   ```json
   {
     "type": "complete",
     "content": "Response complete",
     "timestamp": "2025-10-26T10:30:00"
   }
   ```

#### Codex Agent
```
WS ws://localhost:8080/api/codex/ws
```

Same protocol as Claude, but connects to Codex CLI via BridgeHub (placeholder implementation).

## Testing WebSocket Connection

### Using wscat

```bash
# Install wscat
npm install -g wscat

# Connect to Claude
wscat -c ws://localhost:8080/api/claude/ws

# After connection, send API key:
> 1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3

# You'll receive:
< authenticated
< {"type":"ready","content":"Claude Agent connected","timestamp":"..."}

# Send a message:
> {"content":"Hello Claude!"}

# Receive streaming response:
< {"type":"message","content":"Hello!","timestamp":"..."}
< {"type":"message","content":" How can","timestamp":"..."}
< {"type":"message","content":" I help you","timestamp":"..."}
< {"type":"complete","content":"Response complete","timestamp":"..."}
```

### Using Python

```python
import asyncio
import websockets
import json

async def test_claude():
    uri = "ws://localhost:8080/api/claude/ws"
    async with websockets.connect(uri) as ws:
        # Authenticate
        await ws.send("1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3")
        auth = await ws.recv()
        print(f"Auth: {auth}")

        # Receive ready message
        ready = await ws.recv()
        print(f"Ready: {ready}")

        # Send message
        message = {"content": "Hello Claude!"}
        await ws.send(json.dumps(message))

        # Receive responses
        while True:
            response = await ws.recv()
            data = json.loads(response)
            print(f"Type: {data['type']}, Content: {data['content']}")

            if data['type'] == 'complete':
                break

asyncio.run(test_claude())
```

## Architecture

```
┌─────────────────┐
│   iOS App       │
│  (SwiftUI)      │
└────────┬────────┘
         │ WebSocket (Starscream)
         │
         ▼
┌─────────────────────────────────────┐
│  API Server (Python/aiohttp)        │
│                                     │
│  ┌─────────────┐  ┌──────────────┐ │
│  │   Claude    │  │    Codex     │ │
│  │  Endpoint   │  │   Endpoint   │ │
│  └──────┬──────┘  └───────┬──────┘ │
│         │                 │        │
│         ▼                 ▼        │
│  ┌─────────────┐  ┌──────────────┐ │
│  │  Anthropic  │  │  BridgeHub   │ │
│  │     API     │  │     CLI      │ │
│  └─────────────┘  └──────────────┘ │
└─────────────────────────────────────┘
```

## Troubleshooting

### Server won't start

**Problem:** `ANTHROPIC_API_KEY not set`

**Solution:** Export your API key:
```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
./start.sh
```

### Connection refused from iOS app

**Problem:** iOS app shows "Disconnected" status

**Solution:**
1. Check server is running: `curl http://localhost:8080/api/health`
2. If testing on device, update `APIConfig.swift` to use Mac's local IP:
   ```swift
   static var tunnelURL = "http://192.168.1.X:8080"
   ```
3. For production, use Cloudflare Tunnel: `https://api.builderos.app`

### WebSocket closes immediately

**Problem:** WebSocket connects but closes right away

**Solution:**
1. Check authentication: Send API key as first message
2. Verify API key matches: `1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3`
3. Check server logs for authentication errors

## Development

### Project Structure

```
api/
├── server.py          # Main server implementation
├── requirements.txt   # Python dependencies
├── setup.sh          # One-time setup script
├── start.sh          # Server startup script
└── README.md         # This file
```

### Dependencies

- **aiohttp** (3.10.11) - Async HTTP server with WebSocket support
- **anthropic** (0.42.0) - Official Anthropic Python SDK

### Future Improvements

- [ ] Integrate Codex with BridgeHub CLI
- [ ] Add message history persistence
- [ ] Add rate limiting
- [ ] Add logging rotation
- [ ] Add prometheus metrics
- [ ] Add Docker support
- [ ] Add systemd service file for auto-start

## Security Notes

- API key authentication required for all WebSocket connections
- Currently supports single API key (hardcoded)
- Production deployment should use environment variables or secrets manager
- Consider adding TLS/SSL for production (handled by Cloudflare Tunnel)

## License

Part of BuilderOS - Ty's personal system
