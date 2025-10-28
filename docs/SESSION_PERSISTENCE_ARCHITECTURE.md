# BuilderOS Mobile Session Persistence Architecture

**Version:** 1.0
**Date:** 2025-10-27
**Status:** Design Complete

---

## Executive Summary

This document defines the complete architecture for transforming BuilderOS Mobile from a stateless message relay to a session-persistent backend that maintains TWO simultaneous chat sessions:

1. **Claude Code Session (Jarvis)** - Persistent Claude Code with CLAUDE.md, MCP memory, and agent coordination
2. **Codex Session** - Persistent Codex session with independent conversation thread

Both sessions retain full conversation history, support agent execution, and stream responses to the iOS app in real-time.

---

## Current State Analysis

### Critical Problems

**1. Stateless Architecture**
- `api/server.py` processes each message independently
- Zero conversation history on server
- Each WebSocket message creates isolated exchange
- Context completely lost between messages

**2. No Session Management**
- No session IDs
- No conversation store
- No way to retrieve previous messages
- Each connection starts fresh

**3. Agent Delegations Inert**
- iOS parser detects agent emoji (📱, 🎨, 🏛️)
- Displays delegation text to user
- Never triggers actual agent execution
- No results returned to mobile

**4. Disconnected from BridgeHub**
- BridgeHub relay exists (`tools/bridgehub/`) with full session management
- Mobile API server never calls it
- Missing agent coordination layer
- No integration with Jarvis/Codex infrastructure

**5. No Context Propagation**
- CLAUDE.md never loaded
- MCP memory not connected
- No capsule context
- Mobile isolated from BuilderOS coordination

---

## Solution Architecture

### Core Design Principles

1. **Session Persistence**: Server maintains full conversation history for both sessions
2. **BridgeHub Integration**: Leverage existing relay infrastructure for agent coordination
3. **Real-time Streaming**: WebSocket messages stream back to mobile as responses arrive
4. **Dual Session Support**: Jarvis and Codex sessions run simultaneously
5. **Agent Execution**: Full agent delegation with result capture
6. **Context Loading**: CLAUDE.md and capsule context injected into sessions

---

## Architecture Diagrams

### Overall System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   iOS App (SwiftUI)                         │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ ClaudeAgentService (Starscream WebSocket)           │  │
│  │ - Connects to ws://localhost:8080/api/claude/ws     │  │
│  │ - Sends: {"content": text, "session_id": "xxx"}     │  │
│  │ - Receives: streamed response chunks                │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                           │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │ CodexAgentService (Starscream WebSocket)            │  │
│  │ - Connects to ws://localhost:8080/api/codex/ws      │  │
│  │ - Sends: {"content": text, "session_id": "yyy"}     │  │
│  │ - Receives: streamed response chunks                │  │
│  └──────────────┬───────────────────────────────────────┘  │
└─────────────────┼───────────────────────────────────────────┘
                  │
                  │ WebSocket (authenticated)
                  │
┌─────────────────▼───────────────────────────────────────────┐
│         Python API Server (aiohttp)                         │
│         Port: 8080                                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ SessionManager (In-Memory + SQLite)                 │  │
│  │ - session_store: Dict[str, Session]                │  │
│  │ - persist_to_db() → SQLite database                │  │
│  │ - load_from_db() → Restore sessions on startup     │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                           │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │ /api/claude/ws Handler                              │  │
│  │ 1. Authenticate WebSocket                           │  │
│  │ 2. Load/create session                              │  │
│  │ 3. Add message to session history                   │  │
│  │ 4. Call BridgeHub with full context                 │  │
│  │ 5. Stream response back to iOS                      │  │
│  │ 6. Persist session to database                      │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                           │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │ /api/codex/ws Handler                               │  │
│  │ 1. Authenticate WebSocket                           │  │
│  │ 2. Load/create session                              │  │
│  │ 3. Add message to session history                   │  │
│  │ 4. Call BridgeHub with full context                 │  │
│  │ 5. Stream response back to iOS                      │  │
│  │ 6. Persist session to database                      │  │
│  └──────────────┬───────────────────────────────────────┘  │
└─────────────────┼───────────────────────────────────────────┘
                  │
                  │ Subprocess call (node bridgehub.js)
                  │
