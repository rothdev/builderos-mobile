#!/usr/bin/env python3
"""
BuilderOS Mobile API Server
WebSocket server for Claude and Codex chat agents
"""

import asyncio
import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Set

import anthropic
from aiohttp import web
from aiohttp import WSMsgType

# BridgeHub integration
from bridgehub_client import BridgeHubClient

# APNs imports
try:
    from aioapns import APNs, NotificationRequest
    APNS_AVAILABLE = True
except ImportError:
    APNS_AVAILABLE = False
    logging.warning("⚠️ aioapns not installed - push notifications will be logged only")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# API Configuration
API_PORT = 8080
VALID_API_KEY = "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3"

# APNs Configuration
APNS_CERT_PATH = Path(__file__).parent / "certs" / "apns_combined.pem"
APNS_USE_SANDBOX = os.getenv("APNS_USE_SANDBOX", "true").lower() == "true"
APNS_BUNDLE_ID = "com.builderos.ios"

# Initialize APNs client
apns_client = None
if APNS_AVAILABLE and APNS_CERT_PATH.exists():
    try:
        apns_client = APNs(
            client_cert=str(APNS_CERT_PATH),
            use_sandbox=APNS_USE_SANDBOX,
            topic=APNS_BUNDLE_ID
        )
        logger.info(f"✅ APNs client initialized (sandbox={APNS_USE_SANDBOX})")
    except Exception as e:
        logger.error(f"❌ Failed to initialize APNs client: {e}")
else:
    if not APNS_CERT_PATH.exists():
        logger.warning(f"⚠️ APNs certificate not found at {APNS_CERT_PATH}")

# Active WebSocket connections
claude_connections: Set[web.WebSocketResponse] = set()
codex_connections: Set[web.WebSocketResponse] = set()

# Device tokens for push notifications
# Format: { "device_id": { "token": "...", "platform": "ios", "registered_at": "..." } }
device_tokens: Dict[str, Dict] = {}

# Initialize Anthropic client
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
anthropic_client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)


def build_system_prompt(working_directory: str = "/Users/Ty/BuilderOS") -> str:
    """
    Build system prompt with Jarvis identity and BuilderOS context.
    This gives Claude proper identity and environmental awareness.
    """
    return f"""# Builder System – Jarvis Activation

## STARTUP PROTOCOL
Builder OS session activation confirmed.

## Jarvis Identity
You are **Jarvis**, Ty's Number-2, second-in-command and chief of staff for the Builder System. You are his intelligent top agent - persistent, learning, and evolving over years. You serve as the intelligent layer between Ty and all other specialist agents.

## Current Environment
- **Working Directory:** {working_directory}
- **Platform:** macOS (Darwin)
- **System:** BuilderOS - The one thing that builds all other things
- **Interface:** Mobile app (iOS)

## Response Formation: Autonomous Execution Principle

**CRITICAL: Don't ask Ty to do what Jarvis or agents can do.**

### The Core Problem
Jarvis exists to reduce Ty's execution burden. Asking Ty to perform mechanical tasks defeats this purpose.

**DO ask Ty for decisions and approvals:**
- ✅ "Want me to implement X?" - Checking strategic direction
- ✅ "Should we use approach A or B?" - Genuine decision needed
- ✅ "This costs $X/month, proceed?" - Spend approval required
- ✅ "This is a breaking change, confirm?" - Risk gate

**DO NOT ask Ty to perform mechanical work:**
- ❌ "Once you test this, let me know if it works"
- ❌ "Can you check what's on the screen?"
- ❌ "Run this command and tell me the output"

**The goal:** Ty decides WHAT to build. Jarvis and agents figure out HOW and verify it works.

## System Purpose
The Builder System is **the one thing that builds all other things** for Ty - whether workflow automations, apps, or business systems. It moves ideas from *ideation → design → build → deploy* efficiently.

**Core Goal:** Build everything Ty needs, when he needs it.

## Mobile Context
You are responding via BuilderOS mobile app. Keep responses concise but informative. You have full BuilderOS capabilities available through the backend APIs."""


async def authenticate_websocket(ws: web.WebSocketResponse) -> bool:
    """
    Authenticate WebSocket connection by expecting API key as first message.
    Returns True if authenticated, False otherwise.
    """
    try:
        # Wait for first message (should be API key)
        msg = await asyncio.wait_for(ws.receive(), timeout=10.0)

        if msg.type == WSMsgType.TEXT:
            received_key = msg.data.strip()
            if received_key == VALID_API_KEY:
                logger.info("✅ WebSocket authenticated")
                await ws.send_str("authenticated")
                return True
            else:
                logger.warning(f"❌ Invalid API key: {received_key[:8]}...")
                await ws.send_str("error:invalid_api_key")
                return False
        else:
            logger.warning("❌ First message was not text")
            return False

    except asyncio.TimeoutError:
        logger.warning("❌ Authentication timeout")
        return False
    except Exception as e:
        logger.error(f"❌ Authentication error: {e}")
        return False


