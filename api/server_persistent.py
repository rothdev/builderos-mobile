#!/usr/bin/env python3
"""
BuilderOS Mobile API Server (Session-Persistent v2.0)

WebSocket server for persistent Claude and Codex chat sessions with:
- Full conversation history retention
- BridgeHub integration for agent coordination
- Real-time response streaming
- SQLite session persistence
"""

import asyncio
import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Set

from aiohttp import web, WSMsgType

# Import session management and BridgeHub client
sys.path.insert(0, str(Path(__file__).parent))
from session_manager import SessionManager, Session
from bridgehub_client import BridgeHubClient

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# API Configuration
API_PORT = 8080
VALID_API_KEY = "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3"

# Session management
logger.info("🔧 Initializing SessionManager...")
session_manager = SessionManager(db_path="api/sessions.db")

# Active WebSocket connections (for broadcasting)
claude_connections: Set[web.WebSocketResponse] = set()
codex_connections: Set[web.WebSocketResponse] = set()

# Cleanup old sessions on startup
logger.info("🧹 Cleaning up sessions older than 30 days...")
deleted = session_manager.cleanup_old_sessions(days=30)
logger.info(f"✅ Deleted {deleted} old sessions")


async def authenticate_websocket(ws: web.WebSocketResponse) -> bool:
    """
    Authenticate WebSocket connection by expecting API key as first message.
    Returns True if authenticated, False otherwise.
    """
    try:
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


async def handle_claude_session(
    ws: web.WebSocketResponse,
    user_message: str,
    session_id: str,
    device_id: str
):
    """
    Handle message in Claude (Jarvis) session

    Flow:
    1. Load/create session with full history
    2. Add user message to history
    3. Call BridgeHub with context
    4. Stream response chunks back to iOS
    5. Save complete response to history
    6. Persist session to database
    """

    logger.info(f"📬 Processing Claude message (session: {session_id})")
    logger.debug(f"   Message: {user_message[:60]}...")

    # Get or create session
    session = session_manager.get_or_create_session(
        session_id=session_id,
        agent_type="claude",
        device_id=device_id
    )

    logger.info(f"📚 Session has {len(session.messages)} messages in history")

    # Add user message to history
    session.add_message(role="user", content=user_message)

    # Get conversation history for context
    conversation_history = session.get_conversation_history(max_messages=50)

    # Call BridgeHub and stream response
    full_response = ""
    chunk_count = 0

    try:
        async for chunk in BridgeHubClient.call_jarvis(
            message=user_message,
            session_id=session_id,
            conversation_history=conversation_history,
            system_context=session.system_context
        ):
            # Stream chunk to iOS
            chunk_msg = {
                "type": "message",
                "content": chunk,
                "timestamp": datetime.now().isoformat()
            }
            await ws.send_json(chunk_msg)

            # Accumulate for session history
            full_response += chunk
            chunk_count += 1

            # Small delay to simulate streaming
            await asyncio.sleep(0.05)

        logger.info(f"✅ Streamed {chunk_count} chunks to client")

    except Exception as e:
        logger.error(f"❌ Error during BridgeHub call: {e}", exc_info=True)

        # Only send error if WebSocket is still open
        if not ws.closed:
            error_msg = {
                "type": "error",
                "content": f"Error: {str(e)}",
                "timestamp": datetime.now().isoformat()
            }
            try:
                await ws.send_json(error_msg)
            except Exception as send_error:
                logger.error(f"❌ Failed to send error message: {send_error}")
        return

    # Add assistant response to history
    session.add_message(role="assistant", content=full_response)

    # Persist session to database
    session_manager.persist_session(session)

    # Send completion message
    complete_msg = {
        "type": "complete",
        "content": "Response complete",
        "timestamp": datetime.now().isoformat(),
        "message_count": len(session.messages)
    }
    await ws.send_json(complete_msg)

    logger.info(f"💾 Session persisted ({len(session.messages)} messages total)")