┌─────────────────▼───────────────────────────────────────────┐
│         BridgeHub Relay (Node.js)                           │
│         Location: tools/bridgehub/dist/bridgehub.js         │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Session Broker                                      │  │
│  │ - Track conversation history                       │  │
│  │ - Asymmetric context (Codex: full, Jarvis: summary)│  │
│  │ - Multi-turn coordination                          │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                           │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │ CLI Spawner                                         │  │
│  │ - Spawn `claude` CLI for Jarvis session            │  │
│  │ - Spawn `codex` CLI for Codex session              │  │
│  │ - Load CLAUDE.md system context                    │  │
│  │ - Connect to MCP memory                            │  │
│  │ - Execute agent delegations                        │  │
│  └──────────────┬───────────────────────────────────────┘  │
└─────────────────┼───────────────────────────────────────────┘
                  │
       ┌──────────┴────────────┐
       │                       │
       ▼                       ▼
┌──────────────┐      ┌──────────────┐
│ Claude Code  │      │    Codex     │
│   (Jarvis)   │      │              │
│              │      │              │
│ CLAUDE.md    │      │ Independent  │
│ MCP Memory   │      │ Context      │
│ Agents       │      │              │
└──────────────┘      └──────────────┘
```

### Session Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Session Lifecycle                        │
└─────────────────────────────────────────────────────────────┘

1. iOS App Startup
   │
   ├─→ ClaudeAgentService.connect()
   │   └─→ ws://localhost:8080/api/claude/ws
   │       └─→ Send API key
   │           └─→ Receive "ready" message
   │               └─→ session_id: "mobile-jarvis-<device-id>"
   │
   └─→ CodexAgentService.connect()
       └─→ ws://localhost:8080/api/codex/ws
           └─→ Send API key
               └─→ Receive "ready" message
                   └─→ session_id: "mobile-codex-<device-id>"

2. User Sends Message (Jarvis)
   │
   ├─→ iOS: {"content": "Show me capsules", "session_id": "mobile-jarvis-xyz"}
   │
   ├─→ Server: Load session from SessionManager
   │   └─→ Session exists? Load from memory
   │       Session new? Create + load from DB if exists
   │
   ├─→ Add message to session.messages[]
   │
   ├─→ Build BridgeHub request:
   │   {
   │     "version": "bridgehub/1.0",
   │     "action": "freeform",
   │     "capsule": "/Users/Ty/BuilderOS",
   │     "session": "mobile-jarvis-xyz",
   │     "payload": {
   │       "message": "Show me capsules",
   │       "context": {
   │         "conversation_history": [previous messages],
   │         "system_context": "CLAUDE.md content",
   │         "mode": "coordination"
   │       }
   │     }
   │   }
   │
   ├─→ Spawn BridgeHub subprocess:
   │   node /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js --request '<json>'
   │
   ├─→ BridgeHub spawns Claude Code CLI with full context
   │   └─→ CLAUDE.md loaded (Jarvis identity)
   │       └─→ MCP memory connected
   │           └─→ Agent coordination enabled
   │
   ├─→ Claude Code processes with full context
   │   └─→ May delegate to agents (📱 Mobile Dev, 🎨 UI Designer, etc.)
   │       └─→ Agent execution results captured
   │           └─→ Results returned to BridgeHub
   │
   ├─→ BridgeHub returns JSON:
   │   {
   │     "ok": true,
   │     "answer": "Here are your capsules:\n1. builder-system...",
   │     "duration_ms": 2340
   │   }
   │
   ├─→ Server streams response to iOS:
   │   {"type": "message", "content": "Here are your capsules:\n"}
   │   {"type": "message", "content": "1. builder-system\n"}
   │   {"type": "message", "content": "2. builderos-mobile\n"}
   │   {"type": "complete", "content": "Response complete"}
   │
   └─→ Add response to session.messages[]
       └─→ Persist session to database

3. User Switches to Codex
   │
   └─→ iOS: Uses CodexAgentService (different WebSocket)
       └─→ session_id: "mobile-codex-xyz"
       └─→ Completely independent conversation thread
       └─→ Jarvis session remains intact in memory

4. WebSocket Reconnect (Network Drop)
   │
   ├─→ iOS detects disconnect, calls connect() again
   │
   └─→ Server loads session from database
       └─→ Full conversation history restored
       └─→ iOS receives session state in "ready" message
       └─→ Seamless continuation
```

---

## Component Specifications

### 1. SessionManager Class

**File:** `api/session_manager.py`

**Purpose:** Manage conversation sessions with persistence