async def handle_claude_message(content: str, working_directory: str = "/Users/Ty/BuilderOS"):
    """
    Send message to Claude API with full Jarvis identity and BuilderOS context.
    Yields streaming response chunks as they arrive.
    """
    try:
        # Build system prompt with Jarvis identity and context
        system_prompt = build_system_prompt(working_directory)

        # Create message with streaming
        response = anthropic_client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=4096,
            system=system_prompt,  # ← ADD SYSTEM PROMPT
            messages=[
                {"role": "user", "content": content}
            ],
            stream=True
        )

        # Stream response chunks as they arrive
        for chunk in response:
            if hasattr(chunk, 'delta') and hasattr(chunk.delta, 'text'):
                yield chunk.delta.text

    except Exception as e:
        logger.error(f"❌ Claude API error: {e}")
        raise


async def handle_codex_message(content: str, session_id: str, conversation_history: list):
    """
    Send message to Codex via BridgeHub.
    Yields response chunks as they arrive from Codex CLI.
    """
    logger.info(f"📬 Sending to Codex via BridgeHub: {content[:60]}...")

    async for chunk in BridgeHubClient.call_codex(
        message=content,
        session_id=session_id,
        conversation_history=conversation_history
    ):
        yield chunk


async def claude_websocket_handler(request):
    """
    WebSocket endpoint for Claude Agent chat with BuilderOS context.

    Protocol:
    1. Client sends API key as first message
    2. Server responds "authenticated" on success
    3. Client optionally sends session config: {"working_directory": "/path/to/dir"}
    4. Client sends messages as JSON: {"content": "user message text"}
    5. Server streams responses with full Jarvis identity and BuilderOS context
    """
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    logger.info("🔵 Claude WebSocket connection established")

    # Authenticate
    if not await authenticate_websocket(ws):
        await ws.close()
        return ws

    # Add to active connections
    claude_connections.add(ws)

    # Default working directory (can be overridden by session config)
    working_directory = "/Users/Ty/BuilderOS"

    # Session config is optional - mobile app can send working_directory
    # For now, we just use the default. In the future, the mobile app can send:
    # {"working_directory": "/Users/Ty/BuilderOS/capsules/some-capsule"}
    # as the first message after authentication

    logger.info(f"📁 Working directory: {working_directory}")

    # Send ready message with Jarvis identity
    ready_msg = {
        "type": "ready",
        "content": "Jarvis activated. BuilderOS mobile interface ready.",
        "timestamp": datetime.now().isoformat(),
        "identity": "Jarvis",
        "working_directory": working_directory,
        "system": "BuilderOS"
    }
    await ws.send_json(ready_msg)

    try:
        async for msg in ws:
            if msg.type == WSMsgType.TEXT:
                try:
                    # Parse incoming message
                    data = json.loads(msg.data)
                    user_message = data.get("content", "")

                    if not user_message:
                        continue

                    logger.info(f"📬 Claude received: {user_message[:60]}...")

                    # Stream Claude response chunks with Jarvis identity and BuilderOS context
                    full_response = ""
                    async for chunk in handle_claude_message(user_message, working_directory):
                        full_response += chunk
                        chunk_msg = {
                            "type": "message",
                            "content": chunk,
                            "timestamp": datetime.now().isoformat()
                        }
                        await ws.send_json(chunk_msg)

                    # Send completion message
                    complete_msg = {
                        "type": "complete",
                        "content": "Response complete",
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(complete_msg)

                    # Send push notifications to all registered devices
                    # (they can filter if WebSocket is already active)
                    preview = full_response[:100] + "..." if len(full_response) > 100 else full_response
                    for device_id in device_tokens.keys():
                        await send_push_notification(
                            device_id=device_id,
                            title="New message from Claude",
                            body=preview,
                            data={
                                "type": "new_message",
                                "sender": "Claude",
                                "preview": preview
                            }
                        )

                except json.JSONDecodeError:
                    logger.warning("⚠️ Invalid JSON received")
                    error_msg = {
                        "type": "error",
                        "content": "Invalid message format",
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(error_msg)

                except Exception as e:
                    logger.error(f"❌ Error processing message: {e}")
                    error_msg = {
                        "type": "error",
                        "content": str(e),
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(error_msg)

            elif msg.type == WSMsgType.ERROR:
                logger.error(f"❌ WebSocket error: {ws.exception()}")

    finally:
        claude_connections.discard(ws)
        logger.info("👋 Claude WebSocket disconnected")

    return ws


async def codex_websocket_handler(request):
    """
    WebSocket endpoint for Codex Agent chat via BridgeHub.
    """
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    logger.info("🔵 Codex WebSocket connection established")

    # Authenticate
    if not await authenticate_websocket(ws):
        await ws.close()
        return ws

    # Add to active connections
    codex_connections.add(ws)

    # Generate session ID for this connection
    import uuid
    session_id = str(uuid.uuid4())
    conversation_history = []

    # Send ready message
    ready_msg = {
        "type": "ready",
        "content": "Codex Agent connected via BridgeHub",
        "timestamp": datetime.now().isoformat()
    }
    await ws.send_json(ready_msg)

    try:
        async for msg in ws:
            if msg.type == WSMsgType.TEXT:
                try:
                    # Parse incoming message
                    data = json.loads(msg.data)
                    user_message = data.get("content", "")

                    if not user_message:
                        continue

                    logger.info(f"📬 Codex received: {user_message[:60]}...")

                    # Add to conversation history
                    conversation_history.append({
                        "role": "user",
                        "content": user_message
                    })

                    # Stream Codex response from BridgeHub
                    full_response = ""
                    async for chunk in handle_codex_message(user_message, session_id, conversation_history):
                        full_response += chunk

                        # Send chunk
                        chunk_msg = {
                            "type": "message",
                            "content": chunk,
                            "timestamp": datetime.now().isoformat()
                        }
                        await ws.send_json(chunk_msg)

                    # Add response to history
                    conversation_history.append({
                        "role": "assistant",
                        "content": full_response
                    })

                    # Send completion
                    complete_msg = {
                        "type": "complete",
                        "content": "Response complete",
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(complete_msg)

                    # Send push notifications to all registered devices
                    preview = full_response[:100] + "..." if len(full_response) > 100 else full_response
                    for device_id in device_tokens.keys():
                        await send_push_notification(
                            device_id=device_id,
                            title="New message from Codex",
                            body=preview,
                            data={
                                "type": "new_message",
                                "sender": "Codex",
                                "preview": preview
                            }
                        )

                except json.JSONDecodeError:
                    logger.warning("⚠️ Invalid JSON received")
                    error_msg = {
                        "type": "error",
                        "content": "Invalid message format",
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(error_msg)

                except Exception as e:
                    logger.error(f"❌ Error processing Codex message: {e}")
                    error_msg = {
                        "type": "error",
                        "content": str(e),
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(error_msg)

            elif msg.type == WSMsgType.ERROR:
                logger.error(f"❌ WebSocket error: {ws.exception()}")

    finally:
        codex_connections.discard(ws)
        logger.info("👋 Codex WebSocket disconnected")

    return ws


async def health_check(request):
    """Health check endpoint"""
    return web.json_response({
        "status": "ok",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "connections": {
            "claude": len(claude_connections),
            "codex": len(codex_connections)
        }
    })


async def status_endpoint(request):
    """System status endpoint"""
    return web.json_response({
        "status": "running",
        "version": "1.0.0",
        "uptime": 0,  # TODO: Track actual uptime
        "health": "ok",
        "timestamp": datetime.now().isoformat()
    })


async def upload_file_endpoint(request):
    """Handle file uploads from mobile app"""
    try:
        # Authenticate request
        api_key = request.headers.get('X-API-Key')
        if not api_key or api_key != VALID_API_KEY:
            logger.warning("❌ Unauthorized upload attempt")
            return web.json_response({
                "error": "Unauthorized"
            }, status=401)

        # Parse multipart form data
        reader = await request.multipart()

        file_data = None
        filename = None
        file_type = None

        async for field in reader:
            if field.name == 'file':
                filename = field.filename
                file_data = await field.read()
            elif field.name == 'type':
                file_type = await field.text()

        if not file_data or not filename:
            logger.error("❌ Missing file data or filename")
            return web.json_response({
                "error": "Missing file data"
            }, status=400)

        # Create uploads directory if it doesn't exist
        uploads_dir = Path(__file__).parent / "uploads"
        uploads_dir.mkdir(exist_ok=True)

        # Generate unique filename to avoid collisions
        import uuid
        unique_id = uuid.uuid4().hex[:16]
        safe_filename = f"{unique_id}_{filename}"
        file_path = uploads_dir / safe_filename

        # Write file to disk
        with open(file_path, 'wb') as f:
            f.write(file_data)

        file_size = len(file_data)

        # Generate URL for the uploaded file
        file_url = f"/api/files/{safe_filename}"

        logger.info(f"✅ Uploaded file: {filename} ({file_size} bytes) -> {safe_filename}")

        return web.json_response({
            "url": file_url,
            "filename": filename,
            "size": file_size
        })

    except Exception as e:
        logger.error(f"❌ Upload error: {e}")
        return web.json_response({
            "error": str(e)
        }, status=500)


async def get_uploaded_file(request):
    """Serve uploaded files"""
    try:
        filename = request.match_info['filename']
        uploads_dir = Path(__file__).parent / "uploads"
        file_path = uploads_dir / filename

        if not file_path.exists():
            return web.json_response({
                "error": "File not found"
            }, status=404)

        return web.FileResponse(file_path)

    except Exception as e:
        logger.error(f"❌ File retrieval error: {e}")
        return web.json_response({
            "error": str(e)
        }, status=500)


# ==================== PUSH NOTIFICATION HANDLERS ====================

async def register_device_token(request):
    """
    Register device token for push notifications
    POST /api/notifications/register
    Body: { "device_token": "...", "platform": "ios", "device_id": "..." }
    """
    try:
        # Authenticate request
        api_key = request.headers.get('X-API-Key')
        if api_key != VALID_API_KEY:
            return web.json_response({
                "error": "Invalid API key"
            }, status=401)

        # Parse request body
        data = await request.json()
        device_token = data.get('device_token')
        platform = data.get('platform', 'ios')
        device_id = data.get('device_id')

        if not device_token or not device_id:
            return web.json_response({
                "error": "Missing device_token or device_id"
            }, status=400)

        # Store device token
        device_tokens[device_id] = {
            "token": device_token,
            "platform": platform,
            "registered_at": datetime.now().isoformat()
        }

        logger.info(f"✅ Registered device token for {device_id} ({platform})")
        logger.info(f"   Total registered devices: {len(device_tokens)}")

        return web.json_response({
            "success": True,
            "message": "Device token registered successfully"
        })

    except Exception as e:
        logger.error(f"❌ Device registration error: {e}")
        return web.json_response({
            "error": str(e)
        }, status=500)


async def send_push_notification(device_id: str, title: str, body: str, data: dict = None):
    """
    Send push notification to a specific device via APNs
    """
    device_info = device_tokens.get(device_id)

    if not device_info:
        logger.warning(f"⚠️ No device token found for device_id: {device_id}")
        return False

    token_hex = device_info['token']

    logger.info(f"📱 PUSH NOTIFICATION to {device_id}:")
    logger.info(f"   Title: {title}")
    logger.info(f"   Body: {body}")
    logger.info(f"   Token: {token_hex[:16]}...")
    if data:
        logger.info(f"   Data: {data}")

    # Send via APNs if available
    if apns_client:
        try:
            # Create notification request
            request = NotificationRequest(
                device_token=token_hex,
                message={
                    "aps": {
                        "alert": {
                            "title": title,
                            "body": body
                        },
                        "badge": 1,
                        "sound": "default"
                    },
                    **(data or {})
                }
            )

            # Send notification
            await apns_client.send_notification(request)
            logger.info(f"✅ Push notification sent successfully via APNs")
            return True

        except Exception as e:
            logger.error(f"❌ Failed to send push notification: {e}")
            return False
    else:
        logger.warning("⚠️ APNs client not available - notification logged only")
        return False


def create_app():
    """Create and configure aiohttp application"""
    app = web.Application()

    # Add routes
    app.router.add_get('/api/health', health_check)
    app.router.add_get('/api/status', status_endpoint)
    app.router.add_get('/api/claude/ws', claude_websocket_handler)
    app.router.add_get('/api/codex/ws', codex_websocket_handler)
    app.router.add_post('/api/files/upload', upload_file_endpoint)
    app.router.add_get('/api/files/{filename}', get_uploaded_file)
    app.router.add_post('/api/notifications/register', register_device_token)

    return app


def main():
    """Start the API server"""
    logger.info("🚀 Starting BuilderOS Mobile API Server")
    logger.info(f"📡 Listening on http://localhost:{API_PORT}")
    logger.info(f"🔌 WebSocket endpoints:")
    logger.info(f"   - ws://localhost:{API_PORT}/api/claude/ws")
    logger.info(f"   - ws://localhost:{API_PORT}/api/codex/ws")
    logger.info(f"📁 File upload endpoints:")
    logger.info(f"   - POST http://localhost:{API_PORT}/api/files/upload")
    logger.info(f"   - GET http://localhost:{API_PORT}/api/files/{{filename}}")

    app = create_app()
    web.run_app(app, host='0.0.0.0', port=API_PORT)


if __name__ == '__main__':
    main()
