# BuilderOS Mobile Communication Architecture Analysis

## Executive Summary

**Current Problem:** BuilderOS Mobile is a **stateless, message-per-connection system** where context is NOT retained between messages. Each user message creates an isolated exchange with no conversation history, agent coordination, or task tracking.

**Impact:** 
- Context is completely lost after each message
- Agent delegations are parsed but never executed
- No task coordination between mobile app and Claude Code
- Responses cannot reference previous conversations
- Each message is treated as a completely independent prompt

---

## Architecture Overview

### Current Message Flow

```
┌─────────────────────┐
│  iOS Swift App      │
│  (SwiftUI)          │
└──────────┬──────────┘
           │
           │ WebSocket (Starscream)
           │ Message: {"content": "user text"}
           │
           ▼
┌─────────────────────────────────────────────┐
│  Local API Server (Python/aiohttp)         │
│  Port: 8080                                │
│                                            │
│  Routes:                                  │
│  - /api/claude/ws   (Claude endpoint)     │
│  - /api/codex/ws    (Codex endpoint)      │
└──────────┬──────────────┬──────────────────┘
           │              │
           │              │
    Claude API      BridgeHub CLI
  (Anthropic)      (Codex routing)
           │              │
           ▼              ▼
   [Response]      [Response]
           │              │
           └──────┬───────┘
                  │
           Streamed to Swift App
           (chunks + "complete" message)
```

### Key Components

#### 1. Swift iOS App (`src/Services/ClaudeAgentService.swift`)
- **WebSocket Client:** Starscream library for WebSocket communication
- **Message Format:**
  ```swift
  messageJSON = ["content": text]  // User message only
  webSocket.write(string: jsonString)
  ```
- **Response Handling:**
  ```swift
  switch response.type {
    case "message": // Accumulate response chunks
    case "complete": // Mark message complete
    case "ready": // Authentication complete
    case "error": // Error occurred
  }
  ```
- **Persistence:** ChatPersistenceManager stores messages in UserDefaults locally
  - Storage Key: `builderos_claude_chat_history`
  - Max 200 messages (trimmed oldest first)
  - **Critical Issue:** Device-local only, never sent to server

#### 2. Python API Server (`api/server.py`)
- **Framework:** aiohttp with asyncio
- **Port:** 8080 (localhost for development)
- **Authentication:** First WebSocket message must be valid API key
  - Expected key: `1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3`
  - Hardcoded in both server and app
- **Connection Management:**
  ```python
  # Separate connection sets for each agent type
  claude_connections: Set[web.WebSocketResponse] = set()
  codex_connections: Set[web.WebSocketResponse] = set()
  ```
- **Message Handler:**
  1. Parse JSON: `data = json.loads(msg.data)`
  2. Extract content: `user_message = data.get("content", "")`
  3. **CRITICAL:** No conversation history is maintained
  4. Call Claude API with single message
  5. Stream response in 100-char chunks

#### 3. Codex Integration Layer (`tools/bridgehub/dist/actions/relay.js`)
- **Purpose:** General-purpose Codex↔Jarvis communication
- **Current Status:** Placeholder only in mobile API
- **Session Management:** 
  - Sessions tracked in-memory map
  - Asymmetric context (Codex sees full history, Jarvis sees summary)
  - **Problem:** Mobile server doesn't use relay action
- **How It Should Work:**
  ```javascript
  const session = activeSessions.get(sessionId) || new SessionBroker(sessionId)
  session.addTurn(from, message)
  const prompt = buildPrompt(to, message, session, context)
  const result = await spawnCodex(prompt, 120000, visibility)
  ```

---

## Critical Architecture Problems

### Problem #1: No Conversation History on Server
**File:** `api/server.py` lines 136-189 (Claude handler)

```python
async for msg in ws:
    if msg.type == WSMsgType.TEXT:
        # Parse incoming message
        data = json.loads(msg.data)
        user_message = data.get("content", "")  # Only current message
        
        # Get Claude response with NO HISTORY
        response_text = await handle_claude_message(user_message)  # Single message only!
```

**Impact:**
- Each message is processed independently
- Claude API receives: `[{"role": "user", "content": current_message_only}]`
- Previous turns in conversation are lost
- Agent instructions in CLAUDE.md never applied

### Problem #2: No Session Persistence
**Missing:** Server has no session tracking
- No session ID generation
- No conversation store
- No way to retrieve previous messages
- Each WebSocket connection starts fresh