async def handle_codex_session(
    ws: web.WebSocketResponse,
    user_message: str,
    session_id: str,
    device_id: str
):
    """
    Handle message in Codex session

    Flow:
    1. Load/create session with full history
    2. Add user message to history
    3. Call BridgeHub with context
    4. Stream response chunks back to iOS
    5. Save complete response to history
    6. Persist session to database
    """

    logger.info(f"📬 Processing Codex message (session: {session_id})")
    logger.debug(f"   Message: {user_message[:60]}...")

    # Get or create session
    session = session_manager.get_or_create_session(
        session_id=session_id,
        agent_type="codex",
        device_id=device_id
    )

    logger.info(f"📚 Session has {len(session.messages)} messages in history")

    # Add user message to history
    session.add_message(role="user", content=user_message)

    # Get conversation history
    conversation_history = session.get_conversation_history(max_messages=50)

    # Call BridgeHub and stream response
    full_response = ""
    chunk_count = 0

    try:
        async for chunk in BridgeHubClient.call_codex(
            message=user_message,
            session_id=session_id,
            conversation_history=conversation_history
        ):
            # Check if WebSocket is still open before sending
            if ws.closed:
                logger.warning("⚠️ WebSocket closed during Codex response streaming")
                break

            # Stream chunk to iOS
            chunk_msg = {
                "type": "message",
                "content": chunk,
                "timestamp": datetime.now().isoformat()
            }

            try:
                await ws.send_json(chunk_msg)
            except Exception as send_error:
                logger.error(f"❌ Failed to send chunk: {send_error}")
                break

            full_response += chunk
            chunk_count += 1
            await asyncio.sleep(0.05)

        logger.info(f"✅ Streamed {chunk_count} chunks to client")

    except Exception as e:
        logger.error(f"❌ Error during BridgeHub call: {e}", exc_info=True)

        # Only send error if WebSocket is still open
        if not ws.closed:
            error_msg = {
                "type": "error",
                "content": f"Error: {str(e)}",
                "timestamp": datetime.now().isoformat()
            }
            try:
                await ws.send_json(error_msg)
            except Exception as send_error:
                logger.error(f"❌ Failed to send error message: {send_error}")
        return

    # Add assistant response to history
    session.add_message(role="assistant", content=full_response)

    # Persist session
    session_manager.persist_session(session)

    # Send completion
    complete_msg = {
        "type": "complete",
        "content": "Response complete",
        "timestamp": datetime.now().isoformat(),
        "message_count": len(session.messages)
    }
    await ws.send_json(complete_msg)

    logger.info(f"💾 Session persisted ({len(session.messages)} messages total)")


