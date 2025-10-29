#!/usr/bin/env python3
"""
Session Management for BuilderOS Mobile
Persistent conversation sessions with SQLite storage
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any
from datetime import datetime
import json
import sqlite3
from pathlib import Path
import logging

logger = logging.getLogger(__name__)


@dataclass
class Message:
    """Single message in conversation"""
    role: str  # "user" or "assistant"
    content: str
    timestamp: datetime
    metadata: Optional[Dict] = None

    def to_dict(self) -> Dict:
        """Serialize to dictionary"""
        return {
            "role": self.role,
            "content": self.content,
            "timestamp": self.timestamp.isoformat(),
            "metadata": self.metadata
        }

    @classmethod
    def from_dict(cls, data: Dict) -> 'Message':
        """Deserialize from dictionary"""
        return cls(
            role=data["role"],
            content=data["content"],
            timestamp=datetime.fromisoformat(data["timestamp"]),
            metadata=data.get("metadata")
        )


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
        formatted: List[Dict[str, Any]] = []

        for msg in messages:
            content = msg.content
            attachments = []

            if msg.metadata and isinstance(msg.metadata, dict):
                raw_attachments = msg.metadata.get("attachments", [])
                if isinstance(raw_attachments, list):
                    attachments = [att for att in raw_attachments if isinstance(att, dict)]

            if attachments:
                attachment_lines = []
                for att in attachments:
                    filename = att.get("filename", "file")
                    attachment_type = att.get("type", "file")
                    url = att.get("url", "")
                    size = att.get("size")

                    size_display = ""
                    if isinstance(size, (int, float)):
                        size_display = f" ({size} bytes)"

                    attachment_lines.append(
                        f"- {filename} [{attachment_type}]{size_display} {url}".strip()
                    )

                content = f"{content}\n\nAttachments:\n" + "\n".join(attachment_lines)

            formatted.append({
                "role": msg.role,
                "content": content
            })

        return formatted

    def to_dict(self) -> Dict:
        """Serialize session to dictionary"""
        return {
            "session_id": self.session_id,
            "agent_type": self.agent_type,
            "device_id": self.device_id,
            "messages": [msg.to_dict() for msg in self.messages],
            "system_context": self.system_context,
            "capsule_context": self.capsule_context,
            "created_at": self.created_at.isoformat(),
            "last_activity": self.last_activity.isoformat(),
            "metadata": self.metadata
        }

    @classmethod
    def from_dict(cls, data: Dict) -> 'Session':
        """Deserialize session from dictionary"""
        messages = [Message.from_dict(msg) for msg in data["messages"]]

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

        logger.info(f"✅ Database initialized: {self.db_path}")

    def _load_sessions(self):
        """Load recent sessions from database into memory"""
        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        # Load sessions active in last 7 days
        cursor.execute("""
            SELECT data FROM sessions
            WHERE last_activity > datetime('now', '-7 days')
        """)

        count = 0
        for (data_json,) in cursor.fetchall():
            try:
                data = json.loads(data_json)
                session = Session.from_dict(data)
                self.sessions[session.session_id] = session
                count += 1
            except Exception as e:
                logger.error(f"Failed to load session: {e}")

        conn.close()

        logger.info(f"📚 Loaded {count} sessions from database")

    def get_or_create_session(
        self,
        session_id: str,
        agent_type: str,
        device_id: str
    ) -> Session:
        """Get existing session or create new one"""

        # Check memory
        if session_id in self.sessions:
            logger.debug(f"Session '{session_id}' loaded from memory")
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
            try:
                data = json.loads(row[0])
                session = Session.from_dict(data)
                self.sessions[session_id] = session
                logger.info(f"📚 Session '{session_id}' loaded from database")
                return session
            except Exception as e:
                logger.error(f"Failed to deserialize session: {e}")

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

        logger.info(f"✨ Created new session '{session_id}' ({agent_type})")
        return session

    def persist_session(self, session: Session):
        """Save session to database"""
        conn = sqlite3.connect(str(self.db_path))
        cursor = conn.cursor()

        try:
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
            logger.debug(f"💾 Session '{session.session_id}' persisted to database")

        except Exception as e:
            logger.error(f"Failed to persist session: {e}")
            conn.rollback()

        finally:
            conn.close()

    def _load_claude_context(self) -> str:
        """Load CLAUDE.md system context"""
        claude_md_path = Path("/Users/Ty/BuilderOS/CLAUDE.md")
        if claude_md_path.exists():
            try:
                content = claude_md_path.read_text()
                logger.info(f"📖 Loaded CLAUDE.md context ({len(content)} chars)")
                return content
            except Exception as e:
                logger.error(f"Failed to load CLAUDE.md: {e}")
                return ""
        else:
            logger.warning("CLAUDE.md not found")
            return ""

    def cleanup_old_sessions(self, days: int = 30) -> int:
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

        logger.info(f"🧹 Deleted {deleted_count} sessions older than {days} days")
        return deleted_count

    def get_session_stats(self) -> Dict:
        """Get statistics about active sessions"""
        stats = {
            "total": len(self.sessions),
            "by_agent": {
                "claude": sum(1 for s in self.sessions.values() if s.agent_type == "claude"),
                "codex": sum(1 for s in self.sessions.values() if s.agent_type == "codex")
            },
            "by_device": {}
        }

        # Count sessions per device
        for session in self.sessions.values():
            device = session.device_id
            if device not in stats["by_device"]:
                stats["by_device"][device] = 0
            stats["by_device"][device] += 1

        return stats


if __name__ == "__main__":
    # Test session management
    logging.basicConfig(level=logging.INFO)

    # Initialize manager
    manager = SessionManager(db_path="/tmp/test_sessions.db")

    # Create test session
    session = manager.get_or_create_session(
        session_id="test-session-1",
        agent_type="claude",
        device_id="test-device"
    )

    # Add some messages
    session.add_message(role="user", content="Hello, Jarvis!")
    session.add_message(role="assistant", content="Hello! How can I help you today?")

    # Persist
    manager.persist_session(session)

    # Retrieve again
    session2 = manager.get_or_create_session(
        session_id="test-session-1",
        agent_type="claude",
        device_id="test-device"
    )

    print(f"Session has {len(session2.messages)} messages")
    print("Conversation history:")
    for msg in session2.get_conversation_history():
        print(f"  {msg['role']}: {msg['content']}")

    # Stats
    print(f"\nStats: {manager.get_session_stats()}")