**What's Needed:**
```python
# Not implemented:
class Session:
    def __init__(self, session_id):
        self.session_id = session_id
        self.messages = []  # Conversation history
        self.agent_tasks = []  # Agent delegations
        self.metadata = {}  # Context about user/capsule
```

### Problem #3: Agent Delegations Are Parsed But Never Executed
**Files Involved:**
- `src/Services/ClaudeCodeParser.swift` (lines 60-75) — Extracts agent emoji from text
- `api/server.py` (lines 107-108) — Codex handler is a stub with TODO

**Agent Detection:**
```swift
// Mobile app detects agent lines:
if line.contains("📱") || line.contains("🎨") || line.contains("🏛️") {
    let agentMatch = extractAgentDelegation(from: line)
    // Parses and displays to user but NEVER TRIGGERS ACTUAL AGENT
}
```

**Codex Placeholder:**
```python
async def handle_codex_message(content: str) -> str:
    # TODO: Integrate with BridgeHub CLI for Codex communication
    return f"Codex response placeholder for: {content}"
```

**Result:** When Claude Code (Jarvis) response says "Delegating to 📱 Mobile Dev", the mobile app displays this text but:
- Does not invoke the actual agent
- Does not capture agent output
- Does not return results to user

### Problem #4: No Upstream Context from Claude Code
**File:** `api/server.py` lines 81-88 (Claude API call)

```python
response = anthropic_client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[
        {"role": "user", "content": content}  # NO SYSTEM CONTEXT
    ],
    stream=True
)
```

**Missing:**
- No system prompt (no CLAUDE.md instructions injected)
- No capsule context
- No previous conversation turns
- No agent coordination awareness

**Comparison to Desktop Claude Code:**
- Desktop sessions load `CLAUDE.md` at startup
- Full context persists across all messages
- Agent coordination is stateful
- Task tracking is maintained

### Problem #5: Disconnected from BridgeHub Relay
**Files:**
- `tools/bridgehub/dist/actions/relay.js` — Full bidirectional Codex↔Jarvis relay
- `api/server.py` — Never calls relay action

**BridgeHub Relay Features** (Not Used):
- Asymmetric context visibility
- Session history management
- Multi-turn coordination
- Full CLI integration

**Why It Matters:**
Mobile should be calling BridgeHub relay for agent tasks, not making direct API calls

---

## Message Flow Comparison: What Happens vs. What Should Happen

### Current Flow (Broken)

**User sends:** "Tell me about BuilderOS capsules"

```
1. Swift App: Send {"content": "Tell me about BuilderOS capsules"}
2. Server receives: parse JSON, extract message
3. Claude API: [{"role": "user", "content": "Tell me about BuilderOS capsules"}]
   ❌ No system context
   ❌ No conversation history
   ❌ No capsule awareness
4. Claude responds: Generic answer about capsules
5. Server streams response back
6. Swift app displays text
7. ❌ Message history saved locally only (device only)
8. ❌ If Claude said "delegating to agent X", agent is never invoked
```

### What Should Happen (Fixed)

**Same user message:**

```
1. Swift App: Send {"content": "Tell me about BuilderOS capsules", "session_id": "mobile-sess-123"}
2. Server receives: parse JSON, extract session
3. Load session from database:
   - Previous messages in conversation
   - User profile/capsule context
   - Agent coordination state
4. Call BridgeHub Relay:
   - Send full conversation context
   - Include CLAUDE.md system prompt
   - Request agent execution if needed
5. BridgeHub Relay:
   - Spawn Claude Code with full context
   - Execute any agent delegations
   - Return coordination results
6. Server streams response with metadata:
   - Full message history
   - Agent task results
   - Updated context
7. Swift app displays with:
   - Full conversation visible
   - Agent execution status
   - Task tracking
8. ✅ Message stored on server (shared across devices)
9. ✅ Future messages have full context
```

---

## How Each Component Should Work (Fixed)

### Session Management Architecture

```swift
// Swift App should send:
{
  "content": "user message",
  "session_id": "mobile-sess-123",  // Persistent per device
  "capsule": "builderos-mobile",    // Current context
  "mode": "coordination"             // Request agent execution
}
```