async def claude_websocket_handler(request):
    """
    WebSocket endpoint for Claude Agent (Jarvis) chat
    """
    ws = web.WebSocketResponse(heartbeat=30.0, receive_timeout=600.0)
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
        "content": "Claude Agent connected (session-persistent v2.0)",
        "timestamp": datetime.now().isoformat(),
        "features": {
            "session_persistence": True,
            "bridgehub_integration": True,
            "agent_coordination": True
        }
    }
    await ws.send_json(ready_msg)

    try:
        async for msg in ws:
            if msg.type == WSMsgType.TEXT:
                try:
                    # Parse incoming message
                    data = json.loads(msg.data)
                    user_message = data.get("content", "")
                    session_id = data.get("session_id", "default-claude-session")
                    device_id = data.get("device_id", "unknown-device")

                    if not user_message:
                        logger.warning("⚠️ Empty message received")
                        continue

                    logger.info(f"📬 Claude received: {user_message[:60]}... (session: {session_id})")

                    # Handle message in session
                    await handle_claude_session(
                        ws=ws,
                        user_message=user_message,
                        session_id=session_id,
                        device_id=device_id
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
                    logger.error(f"❌ Error processing message: {e}", exc_info=True)
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
    WebSocket endpoint for Codex Agent chat
    """
    ws = web.WebSocketResponse(heartbeat=30.0, receive_timeout=600.0)
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
        "content": "Codex Agent connected (session-persistent v2.0)",
        "timestamp": datetime.now().isoformat(),
        "features": {
            "session_persistence": True,
            "bridgehub_integration": True,
            "independent_context": True
        }
    }
    await ws.send_json(ready_msg)

    try:
        async for msg in ws:
            if msg.type == WSMsgType.TEXT:
                try:
                    # Parse incoming message
                    data = json.loads(msg.data)
                    user_message = data.get("content", "")
                    session_id = data.get("session_id", "default-codex-session")
                    device_id = data.get("device_id", "unknown-device")

                    if not user_message:
                        logger.warning("⚠️ Empty message received")
                        continue

                    logger.info(f"📬 Codex received: {user_message[:60]}... (session: {session_id})")

                    # Handle message in session
                    await handle_codex_session(
                        ws=ws,
                        user_message=user_message,
                        session_id=session_id,
                        device_id=device_id
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
                    logger.error(f"❌ Error processing message: {e}", exc_info=True)
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
    """Health check endpoint with session statistics"""

    # Get BridgeHub health
    bridgehub_health = await BridgeHubClient.health_check()

    # Get session stats
    session_stats = session_manager.get_session_stats()

    return web.json_response({
        "status": "ok",
        "version": "2.0.0-persistent",
        "timestamp": datetime.now().isoformat(),
        "connections": {
            "claude": len(claude_connections),
            "codex": len(codex_connections)
        },
        "sessions": session_stats,
        "bridgehub": bridgehub_health
    })


async def status_endpoint(request):
    """System status endpoint"""
    return web.json_response({
        "status": "running",
        "version": "2.0.0-persistent",
        "health": "ok",
        "timestamp": datetime.now().isoformat(),
        "features": {
            "session_persistence": True,
            "bridgehub_integration": True,
            "agent_coordination": True,
            "multi_turn_conversations": True,
            "dual_sessions": True
        }
    })


async def sessions_endpoint(request):
    """List active sessions (for debugging)"""
    sessions_list = [
        {
            "session_id": session.session_id,
            "agent_type": session.agent_type,
            "device_id": session.device_id,
            "message_count": len(session.messages),
            "created_at": session.created_at.isoformat(),
            "last_activity": session.last_activity.isoformat()
        }
        for session in session_manager.sessions.values()
    ]

    return web.json_response({
        "total": len(sessions_list),
        "sessions": sessions_list
    })


def create_app():
    """Create and configure aiohttp application"""
    app = web.Application()

    # Add routes
    app.router.add_get('/api/health', health_check)
    app.router.add_get('/api/status', status_endpoint)
    app.router.add_get('/api/sessions', sessions_endpoint)
    app.router.add_get('/api/claude/ws', claude_websocket_handler)
    app.router.add_get('/api/codex/ws', codex_websocket_handler)

    return app


def main():
    """Start the API server"""
    logger.info("=" * 60)
    logger.info("🚀 BuilderOS Mobile API Server v2.0 (Session-Persistent)")
    logger.info("=" * 60)
    logger.info(f"📡 Listening on http://localhost:{API_PORT}")
    logger.info(f"🔌 WebSocket endpoints:")
    logger.info(f"   - ws://localhost:{API_PORT}/api/claude/ws (Jarvis)")
    logger.info(f"   - ws://localhost:{API_PORT}/api/codex/ws (Codex)")
    logger.info(f"💾 Session database: {session_manager.db_path}")
    logger.info(f"📚 Active sessions: {len(session_manager.sessions)}")
    logger.info("=" * 60)

    app = create_app()
    web.run_app(app, host='0.0.0.0', port=API_PORT)


if __name__ == '__main__':
    main()
