#!/usr/bin/env python3
"""
Performance Tracing Module for BuilderOS Mobile API

Provides timestamped trace logging to identify latency bottlenecks
in the request/response flow from iPhone → Server → BridgeHub → CLI → Response
"""

import time
import json
import logging
from datetime import datetime
from typing import Dict, Optional

logger = logging.getLogger(__name__)


class PerformanceTrace:
    """Track timing for a single request/response cycle"""

    def __init__(self, trace_id: str, session_id: str, agent_type: str):
        self.trace_id = trace_id
        self.session_id = session_id
        self.agent_type = agent_type
        self.timestamps: Dict[str, float] = {}
        self.metadata: Dict[str, any] = {}

        # Record trace creation
        self.mark("trace_created")

    def mark(self, checkpoint: str, metadata: Optional[Dict] = None):
        """Mark a timing checkpoint"""
        timestamp = time.time()
        self.timestamps[checkpoint] = timestamp

        if metadata:
            self.metadata[checkpoint] = metadata

        # Log in real-time
        if len(self.timestamps) > 1:
            # Calculate delta from previous checkpoint
            previous_checkpoints = list(self.timestamps.keys())[:-1]
            if previous_checkpoints:
                prev_checkpoint = previous_checkpoints[-1]
                prev_timestamp = self.timestamps[prev_checkpoint]
                delta_ms = (timestamp - prev_timestamp) * 1000

                logger.info(
                    f"[TRACE {self.trace_id[:8]}] {checkpoint} "
                    f"(+{delta_ms:.0f}ms from {prev_checkpoint})"
                )
        else:
            logger.info(f"[TRACE {self.trace_id[:8]}] {checkpoint}")

    def get_summary(self) -> Dict:
        """Get timing summary"""
        checkpoints = list(self.timestamps.keys())
        if len(checkpoints) < 2:
            return {
                "trace_id": self.trace_id,
                "session_id": self.session_id,
                "agent_type": self.agent_type,
                "error": "insufficient_checkpoints"
            }

        # Calculate intervals
        intervals = []
        for i in range(1, len(checkpoints)):
            prev_checkpoint = checkpoints[i - 1]
            curr_checkpoint = checkpoints[i]

            delta_ms = (
                self.timestamps[curr_checkpoint] -
                self.timestamps[prev_checkpoint]
            ) * 1000

            intervals.append({
                "from": prev_checkpoint,
                "to": curr_checkpoint,
                "duration_ms": round(delta_ms, 2)
            })

        # Calculate total time
        start_time = self.timestamps[checkpoints[0]]
        end_time = self.timestamps[checkpoints[-1]]
        total_ms = (end_time - start_time) * 1000

        return {
            "trace_id": self.trace_id,
            "session_id": self.session_id,
            "agent_type": self.agent_type,
            "start": datetime.fromtimestamp(start_time).isoformat(),
            "end": datetime.fromtimestamp(end_time).isoformat(),
            "total_duration_ms": round(total_ms, 2),
            "checkpoints": checkpoints,
            "intervals": intervals,
            "metadata": self.metadata
        }

    def log_summary(self):
        """Log complete timing summary"""
        summary = self.get_summary()

        logger.info("=" * 80)
        logger.info(f"PERFORMANCE TRACE SUMMARY: {self.trace_id[:8]}")
        logger.info("=" * 80)
        logger.info(f"Session: {self.session_id}")
        logger.info(f"Agent: {self.agent_type}")
        logger.info(f"Total Duration: {summary['total_duration_ms']:.0f}ms")
        logger.info("")
        logger.info("Timing Breakdown:")
        logger.info("-" * 80)

        for interval in summary["intervals"]:
            logger.info(
                f"  {interval['from']:30s} → {interval['to']:30s}  "
                f"{interval['duration_ms']:8.0f}ms"
            )

        logger.info("=" * 80)

        return summary


# Global trace storage (for debugging)
active_traces: Dict[str, PerformanceTrace] = {}


def create_trace(trace_id: str, session_id: str, agent_type: str) -> PerformanceTrace:
    """Create and register a new performance trace"""
    trace = PerformanceTrace(trace_id, session_id, agent_type)
    active_traces[trace_id] = trace
    return trace


def get_trace(trace_id: str) -> Optional[PerformanceTrace]:
    """Get an existing trace by ID"""
    return active_traces.get(trace_id)


def cleanup_old_traces(max_traces: int = 100):
    """Clean up old traces to prevent memory bloat"""
    if len(active_traces) > max_traces:
        # Remove oldest traces
        oldest_traces = sorted(
            active_traces.items(),
            key=lambda x: x[1].timestamps.get("trace_created", 0)
        )[:len(active_traces) - max_traces]

        for trace_id, _ in oldest_traces:
            del active_traces[trace_id]