```python
# Python Server should maintain:
class MobileSession:
    session_id: str
    user_device: str
    messages: List[Message]  # Full conversation
    agent_tasks: List[Task]  # Pending/completed
    last_activity: datetime
    system_context: str      # Loaded from CLAUDE.md
    capsule_context: str     # Current capsule context
    
    def add_message(self, role: str, content: str):
        """Add to conversation history"""
    
    def invoke_agent(self, agent_name: str, task: str):
        """Call BridgeHub relay to execute agent"""
    
    def get_context_prompt(self) -> str:
        """Build system prompt with full context"""
```

### BridgeHub Relay Integration

```python
# In api/server.py handle_codex_message():

async def handle_codex_message(content: str, session: MobileSession) -> str:
    # Instead of placeholder, call BridgeHub relay
    
    result = await subprocess.run([
        'node', '/path/to/bridgehub.js',
        '--request', json.dumps({
            "version": "bridgehub/1.0",
            "action": "relay",
            "from": "mobile-app",
            "to": "codex",
            "message": content,
            "context": {
                "session_id": session.session_id,
                "conversation": session.get_context(),
                "visibility": "summary"
            }
        })
    ], capture_output=True, text=True)
    
    return result.stdout
```

### Agent Task Tracking

```swift
// Swift App should display:
ChatMessage(
    type: .agentDelegation,
    content: "📱 Mobile Dev → Building chat interface",
    status: .executing,  // ← NEW
    taskId: "task-456"   // ← NEW
)

// And later receive update:
ChatMessage(
    type: .agentResult,  // ← NEW
    content: "[Chat interface build complete]",
    status: .completed,
    taskId: "task-456"
)
```

---

## Current Data Flow: Where Context Is Lost

### Local Device Storage (Exists)
- **Location:** `ChatPersistenceManager` (UserDefaults)
- **Key:** `builderos_claude_chat_history`
- **Limit:** 200 messages max per device
- **Scope:** Device-only (not shared across iPad/Mac/iPhone)
- **Problem:** Server never reads this

### Server Storage (Missing)
- **Location:** Should be database, currently non-existent
- **What's Missing:**
  - No session table
  - No conversation history table
  - No agent task tracking
  - No system context storage
- **Impact:** Each connection starts with zero context

### Claude Code Context (Disconnected)
- **Location:** Desktop CLAUDE.md + MCP memory
- **What's Missing:**
  - Mobile server doesn't load CLAUDE.md
  - Mobile server doesn't connect to MCP memory
  - No bidirectional context sync
- **Impact:** Claude responses lack BuilderOS awareness

---

## File-by-File Context Loss Points

| File | Line(s) | Problem | Impact |
|------|---------|---------|--------|
| `api/server.py` | 84-87 | Messages sent to Claude API without history | No context in Claude response |
| `api/server.py` | 136-189 | Handler processes single message, stores nothing | Each message starts fresh |
| `api/server.py` | 103-108 | Codex handler is placeholder | Agent tasks never executed |
| `src/ClaudeCodeParser.swift` | 60-75 | Parses agent lines but never triggers agents | Delegations visible but inert |
| `src/ChatPersistenceManager.swift` | 38-52 | Saves to device UserDefaults | Not accessible to server or other devices |
| `api/server.py` | Missing | No session/database layer | Zero persistence across connections |

---

## Why BridgeHub Relay Isn't Being Used

### BridgeHub Relay Design (In `tools/bridgehub/`)
```javascript
// BridgeHub relay.js handles:
- Full conversation context (for Codex)
- Summary context (for Jarvis)
- Session tracking
- Multi-turn coordination
- Agent invocation
```

### Current Integration Attempt
1. Mobile API server created (`api/server.py`)
2. Separate from desktop Jarvis session
3. Doesn't call `bridgehub.js` relay
4. Creates independent thread of conversation
5. Result: Relay features are unused

### Why Not Connected
- **Design Decision:** Implemented as local HTTP server, not integrated with BridgeHub
- **Result:** Mobile app talks to simple Python server, not to actual Jarvis/Codex coordination layer
- **Missing Link:** No subprocess call to `node bridgehub.js`

---

## System Architecture Diagram (Current State)