```python
from dataclasses import dataclass, field
from typing import List, Dict, Optional
from datetime import datetime
import json
import sqlite3
from pathlib import Path

@dataclass
class Message:
    """Single message in conversation"""
    role: str  # "user" or "assistant"
    content: str
    timestamp: datetime
    metadata: Optional[Dict] = None

@dataclass
class Session:
    """Persistent conversation session"""
    session_id: str
    agent_type: str  # "claude" or "codex"
    device_id: str
    messages: List[Message] = field(default_factory=list)
    system_context: str = ""
    capsule_context: str = ""
    created_at: datetime = field(default_factory=datetime.now)
    last_activity: datetime = field(default_factory=datetime.now)
    metadata: Dict = field(default_factory=dict)

    def add_message(self, role: str, content: str, metadata: Optional[Dict] = None):
        """Add message to conversation history"""
        msg = Message(
            role=role,
            content=content,
            timestamp=datetime.now(),
            metadata=metadata
        )
        self.messages.append(msg)
        self.last_activity = datetime.now()

    def get_conversation_history(self, max_messages: Optional[int] = None) -> List[Dict]:
        """Get conversation history formatted for Claude API"""
        messages = self.messages[-max_messages:] if max_messages else self.messages
        return [
            {"role": msg.role, "content": msg.content}
            for msg in messages
        ]

    def to_dict(self) -> Dict:
        """Serialize session to dictionary"""
        return {
            "session_id": self.session_id,
            "agent_type": self.agent_type,
            "device_id": self.device_id,
            "messages": [
                {
                    "role": msg.role,
                    "content": msg.content,
                    "timestamp": msg.timestamp.isoformat(),
                    "metadata": msg.metadata
                }
                for msg in self.messages
            ],
            "system_context": self.system_context,
            "capsule_context": self.capsule_context,
            "created_at": self.created_at.isoformat(),
            "last_activity": self.last_activity.isoformat(),
            "metadata": self.metadata
        }

    @classmethod
    def from_dict(cls, data: Dict) -> 'Session':
        """Deserialize session from dictionary"""
        messages = [
            Message(
                role=msg["role"],
                content=msg["content"],
                timestamp=datetime.fromisoformat(msg["timestamp"]),
                metadata=msg.get("metadata")
            )
            for msg in data["messages"]
        ]

        return cls(
            session_id=data["session_id"],
            agent_type=data["agent_type"],
            device_id=data["device_id"],
            messages=messages,
            system_context=data.get("system_context", ""),
            capsule_context=data.get("capsule_context", ""),
            created_at=datetime.fromisoformat(data["created_at"]),
            last_activity=datetime.fromisoformat(data["last_activity"]),
            metadata=data.get("metadata", {})
        )


class SessionManager:
    """Manage conversation sessions with SQLite persistence"""

    def __init__(self, db_path: str = "api/sessions.db"):
        self.db_path = Path(db_path)
        self.sessions: Dict[str, Session] = {}
        self._init_database()
        self._load_sessions()

    def _init_database(self):
        """Initialize SQLite database"""
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                session_id TEXT PRIMARY KEY,
                agent_type TEXT NOT NULL,
                device_id TEXT NOT NULL,
                data TEXT NOT NULL,
                created_at TEXT NOT NULL,
                last_activity TEXT NOT NULL
            )
        """)

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_device_agent
            ON sessions(device_id, agent_type)
        """)

        conn.commit()
        conn.close()

    def _load_sessions(self):
        """Load recent sessions from database into memory"""
        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        # Load sessions active in last 7 days
        cursor.execute("""
            SELECT data FROM sessions
            WHERE last_activity > datetime('now', '-7 days')
        """)

        for (data_json,) in cursor.fetchall():
            data = json.loads(data_json)
            session = Session.from_dict(data)
            self.sessions[session.session_id] = session

        conn.close()

    def get_or_create_session(
        self,
        session_id: str,
        agent_type: str,
        device_id: str
    ) -> Session:
        """Get existing session or create new one"""

        # Check memory
        if session_id in self.sessions:
            return self.sessions[session_id]

        # Check database
        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        cursor.execute(
            "SELECT data FROM sessions WHERE session_id = ?",
            (session_id,)
        )

        row = cursor.fetchone()
        conn.close()

        if row:
            data = json.loads(row[0])
            session = Session.from_dict(data)
            self.sessions[session_id] = session
            return session

        # Create new session
        session = Session(
            session_id=session_id,
            agent_type=agent_type,
            device_id=device_id
        )

        # Load system context for Jarvis sessions
        if agent_type == "claude":
            session.system_context = self._load_claude_context()

        self.sessions[session_id] = session
        self.persist_session(session)

        return session

    def persist_session(self, session: Session):
        """Save session to database"""
        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        cursor.execute("""
            INSERT OR REPLACE INTO sessions
            (session_id, agent_type, device_id, data, created_at, last_activity)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            session.session_id,
            session.agent_type,
            session.device_id,
            json.dumps(session.to_dict()),
            session.created_at.isoformat(),
            session.last_activity.isoformat()
        ))

        conn.commit()
        conn.close()

    def _load_claude_context(self) -> str:
        """Load CLAUDE.md system context"""
        claude_md_path = Path("/Users/Ty/BuilderOS/CLAUDE.md")
        if claude_md_path.exists():
            return claude_md_path.read_text()
        return ""

    def cleanup_old_sessions(self, days: int = 30):
        """Remove sessions older than N days"""
        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        cursor.execute("""
            DELETE FROM sessions
            WHERE last_activity < datetime('now', ? || ' days')
        """, (f"-{days}",))

        deleted_count = cursor.rowcount
        conn.commit()
        conn.close()

        return deleted_count
```

