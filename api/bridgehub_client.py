#!/usr/bin/env python3
"""
BridgeHub Integration Client for BuilderOS Mobile
Connects mobile backend to BridgeHub relay for agent coordination
"""

import asyncio
import json
import logging
from typing import Dict, Optional, AsyncIterator, List
from pathlib import Path

logger = logging.getLogger(__name__)


class BridgeHubClient:
    """Client for calling BridgeHub relay"""

    BRIDGEHUB_PATH = "/Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js"
    DEFAULT_TIMEOUT = 120  # 2 minutes

    @staticmethod
    async def call_jarvis(
        message: str,
        session_id: str,
        conversation_history: List[Dict],
        system_context: str = ""
    ) -> AsyncIterator[str]:
        """
        Call BridgeHub to execute Jarvis session via CLAUDE CODE
        Routes to Claude Code (not Codex) for full BuilderOS access

        Direction: codex_to_claude → spawns Claude Code CLI
        - Full file system access (no sandbox)
        - Full BuilderOS context and tools
        - Same environment as desktop Claude Code sessions

        Yields response chunks as they arrive

        Args:
            message: User's message
            session_id: Persistent session ID
            conversation_history: Previous messages [{"role": "user", "content": "..."}]
            system_context: CLAUDE.md content

        Yields:
            Response chunks as strings
        """

        logger.info(f"📞 Calling BridgeHub for Jarvis session '{session_id}' → Claude Code")
        logger.debug(f"   Message: {message[:60]}...")
        logger.debug(f"   History: {len(conversation_history)} messages")

        # Build BridgeHub request with correct payload format
        # context must be an array of {title, role, content} objects
        context_items = []

        # Add conversation history as context
        if conversation_history:
            context_items.append({
                "title": "Conversation History",
                "role": "note",
                "content": json.dumps(conversation_history, indent=2)
            })

        # NOTE: Do NOT send CLAUDE.md through BridgeHub
        # The file is 35KB and causes the response payload to be too large (65KB+)
        # which gets corrupted when reading line-by-line from stdout.
        # BridgeHub/Codex already has access to CLAUDE.md in the filesystem.
        # if system_context:
        #     context_items.append({
        #         "title": "System Context (CLAUDE.md)",
        #         "role": "system",
        #         "content": system_context
        #     })

        request = {
            "version": "bridgehub/1.0",
            "action": "freeform",
            "capsule": "/Users/Ty/BuilderOS",
            "session": session_id,
            "payload": {
                "message": message,
                "intent": "mobile_session_query",
                "direction": "codex_to_claude",  # Jarvis uses Claude Code, not Codex
                "context": context_items,
                "metadata": {
                    "source": "builderos_mobile",
                    "mode": "coordination"
                }
            }
        }

        # Call BridgeHub and stream response
        async for chunk in BridgeHubClient._execute_bridgehub(request):
            yield chunk

    @staticmethod
    async def call_codex(
        message: str,
        session_id: str,
        conversation_history: List[Dict]
    ) -> AsyncIterator[str]:
        """
        Call BridgeHub to execute Codex session via CODEX CLI
        Routes to Codex CLI for code-focused assistance

        Direction: claude_to_codex → spawns Codex CLI
        - Sandbox mode: danger-full-access (full write permissions)
        - Approval mode: never (autonomous execution)
        - Focused on code generation and technical tasks

        Yields response chunks as they arrive

        Args:
            message: User's message
            session_id: Persistent session ID
            conversation_history: Previous messages

        Yields:
            Response chunks as strings
        """

        logger.info(f"📞 Calling BridgeHub for Codex session '{session_id}' → Codex CLI")
        logger.debug(f"   Message: {message[:60]}...")
        logger.debug(f"   History: {len(conversation_history)} messages")

        # Build BridgeHub request for Codex with correct payload format
        context_items = []

        # Add conversation history (Codex sees full context)
        if conversation_history:
            context_items.append({
                "title": "Full Conversation History",
                "role": "note",
                "content": json.dumps(conversation_history, indent=2)
            })

        request = {
            "version": "bridgehub/1.0",
            "action": "freeform",
            "capsule": "/Users/Ty/BuilderOS",
            "session": session_id,
            "payload": {
                "message": message,
                "intent": "mobile_codex_query",
                "direction": "claude_to_codex",  # Codex uses Codex CLI with danger-full-access
                "context": context_items,
                "metadata": {
                    "source": "builderos_mobile",
                    "visibility": "full"
                }
            }
        }

        # Call BridgeHub and stream response
        async for chunk in BridgeHubClient._execute_bridgehub(request):
            yield chunk

    @staticmethod
    async def _execute_bridgehub(request: Dict) -> AsyncIterator[str]:
        """
        Execute BridgeHub subprocess and stream output

        Args:
            request: BridgeHub request payload

        Yields:
            Response chunks from BridgeHub
        """
        import time

        # Track timing
        start_time = time.time()
        spawn_time = None
        first_output_time = None
        first_chunk_time = None

        # Verify BridgeHub exists
        if not Path(BridgeHubClient.BRIDGEHUB_PATH).exists():
            error_msg = f"BridgeHub not found at {BridgeHubClient.BRIDGEHUB_PATH}"
            logger.error(error_msg)
            yield f"Error: {error_msg}"
            return

        # Serialize request
        request_json = json.dumps(request)

        logger.debug(f"🚀 Spawning BridgeHub process")
        logger.debug(f"   Command: node {BridgeHubClient.BRIDGEHUB_PATH} --request '<json>'")

        try:
            # Spawn BridgeHub process
            process = await asyncio.create_subprocess_exec(
                "node",
                BridgeHubClient.BRIDGEHUB_PATH,
                "--request",
                request_json,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            spawn_time = time.time()
            spawn_duration_ms = (spawn_time - start_time) * 1000
            logger.info(f"⏱️  BridgeHub process spawned in {spawn_duration_ms:.0f}ms")

            # Read stdout line by line
            if process.stdout:
                async for line in process.stdout:
                    line_str = line.decode('utf-8').strip()

                    # Mark first output
                    if first_output_time is None:
                        first_output_time = time.time()
                        first_output_ms = (first_output_time - start_time) * 1000
                        logger.info(f"⏱️  First output from BridgeHub in {first_output_ms:.0f}ms")

                    # Skip empty lines
                    if not line_str:
                        continue

                    logger.debug(f"   BridgeHub output: {line_str[:80]}...")

                    # Parse JARVIS_PAYLOAD response
                    if line_str.startswith("JARVIS_PAYLOAD="):
                        payload_buffer = line_str.replace("JARVIS_PAYLOAD=", "")

                        try:
                            payload = json.loads(payload_buffer)

                            if payload.get("ok"):
                                # Extract answer from data.output field
                                data = payload.get("data", {})
                                answer = data.get("output", "")

                                # Fallback to summary if output is empty
                                if not answer:
                                    answer = payload.get("summary", "No response")

                                logger.info(f"✅ BridgeHub call successful")
                                logger.debug(f"   Answer length: {len(answer)} chars")

                                # Yield answer in chunks for streaming
                                chunk_size = 100
                                for i in range(0, len(answer), chunk_size):
                                    chunk = answer[i:i+chunk_size]

                                    # Mark first chunk time
                                    if first_chunk_time is None:
                                        first_chunk_time = time.time()
                                        first_chunk_ms = (first_chunk_time - start_time) * 1000
                                        logger.info(f"⏱️  First chunk yielded in {first_chunk_ms:.0f}ms")

                                    yield chunk

                            else:
                                # Error response
                                reason = payload.get("reason", "Unknown error")
                                details = payload.get("details", "")

                                error_msg = f"BridgeHub error: {reason}"
                                if details:
                                    error_msg += f" - {details}"

                                logger.error(error_msg)
                                yield f"Error: {reason}"

                        except json.JSONDecodeError as e:
                            logger.error(f"Failed to parse BridgeHub response: {e}")
                            logger.error(f"   Payload length: {len(payload_buffer)} chars")
                            logger.error(f"   First 200 chars: {payload_buffer[:200]}")
                            logger.error(f"   Last 200 chars: {payload_buffer[-200:]}")
                            logger.error(f"   Chars around error position: {payload_buffer[37300:37400]}")
                            yield "Error: Invalid response from BridgeHub"

                    else:
                        # Other output (logs, debug info)
                        logger.debug(f"   [BridgeHub] {line_str}")

            # Wait for process to complete
            return_code = await process.wait()

            if return_code != 0:
                # Process failed
                stderr = await process.stderr.read() if process.stderr else b""
                stderr_str = stderr.decode('utf-8').strip()

                logger.error(f"❌ BridgeHub process failed (exit code {return_code})")
                if stderr_str:
                    logger.error(f"   stderr: {stderr_str}")

                yield f"Error: BridgeHub process failed (code {return_code})"

        except FileNotFoundError:
            error_msg = "Node.js not found. Is Node.js installed?"
            logger.error(error_msg)
            yield f"Error: {error_msg}"

        except Exception as e:
            logger.error(f"❌ BridgeHub execution failed: {e}", exc_info=True)
            yield f"Error: {str(e)}"

    @staticmethod
    async def health_check() -> Dict:
        """
        Check if BridgeHub is available and functional

        Returns:
            Health status dictionary
        """

        # Check if BridgeHub file exists
        bridgehub_exists = Path(BridgeHubClient.BRIDGEHUB_PATH).exists()

        # Check if Node.js is available
        try:
            process = await asyncio.create_subprocess_exec(
                "node",
                "--version",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await process.communicate()
            node_version = stdout.decode('utf-8').strip() if stdout else None
            node_available = process.returncode == 0
        except FileNotFoundError:
            node_version = None
            node_available = False

        return {
            "bridgehub_exists": bridgehub_exists,
            "bridgehub_path": str(BridgeHubClient.BRIDGEHUB_PATH),
            "node_available": node_available,
            "node_version": node_version,
            "ready": bridgehub_exists and node_available
        }


async def main():
    """Test BridgeHub client"""
    logging.basicConfig(level=logging.DEBUG)

    # Health check
    health = await BridgeHubClient.health_check()
    print("🏥 BridgeHub Health Check:")
    print(f"   BridgeHub exists: {health['bridgehub_exists']}")
    print(f"   Node.js available: {health['node_available']}")
    print(f"   Node.js version: {health['node_version']}")
    print(f"   Ready: {health['ready']}")

    if not health["ready"]:
        print("\n❌ BridgeHub not ready. Cannot proceed with test.")
        return

    print("\n📞 Testing BridgeHub call...")

    # Test call
    conversation_history = [
        {"role": "user", "content": "Hello"},
        {"role": "assistant", "content": "Hi! How can I help?"}
    ]

    print("\nStreaming response:")
    print("-" * 60)

    async for chunk in BridgeHubClient.call_jarvis(
        message="What is BuilderOS?",
        session_id="test-session-123",
        conversation_history=conversation_history,
        system_context="You are Jarvis, Ty's assistant."
    ):
        print(chunk, end='', flush=True)

    print()
    print("-" * 60)
    print("\n✅ Test complete")


if __name__ == "__main__":
    asyncio.run(main())