```
BuilderOS Mobile System (Current - Broken Context)

┌─────────────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                           │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ClaudeAgentService (Starscream WebSocket)              │  │
│  │ - Connects to ws://localhost:8080/api/claude/ws        │  │
│  │ - Sends: {"content": user_message_only}                │  │
│  │ - Receives: streamed response chunks                   │  │
│  └──────────┬───────────────────────────────────────────────┘  │
│             │                                                    │
│  ┌──────────▼──────────────────────────────────────────────┐  │
│  │ ChatPersistenceManager (UserDefaults)                  │  │
│  │ - Stores locally only                                  │  │
│  │ - Max 200 messages                                     │  │
│  │ - Device-specific, not synced to server               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ClaudeCodeParser                                       │  │
│  │ - Detects agent emoji (📱, 🎨, 🏛️)                    │  │
│  │ - Parses task text                                     │  │
│  │ - ❌ Never triggers actual agent execution             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ WebSocket
                           │ {"content": "..."}  [No history]
                           │
┌──────────────────────────▼────────────────────────────────────┐
│         Python API Server (aiohttp)                           │
│         Port: 8080                                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ /api/claude/ws Handler                                 │ │
│  │ - Parses message                                       │ │
│  │ - ❌ Stores nothing (no session)                       │ │
│  │ - Calls Claude API with single message                │ │
│  │ - Streams back response                               │ │
│  └──────────┬────────────────────────────────────────────┘ │
│             │                                              │
│  ┌──────────▼──────────────────────────────────────────────┐ │
│  │ /api/codex/ws Handler (STUB)                           │ │
│  │ - Placeholder implementation                           │ │
│  │ - Returns mock response                                │ │
│  │ - ❌ Never calls BridgeHub relay                       │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
└──────────┬──────────────────────────────┬────────────────────┘
           │                              │
    Claude API              BridgeHub CLI (Disconnected)
   (Anthropic)                    |
           │                      │
    [Response]            [Should call relay]
           │                      │
           └──────────┬───────────┘
                      │
                  To Swift App
                  (chunks only)
```

---

## Data Isolation Problem

```
Desktop Claude Code              Mobile App
─────────────────              ──────────
✅ CLAUDE.md loaded           ❌ No CLAUDE.md
✅ MCP memory connected       ❌ No MCP memory
✅ Agent coordination        ❌ No agent tracking
✅ Full conversation history  ❌ Only current message
✅ Task tracking             ❌ No task tracking
✅ System context injected   ❌ No system context
✅ Bidirectional sync        ❌ One-way messages
                               
Two completely separate systems with no coordination!
```

---

## Summary Table: What Exists vs. What's Missing

| Component | Current | Required | Gap |
|-----------|---------|----------|-----|
| **Session Management** | None | Database + session IDs | Complete absence |
| **Conversation History** | Device only (UserDefaults) | Server + database | Not accessible to server |
| **System Context** | In desktop CLAUDE.md | Injected into Claude API | Never included |
| **Agent Coordination** | Parsed but inert | Active execution + tracking | Stub implementations |
| **BridgeHub Relay** | Exists but unused | Called for all tasks | No integration |
| **Context Propagation** | One-way (mobile → server) | Bidirectional | Missing upstream |
| **Task Tracking** | None | Database + status tracking | Complete absence |
| **Multi-Device Sync** | No | Server-based sync | Not implemented |
| **MCP Memory Access** | None | Shared context layer | Not implemented |

---

## Root Cause Analysis

### Why This Happened

1. **Architecture Decision:** Built separate HTTP server instead of integrating with BridgeHub
2. **Timeline Pressure:** Quick implementation to get mobile communication working
3. **Scope Creep:** Started with simple message relay, didn't evolve to handle sessions
4. **Integration Gap:** Mobile server and desktop Jarvis operate independently

### Why It's a Problem Now

1. **Context Awareness:** Each message is stateless
2. **Agent Execution:** Delegations are parsed but never triggered
3. **User Experience:** Can't have multi-turn conversations with history
4. **System Integration:** Mobile is isolated from BuilderOS coordination layer

---

## Conclusion

**BuilderOS Mobile is a stateless, message-per-connection system that violates BuilderOS's fundamental design principle of persistent, agent-coordinated execution.**

The architecture treats the mobile app as a simple chat client that:
- Sends one message at a time
- Receives one response
- Has no conversation history on server
- Cannot coordinate with agents
- Is completely disconnected from Jarvis's context layer

To fix this, the mobile server needs to:
1. Adopt BridgeHub Relay for agent coordination
2. Implement session persistence with conversation history
3. Inject CLAUDE.md and capsule context into prompts
4. Track agent tasks and return results to mobile
5. Sync state bidirectionally with desktop Jarvis

This is not a quick patch—it requires redesigning the mobile communication layer to be a true first-class citizen in the BuilderOS agent coordination architecture.