---

### 2. BridgeHub Integration Layer

**File:** `api/bridgehub_client.py`

**Purpose:** Call BridgeHub relay for agent coordination

```python
import asyncio
import json
import logging
from typing import Dict, Optional, AsyncIterator
from pathlib import Path

logger = logging.getLogger(__name__)

class BridgeHubClient:
    """Client for calling BridgeHub relay"""

    BRIDGEHUB_PATH = "/Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js"

    @staticmethod
    async def call_jarvis(
        message: str,
        session_id: str,
        conversation_history: list,
        system_context: str = ""
    ) -> AsyncIterator[str]:
        """
        Call BridgeHub to execute Jarvis session
        Yields response chunks as they arrive
        """

        # Build BridgeHub request
        request = {
            "version": "bridgehub/1.0",
            "action": "freeform",
            "capsule": "/Users/Ty/BuilderOS",
            "session": session_id,
            "payload": {
                "message": message,
                "context": {
                    "conversation_history": conversation_history,
                    "system_context": system_context,
                    "mode": "coordination"
                }
            }
        }

        # Spawn BridgeHub process
        process = await asyncio.create_subprocess_exec(
            "node",
            BridgeHubClient.BRIDGEHUB_PATH,
            "--request",
            json.dumps(request),
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        # Read stdout and yield chunks
        if process.stdout:
            async for line in process.stdout:
                line_str = line.decode('utf-8').strip()

                # Parse JARVIS_PAYLOAD response
                if line_str.startswith("JARVIS_PAYLOAD="):
                    payload_json = line_str.replace("JARVIS_PAYLOAD=", "")
                    try:
                        payload = json.loads(payload_json)

                        if payload.get("ok"):
                            answer = payload.get("answer", "")
                            # Yield answer in chunks for streaming
                            chunk_size = 100
                            for i in range(0, len(answer), chunk_size):
                                yield answer[i:i+chunk_size]
                        else:
                            error_msg = f"Error: {payload.get('reason', 'Unknown error')}"
                            yield error_msg

                    except json.JSONDecodeError:
                        logger.error(f"Failed to parse BridgeHub response: {payload_json}")
                        yield "Error: Invalid response from BridgeHub"

        # Wait for process to complete
        await process.wait()

        if process.returncode != 0:
            stderr = await process.stderr.read() if process.stderr else b""
            logger.error(f"BridgeHub error: {stderr.decode('utf-8')}")

    @staticmethod
    async def call_codex(
        message: str,
        session_id: str,
        conversation_history: list
    ) -> AsyncIterator[str]:
        """
        Call BridgeHub to execute Codex session
        Yields response chunks as they arrive
        """

        # Build BridgeHub request for Codex
        request = {
            "version": "bridgehub/1.0",
            "action": "freeform",
            "capsule": "/Users/Ty/BuilderOS",
            "session": session_id,
            "payload": {
                "message": message,
                "context": {
                    "conversation_history": conversation_history,
                    "visibility": "full"  # Codex sees full context
                }
            }
        }

        # Same subprocess pattern as Jarvis
        process = await asyncio.create_subprocess_exec(
            "node",
            BridgeHubClient.BRIDGEHUB_PATH,
            "--request",
            json.dumps(request),
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        if process.stdout:
            async for line in process.stdout:
                line_str = line.decode('utf-8').strip()

                if line_str.startswith("JARVIS_PAYLOAD="):
                    payload_json = line_str.replace("JARVIS_PAYLOAD=", "")
                    try:
                        payload = json.loads(payload_json)

                        if payload.get("ok"):
                            answer = payload.get("answer", "")
                            chunk_size = 100
                            for i in range(0, len(answer), chunk_size):
                                yield answer[i:i+chunk_size]
                        else:
                            yield f"Error: {payload.get('reason', 'Unknown error')}"

                    except json.JSONDecodeError:
                        logger.error(f"Failed to parse BridgeHub response")
                        yield "Error: Invalid response from BridgeHub"

        await process.wait()
```

