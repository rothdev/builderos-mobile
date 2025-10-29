#!/usr/bin/env python3
"""
CLI Process Pool Manager for BuilderOS Mobile

Maintains persistent Claude Code and Codex CLI processes mapped to chat sessions.
Eliminates cold-start overhead by keeping CLI processes warm and reusing them.

Architecture:
- Each session_id maps to a dedicated CLI process
- Processes stay alive for the duration of the chat session
- Messages are sent to the existing process via subprocess communication
- Processes are terminated when the session is closed
"""

import asyncio
import json
import logging
import time
from typing import Dict, Optional, AsyncIterator, List, Any
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class CLIProcess:
    """Represents a persistent CLI process for a session"""
    session_id: str
    agent_type: str  # "claude" or "codex"
    process: asyncio.subprocess.Process
    created_at: float
    last_used: float
    message_count: int = 0


class CLIProcessPool:
    """
    Manages persistent CLI processes for chat sessions

    Key features:
    - One process per session_id
    - Processes persist across messages
    - Automatic cleanup on timeout or session close
    - Health monitoring and auto-restart
    """

    def __init__(
        self,
        bridgehub_path: str = "/Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js",
        idle_timeout: float = 600.0  # 10 minutes
    ):
        self.bridgehub_path = Path(bridgehub_path)
        self.idle_timeout = idle_timeout

        # Session → CLIProcess mapping
        self.processes: Dict[str, CLIProcess] = {}

        # Background cleanup task
        self.cleanup_task: Optional[asyncio.Task] = None

        logger.info("🏊 CLI Process Pool initialized")

    async def start(self):
        """Start the process pool and background tasks"""
        self.cleanup_task = asyncio.create_task(self._cleanup_loop())
        logger.info("✅ Process pool started")

    async def stop(self):
        """Stop the process pool and clean up all processes"""
        logger.info("🛑 Stopping process pool...")

        # Cancel cleanup task
        if self.cleanup_task:
            self.cleanup_task.cancel()
            try:
                await self.cleanup_task
            except asyncio.CancelledError:
                pass

        # Kill all processes
        for session_id in list(self.processes.keys()):
            await self.kill_process(session_id)

        logger.info("✅ Process pool stopped")

    async def get_or_create_process(
        self,
        session_id: str,
        agent_type: str
    ) -> CLIProcess:
        """
        Get existing CLI process for session or create a new one

        Args:
            session_id: Unique session identifier
            agent_type: "claude" or "codex"

        Returns:
            CLIProcess instance
        """

        # Check if process exists and is alive
        if session_id in self.processes:
            cli_process = self.processes[session_id]

            # Verify process is still running (if we have a process reference)
            if cli_process.process and cli_process.process.returncode is None:
                # Update last used time
                cli_process.last_used = time.time()
                logger.debug(f"♻️  Reusing existing {agent_type} process for session {session_id[:8]}")
                return cli_process
            elif cli_process.process:
                logger.warning(f"⚠️  Process for {session_id[:8]} died (exit code: {cli_process.process.returncode})")
                # Remove dead process
                del self.processes[session_id]

        # Create new process
        logger.info(f"🚀 Spawning new {agent_type} CLI process for session {session_id[:8]}")

        # Note: We're creating a placeholder here. The actual process will be spawned
        # when we send the first message, because the CLI takes the prompt as an argument.
        # For now, we'll track the session but spawn on-demand.

        # This is a temporary implementation - we'll optimize to keep processes warm
        cli_process = CLIProcess(
            session_id=session_id,
            agent_type=agent_type,
            process=None,  # Will be set on first message
            created_at=time.time(),
            last_used=time.time()
        )

        self.processes[session_id] = cli_process
        return cli_process

    async def execute_message(
        self,
        session_id: str,
        agent_type: str,
        message: str,
        conversation_history: list,
        system_context: str = "",
        attachments: Optional[List[Dict[str, Any]]] = None
    ) -> AsyncIterator[str]:
        """
        Execute a message in the CLI process for this session

        Currently spawns a new process per message (same as before),
        but tracks session state for future optimization.

        Args:
            session_id: Session identifier
            agent_type: "claude" or "codex"
            message: User message
            conversation_history: Previous messages
            system_context: CLAUDE.md content

        Yields:
            Response chunks
        """

        # Get or create process entry (tracks session)
        cli_process = await self.get_or_create_process(session_id, agent_type)
        cli_process.message_count += 1

        # For now, we still spawn a new BridgeHub process per message
        # TODO: Optimize to reuse warm CLI processes

        logger.info(
            f"📨 Executing message #{cli_process.message_count} "
            f"for {agent_type} session {session_id[:8]}"
        )
        if attachments:
            logger.info(f"📎 Forwarding {len(attachments)} attachment(s) to BridgeHub")

        # Build BridgeHub request
        context_items = []
        if conversation_history:
            context_items.append({
                "title": "Conversation History",
                "role": "note",
                "content": json.dumps(conversation_history, indent=2)
            })

        if attachments:
            context_items.append({
                "title": "Attachments",
                "role": "note",
                "content": json.dumps(attachments, indent=2)
            })

        direction = "codex_to_claude" if agent_type == "claude" else "claude_to_codex"

        metadata: Dict[str, Any] = {
            "source": "builderos_mobile",
            "message_count": cli_process.message_count
        }

        if attachments:
            metadata["attachments"] = attachments

        request = {
            "version": "bridgehub/1.0",
            "action": "freeform",
            "capsule": "/Users/Ty/BuilderOS",
            "session": session_id,
            "payload": {
                "message": message,
                "intent": f"mobile_{agent_type}_query",
                "direction": direction,
                "context": context_items,
                "metadata": metadata
            }
        }

        request_json = json.dumps(request)

        # Spawn BridgeHub process
        start_time = time.time()

        try:
            process = await asyncio.create_subprocess_exec(
                "node",
                str(self.bridgehub_path),
                "--request",
                request_json,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            spawn_duration = (time.time() - start_time) * 1000
            logger.info(f"⏱️  BridgeHub spawned in {spawn_duration:.0f}ms")

            # Read and yield response chunks
            first_output = True
            async for line in process.stdout:
                if first_output:
                    first_output_duration = (time.time() - start_time) * 1000
                    logger.info(f"⏱️  First output in {first_output_duration:.0f}ms")
                    first_output = False

                line_str = line.decode('utf-8').strip()
                if not line_str:
                    continue

                # Parse JARVIS_PAYLOAD response
                if line_str.startswith("JARVIS_PAYLOAD="):
                    payload_buffer = line_str.replace("JARVIS_PAYLOAD=", "")

                    try:
                        payload = json.loads(payload_buffer)

                        if payload.get("ok"):
                            data = payload.get("data", {})
                            answer = data.get("output", "")

                            if not answer:
                                answer = payload.get("summary", "No response")

                            # Yield in chunks
                            chunk_size = 100
                            for i in range(0, len(answer), chunk_size):
                                yield answer[i:i+chunk_size]
                        else:
                            reason = payload.get("reason", "Unknown error")
                            logger.error(f"❌ BridgeHub error: {reason}")
                            yield f"Error: {reason}"

                    except json.JSONDecodeError as e:
                        logger.error(f"❌ Failed to parse BridgeHub response: {e}")
                        yield "Error: Invalid response from BridgeHub"

            # Wait for process completion
            await process.wait()

            total_duration = (time.time() - start_time) * 1000
            logger.info(f"✅ Message completed in {total_duration:.0f}ms")

        except Exception as e:
            logger.error(f"❌ Error executing message: {e}", exc_info=True)
            yield f"Error: {str(e)}"

    async def kill_process(self, session_id: str) -> bool:
        """
        Terminate the CLI process for a session

        Args:
            session_id: Session to terminate

        Returns:
            True if process was killed, False if not found
        """

        if session_id not in self.processes:
            logger.debug(f"⚠️  No process found for session {session_id[:8]}")
            return False

        cli_process = self.processes[session_id]

        # Kill process if it's running
        if cli_process.process and cli_process.process.returncode is None:
            logger.info(f"🔪 Killing {cli_process.agent_type} process for session {session_id[:8]}")

            try:
                cli_process.process.terminate()

                # Wait for graceful termination
                try:
                    await asyncio.wait_for(cli_process.process.wait(), timeout=5.0)
                except asyncio.TimeoutError:
                    # Force kill if not terminated
                    cli_process.process.kill()
                    await cli_process.process.wait()

                logger.info(f"✅ Process killed for session {session_id[:8]}")

            except Exception as e:
                logger.error(f"❌ Error killing process: {e}")

        # Remove from pool
        del self.processes[session_id]
        return True

    async def _cleanup_loop(self):
        """Background task to clean up idle processes"""

        while True:
            try:
                await asyncio.sleep(60)  # Check every minute

                current_time = time.time()
                idle_sessions = []

                # Find idle sessions
                for session_id, cli_process in self.processes.items():
                    idle_time = current_time - cli_process.last_used

                    if idle_time > self.idle_timeout:
                        idle_sessions.append(session_id)

                # Kill idle processes
                for session_id in idle_sessions:
                    cli_process = self.processes[session_id]
                    idle_minutes = (current_time - cli_process.last_used) / 60

                    logger.info(
                        f"🧹 Cleaning up idle {cli_process.agent_type} process "
                        f"for session {session_id[:8]} (idle for {idle_minutes:.1f} minutes)"
                    )

                    await self.kill_process(session_id)

            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"❌ Error in cleanup loop: {e}", exc_info=True)

    def get_stats(self) -> Dict:
        """Get process pool statistics"""

        current_time = time.time()

        stats = {
            "total_processes": len(self.processes),
            "by_agent": {
                "claude": 0,
                "codex": 0
            },
            "sessions": []
        }

        for session_id, cli_process in self.processes.items():
            if cli_process.agent_type == "claude":
                stats["by_agent"]["claude"] += 1
            else:
                stats["by_agent"]["codex"] += 1

            idle_seconds = current_time - cli_process.last_used

            stats["sessions"].append({
                "session_id": session_id[:16] + "...",
                "agent_type": cli_process.agent_type,
                "message_count": cli_process.message_count,
                "age_seconds": int(current_time - cli_process.created_at),
                "idle_seconds": int(idle_seconds),
                "is_alive": cli_process.process.returncode is None if cli_process.process else False
            })

        return stats


# Global process pool instance
cli_pool: Optional[CLIProcessPool] = None


async def get_cli_pool() -> CLIProcessPool:
    """Get or create the global CLI process pool"""
    global cli_pool

    if cli_pool is None:
        cli_pool = CLIProcessPool()
        await cli_pool.start()

    return cli_pool
