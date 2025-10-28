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

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# API Configuration
API_PORT = 8080
VALID_API_KEY = "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3"

# Active WebSocket connections
claude_connections: Set[web.WebSocketResponse] = set()
codex_connections: Set[web.WebSocketResponse] = set()

# Initialize Anthropic client
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
if not ANTHROPIC_API_KEY:
    logger.error("❌ ANTHROPIC_API_KEY not found in environment")
    sys.exit(1)

anthropic_client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)


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


async def handle_claude_message(content: str) -> str:
    """
    Send message to Claude API and return streaming response.
    """
    try:
        # Create message with streaming
        response = anthropic_client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=4096,
            messages=[
                {"role": "user", "content": content}
            ],
            stream=True
        )

        # Collect full response
        full_response = ""
        for chunk in response:
            if hasattr(chunk, 'delta') and hasattr(chunk.delta, 'text'):
                full_response += chunk.delta.text

        return full_response

    except Exception as e:
        logger.error(f"❌ Claude API error: {e}")
        raise


async def handle_codex_message(content: str) -> str:
    """
    Send message to Codex (placeholder - needs BridgeHub integration).
    """
    # TODO: Integrate with BridgeHub CLI for Codex communication
    return f"Codex response placeholder for: {content}"


async def claude_websocket_handler(request):
    """
    WebSocket endpoint for Claude Agent chat.
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

    # Send ready message
    ready_msg = {
        "type": "ready",
        "content": "Claude Agent connected",
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

                    logger.info(f"📬 Claude received: {user_message[:60]}...")

                    # Get Claude response (streaming)
                    response_text = await handle_claude_message(user_message)

                    # Send response in chunks
                    chunk_size = 100
                    for i in range(0, len(response_text), chunk_size):
                        chunk = response_text[i:i+chunk_size]
                        chunk_msg = {
                            "type": "message",
                            "content": chunk,
                            "timestamp": datetime.now().isoformat()
                        }
                        await ws.send_json(chunk_msg)
                        await asyncio.sleep(0.05)  # Simulate streaming

                    # Send completion message
                    complete_msg = {
                        "type": "complete",
                        "content": "Response complete",
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(complete_msg)

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
    WebSocket endpoint for Codex Agent chat.
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

    # Send ready message
    ready_msg = {
        "type": "ready",
        "content": "Codex Agent connected",
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

                    # Get Codex response
                    response_text = await handle_codex_message(user_message)

                    # Send response
                    response_msg = {
                        "type": "message",
                        "content": response_text,
                        "timestamp": datetime.now().isoformat()
                    }
                    await ws.send_json(response_msg)

                    # Send completion
                    complete_msg = {
                        "type": "complete",
                        "content": "Response complete",
                        "timestamp": datetime.now().isoformat(),
                        "usage": {
                            "input_tokens": None,
                            "cached_input_tokens": None,
                            "output_tokens": None
                        }
                    }
                    await ws.send_json(complete_msg)

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


def create_app():
    """Create and configure aiohttp application"""
    app = web.Application()

    # Add routes
    app.router.add_get('/api/health', health_check)
    app.router.add_get('/api/status', status_endpoint)
    app.router.add_get('/api/claude/ws', claude_websocket_handler)
    app.router.add_get('/api/codex/ws', codex_websocket_handler)

    return app


def main():
    """Start the API server"""
    logger.info("🚀 Starting BuilderOS Mobile API Server")
    logger.info(f"📡 Listening on http://localhost:{API_PORT}")
    logger.info(f"🔌 WebSocket endpoints:")
    logger.info(f"   - ws://localhost:{API_PORT}/api/claude/ws")
    logger.info(f"   - ws://localhost:{API_PORT}/api/codex/ws")

    app = create_app()
    web.run_app(app, host='0.0.0.0', port=API_PORT)


if __name__ == '__main__':
    main()