---

### 3. Refactored API Server

**File:** `api/server.py` (complete rewrite)

```python
#!/usr/bin/env python3
"""
BuilderOS Mobile API Server (Session-Persistent)
WebSocket server for persistent Claude and Codex chat sessions
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
session_manager = SessionManager(db_path="api/sessions.db")

# Active WebSocket connections (for broadcasting)
claude_connections: Set[web.WebSocketResponse] = set()
codex_connections: Set[web.WebSocketResponse] = set()

# Cleanup old sessions on startup
logger.info(f"🧹 Cleaning up sessions older than 30 days...")
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
    - Load/create session
    - Add message to history
    - Call BridgeHub with full context
    - Stream response back
    """

    # Get or create session
    session = session_manager.get_or_create_session(
        session_id=session_id,
        agent_type="claude",
        device_id=device_id
    )

    logger.info(f"📬 Claude session '{session_id}' - {len(session.messages)} messages in history")

    # Add user message to history
    session.add_message(role="user", content=user_message)

    # Get conversation history for context
    conversation_history = session.get_conversation_history(max_messages=50)

    # Call BridgeHub and stream response
    full_response = ""

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

        # Small delay to simulate streaming
        await asyncio.sleep(0.05)

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


async def handle_codex_session(
    ws: web.WebSocketResponse,
    user_message: str,
    session_id: str,
    device_id: str
):
    """
    Handle message in Codex session
    - Load/create session
    - Add message to history
    - Call BridgeHub with full context
    - Stream response back
    """

    # Get or create session
    session = session_manager.get_or_create_session(
        session_id=session_id,
        agent_type="codex",
        device_id=device_id
    )

    logger.info(f"📬 Codex session '{session_id}' - {len(session.messages)} messages in history")

    # Add user message to history
    session.add_message(role="user", content=user_message)

    # Get conversation history
    conversation_history = session.get_conversation_history(max_messages=50)

    # Call BridgeHub and stream response
    full_response = ""

    async for chunk in BridgeHubClient.call_codex(
        message=user_message,
        session_id=session_id,
        conversation_history=conversation_history
    ):
        # Stream chunk to iOS
        chunk_msg = {
            "type": "message",
            "content": chunk,
            "timestamp": datetime.now().isoformat()
        }
        await ws.send_json(chunk_msg)

        full_response += chunk
        await asyncio.sleep(0.05)

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


async def claude_websocket_handler(request):
    """
    WebSocket endpoint for Claude Agent (Jarvis) chat
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
        "content": "Claude Agent connected (session-persistent)",
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
                    session_id = data.get("session_id", "default-claude-session")
                    device_id = data.get("device_id", "unknown-device")

                    if not user_message:
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
        "content": "Codex Agent connected (session-persistent)",
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
                    session_id = data.get("session_id", "default-codex-session")
                    device_id = data.get("device_id", "unknown-device")

                    if not user_message:
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
    """Health check endpoint"""
    return web.json_response({
        "status": "ok",
        "version": "2.0.0-persistent",
        "timestamp": datetime.now().isoformat(),
        "connections": {
            "claude": len(claude_connections),
            "codex": len(codex_connections)
        },
        "sessions": {
            "total": len(session_manager.sessions),
            "by_agent": {
                "claude": sum(1 for s in session_manager.sessions.values() if s.agent_type == "claude"),
                "codex": sum(1 for s in session_manager.sessions.values() if s.agent_type == "codex")
            }
        }
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
            "multi_turn_conversations": True
        }
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
    logger.info("🚀 Starting BuilderOS Mobile API Server (Session-Persistent)")
    logger.info(f"📡 Listening on http://localhost:{API_PORT}")
    logger.info(f"🔌 WebSocket endpoints:")
    logger.info(f"   - ws://localhost:{API_PORT}/api/claude/ws (Jarvis)")
    logger.info(f"   - ws://localhost:{API_PORT}/api/codex/ws (Codex)")
    logger.info(f"💾 Session database: api/sessions.db")
    logger.info(f"📚 Active sessions: {len(session_manager.sessions)}")

    app = create_app()
    web.run_app(app, host='0.0.0.0', port=API_PORT)


if __name__ == '__main__':
    main()
```

---

## iOS App Changes (Minimal)

### Updated Message Format

**Current:**
```swift
let messageJSON = ["content": text]
```

**New:**
```swift
let messageJSON = [
    "content": text,
    "session_id": self.sessionId,  // Device-persistent ID
    "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
]
```

### Session ID Generation

```swift
class ClaudeAgentService {
    private let sessionId: String

    init() {
        // Generate persistent session ID per device
        if let savedSessionId = UserDefaults.standard.string(forKey: "claude_session_id") {
            self.sessionId = savedSessionId
        } else {
            let newSessionId = "mobile-jarvis-\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)"
            UserDefaults.standard.set(newSessionId, forKey: "claude_session_id")
            self.sessionId = newSessionId
        }
    }
}
```

---

## Implementation Plan

### Phase 1: Core Session Infrastructure (Day 1)
1. ✅ Create `session_manager.py` with Session and SessionManager classes
2. ✅ Implement SQLite persistence layer
3. ✅ Write unit tests for session management
4. Test session creation, retrieval, and persistence

### Phase 2: BridgeHub Integration (Day 2)
1. ✅ Create `bridgehub_client.py` with async subprocess calls
2. Implement streaming response handling
3. Test BridgeHub calls with sample sessions
4. Verify CLAUDE.md context loading

### Phase 3: API Server Refactor (Day 3)
1. ✅ Rewrite `api/server.py` with session-aware handlers
2. Integrate SessionManager and BridgeHubClient
3. Update health/status endpoints with session info
4. Test WebSocket flow end-to-end

### Phase 4: iOS App Updates (Day 4)
1. Add session_id and device_id to message payloads
2. Update ClaudeAgentService and CodexAgentService
3. Test session persistence across reconnects
4. Verify context retention in multi-turn conversations

### Phase 5: Testing & Validation (Day 5)
1. Multi-turn conversation tests (5+ messages)
2. Session switching tests (Jarvis ↔ Codex)
3. Reconnection tests (simulate network drops)
4. Agent delegation tests (verify execution)
5. Performance testing (response latency, memory usage)

---

## Success Criteria

### ✅ Session Persistence
- [ ] Conversation history retained across messages
- [ ] Sessions survive WebSocket reconnects
- [ ] Multiple devices can access same session
- [ ] Session state persisted to database

### ✅ Dual Session Support
- [ ] Jarvis and Codex sessions run simultaneously
- [ ] Switching between sessions preserves context
- [ ] Each session maintains independent conversation thread
- [ ] No cross-contamination between sessions

### ✅ Agent Coordination
- [ ] Jarvis session executes agent delegations
- [ ] Agent outputs captured and returned to mobile
- [ ] Task tracking visible in session metadata
- [ ] CLAUDE.md context loaded and active

### ✅ Context Propagation
- [ ] CLAUDE.md injected into Jarvis sessions
- [ ] Conversation history included in every call
- [ ] MCP memory accessible via BridgeHub
- [ ] Capsule context loaded when available

### ✅ Real-time Streaming
- [ ] Responses stream back to iOS as chunks arrive
- [ ] Streaming works for both Jarvis and Codex
- [ ] No buffering delays (responses start immediately)
- [ ] Completion messages sent correctly

---

## Migration Guide

### Backend Migration

1. **Backup existing server:**
   ```bash
   cp api/server.py api/server.py.backup
   ```

2. **Create new files:**
   ```bash
   # Copy implementations from this document
   touch api/session_manager.py
   touch api/bridgehub_client.py
   ```

3. **Update requirements.txt:**
   ```
   aiohttp==3.10.11
   websockets==13.1
   # No change to dependencies - using stdlib for subprocess
   ```

4. **Initialize database:**
   ```bash
   python3 -c "from api.session_manager import SessionManager; SessionManager()"
   ```

5. **Test server:**
   ```bash
   python3 api/server.py
   # Should see "Session-Persistent" in startup logs
   ```

### iOS Migration

**Minimal changes required:**

1. Update `ClaudeAgentService.swift`:
   - Add `session_id` property
   - Include in message JSON
   - Generate persistent session ID

2. Update `CodexAgentService.swift`:
   - Same changes as Claude service

3. **No UI changes required** - message format stays the same

---

## Maintenance & Operations

### Database Management

**Location:** `api/sessions.db` (SQLite)

**Cleanup:**
```bash
# Manual cleanup (sessions older than 30 days)
python3 -c "from api.session_manager import SessionManager; sm = SessionManager(); print(sm.cleanup_old_sessions())"
```

**Backup:**
```bash
cp api/sessions.db api/sessions.db.backup.$(date +%Y%m%d)
```

### Monitoring

**Health Check:**
```bash
curl http://localhost:8080/api/health
```

**Response:**
```json
{
  "status": "ok",
  "connections": {"claude": 2, "codex": 1},
  "sessions": {
    "total": 5,
    "by_agent": {"claude": 3, "codex": 2}
  }
}
```

### Logging

**Server logs:**
```
🚀 Starting BuilderOS Mobile API Server (Session-Persistent)
📡 Listening on http://localhost:8080
🔌 WebSocket endpoints:
   - ws://localhost:8080/api/claude/ws (Jarvis)
   - ws://localhost:8080/api/codex/ws (Codex)
💾 Session database: api/sessions.db
📚 Active sessions: 5
```

**Message logs:**
```
📬 Claude session 'mobile-jarvis-abc123' - 12 messages in history
✅ BridgeHub call complete (2.3s)
💾 Session persisted to database
```

---

## Future Enhancements

### Phase 2 Features

1. **Multi-Device Sync**
   - Share sessions across iPhone, iPad, Mac
   - Real-time sync via WebSocket broadcast
   - Conflict resolution for concurrent edits

2. **Agent Task Tracking**
   - Track agent execution status
   - Show progress in iOS UI
   - Send push notifications on completion

3. **Context Capsules**
   - Associate sessions with specific capsules
   - Load capsule-specific context automatically
   - Capsule switching in mobile UI

4. **Voice Integration**
   - Voice input → transcription → session message
   - TTS responses from BridgeHub
   - Voice-only mode for hands-free operation

5. **Offline Mode**
   - Queue messages when offline
   - Sync when connection restored
   - Local message drafts

---

## Appendix A: API Contract

### WebSocket Message Format

**Client → Server (User Message):**
```json
{
  "content": "User message text",
  "session_id": "mobile-jarvis-abc123",
  "device_id": "iphone-xyz"
}
```

**Server → Client (Response Chunk):**
```json
{
  "type": "message",
  "content": "Response chunk text",
  "timestamp": "2025-10-27T12:34:56.789Z"
}
```

**Server → Client (Completion):**
```json
{
  "type": "complete",
  "content": "Response complete",
  "timestamp": "2025-10-27T12:34:58.123Z",
  "message_count": 15
}
```

**Server → Client (Error):**
```json
{
  "type": "error",
  "content": "Error description",
  "timestamp": "2025-10-27T12:34:58.456Z"
}
```

---

## Appendix B: Database Schema

### Sessions Table

```sql
CREATE TABLE sessions (
    session_id TEXT PRIMARY KEY,
    agent_type TEXT NOT NULL,  -- 'claude' or 'codex'
    device_id TEXT NOT NULL,
    data TEXT NOT NULL,  -- JSON serialized Session object
    created_at TEXT NOT NULL,
    last_activity TEXT NOT NULL
);

CREATE INDEX idx_device_agent ON sessions(device_id, agent_type);
```

**Sample Row:**
```json
{
  "session_id": "mobile-jarvis-abc123",
  "agent_type": "claude",
  "device_id": "iphone-xyz",
  "data": "{\"session_id\": \"mobile-jarvis-abc123\", \"messages\": [...]}",
  "created_at": "2025-10-27T12:00:00Z",
  "last_activity": "2025-10-27T15:30:00Z"
}
```

---

**End of Architecture Document**

This architecture transforms BuilderOS Mobile from a stateless relay into a true first-class citizen of the BuilderOS agent coordination system, with persistent sessions, full context awareness, and agent execution capabilities.
