# BuilderOS Mobile Communication - Flow Diagrams

## 1. Current Broken Flow: Message-per-Connection

```
User Types: "How do I deploy a capsule?"
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│ iOS App - ClaudeAgentService                           │
│ Sends: {"content": "How do I deploy a capsule?"}       │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ WebSocket
                 │ (No session ID)
                 │ (No conversation context)
                 │
        ┌────────▼────────┐
        │ Server connects │
        │ Is fresh        │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────────┐
        │ Parse: extract      │
        │ "How do I deploy"   │
        │ Store: NOWHERE      │
        │ Load history: NONE  │
        └────────┬────────────┘
                 │
                 ▼
        ┌────────────────────────────────┐
        │ Call Claude API:               │
        │                                │
        │ messages=[                     │
        │   {                            │
        │    "role": "user",             │
        │    "content": "How do I ..."   │
        │   }                            │
        │ ]                              │
        │                                │
        │ ❌ NO SYSTEM CONTEXT           │
        │ ❌ NO PREVIOUS TURNS           │
        │ ❌ NO CAPSULE INFO             │
        └────────┬───────────────────────┘
                 │
                 ▼
        Claude gives generic answer
        (lacks BuilderOS context)
                 │
                 ▼
        Server streams back
        in 100-char chunks
                 │
                 ▼
        ┌──────────────────────────────────┐
        │ iOS App displays response        │
        │ ChatPersistenceManager saves     │
        │ to local UserDefaults            │
        │ (NOT sent back to server)        │
        └──────────────────────────────────┘
                 │
                 ▼
        User asks follow-up:
        "Can I automate deployment?"
                 │
                 ▼
        ❌ CONTEXT LOST ❌
        │
        Previous message about deployment
        is NOT in Claude context
        │
        ▼
        New WebSocket connection
        (or new message on existing connection)
        │
        ▼
        Server has zero history
        │
        ▼
        Claude API gets:
        messages=[
          {"role": "user", "content": "Can I automate deployment?"}
        ]
        │
        ▼
        Claude responds without knowledge
        that this is follow-up to deployment question
```

## 2. What Should Happen: BridgeHub Relay Flow

```
User Types: "How do I deploy a capsule?"
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│ iOS App - ClaudeAgentService                           │
│ Sends:                                                  │
│ {                                                       │
│   "content": "How do I deploy a capsule?",             │
│   "session_id": "mobile-sess-abc123",   ← NEW         │
│   "device": "iphone-ty",                ← NEW         │
│   "capsule": "builderos-mobile"         ← NEW         │
│ }                                                       │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ WebSocket
                 │ (With session ID)
                 │
        ┌────────▼────────────────────┐
        │ Server receives message     │
        │ Session exists? Check DB    │
        │ Load previous messages      │
        │ Load agent task history     │
        │ Load user/capsule context   │
        └────────┬───────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────┐
        │ Load system context:             │
        │ - CLAUDE.md (full instructions)  │
        │ - Capsule specs                  │
        │ - Agent coordination rules       │
        │ - Task tracking state            │
        └────────┬───────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────────┐
        │ Call BridgeHub Relay:                │
        │                                      │
        │ POST node bridgehub.js              │
        │ {                                    │
        │   "action": "relay",                │
        │   "from": "mobile-app",             │
        │   "to": "codex",                    │
        │   "message": "How do I deploy...",  │
        │   "context": {                      │
        │     "session_id": "...",            │
        │     "conversation": [               │
        │       {msg}, {msg}, ...             │
        │     ],                              │
        │     "system_context": "CLAUDE.md",  │
        │     "agent_state": {...}            │
        │   }                                 │
        │ }                                    │
        └────────┬───────────────────────────┘
                 │
                 ▼
        ┌────────────────────────────────────┐
        │ BridgeHub Relay:                  │
        │                                    │
        │ 1. Build prompt with full history │
        │ 2. Spawn Claude Code CLI          │
        │    (loads Jarvis + CLAUDE.md)    │
        │ 3. Send message to Claude Code    │
        │ 4. Track session state            │
        │ 5. Execute any agents delegated   │
        │ 6. Collect results                │
        └────────┬───────────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────┐
        │ Jarvis processes:                │
        │                                  │
        │ - Full conversation context      │
        │ - System instructions from       │
        │   CLAUDE.md                      │
        │ - Agent coordination aware       │
        │ - Can delegate to agents         │
        │ - Tracks tasks                   │
        │                                  │
        │ Response:                        │
        │ "Based on our system, here's    │
        │  how to deploy a capsule..."    │
        │                                  │
        │ If needed: Delegating to        │
        │ 🏗️ System Architect...          │
        └────────┬───────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────────┐
        │ Server receives response:            │
        │ - Full answer                        │
        │ - Agent task results (if any)       │
        │ - Updated session state             │
        │ - Context metadata                  │
        └────────┬───────────────────────────┘
                 │
                 ▼
        Store in database:
        │ - Save message to session
        │ - Update agent task status
        │ - Update context state
        │
        ▼
        ┌──────────────────────────────────────┐
        │ Stream to iOS app:                   │
        │ - Response chunks                    │
        │ - Agent execution status             │
        │ - Task metadata                      │
        │ - Updated conversation history       │
        └────────┬───────────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────────┐
        │ iOS App displays:                    │
        │                                      │
        │ "Based on our system, here's how   │
        │  to deploy a capsule:               │
        │  1. Create spec...                  │
        │  2. Run validation...               │
        │  3. Execute pipeline..."            │
        │                                      │
        │ [Loading: 🏗️ System Architect...]   │
        │                                      │
        │ Once agent completes:               │
        │ [✅] Architecture recommendations   │
        │      applied                        │
        └──────────────────────────────────────┘
                 │
                 ▼
        User asks: "Can I automate deployment?"
                 │
                 ▼
        ✅ CONTEXT PRESERVED ✅
        │
        Server loads full session:
        - Previous deployment question
        - Deployment answer
        - Agent results
        - Full conversation thread
        │
        ▼
        Send to BridgeHub Relay with:
        - Full conversation history
        - Previous agent results
        - Updated system context
        │
        ▼
        Jarvis responds with context:
        "Yes, you can automate with n8n.
         Here's how based on what we discussed..."
        │
        ▼
        Conversation continues with
        full awareness of previous exchanges
```

## 3. Message Structure Comparison

### Current (Broken)

```swift
// What iOS sends:
{
  "content": "user message"
}

// No session tracking
// No context metadata
// No agent coordination info
```

```python
# What server does with it:
messages = [
  {"role": "user", "content": content}  # THAT'S IT
]

# No conversation history
# No system context
# No previous turns
```

### Fixed (BridgeHub Relay)

```swift
// What iOS should send:
{
  "content": "user message",
  "session_id": "mobile-sess-abc123",
  "device": "iphone-ty",
  "capsule": "builderos-mobile",
  "mode": "coordination",  // Request full agent execution
  "metadata": {
    "timestamp": "2025-10-27T18:45:00Z",
    "previous_tasks": ["task-1", "task-2"]
  }
}
```

```python
# What server should do:
# 1. Load session from database
session = db.get_session(session_id)

# 2. Build full context
context = {
  "session_id": session_id,
  "device": device,
  "capsule": capsule,
  "conversation_history": session.messages,  # All previous messages
  "agent_tasks": session.agent_tasks,        # Pending/completed tasks
  "system_context": load_claude_md(),        # Full CLAUDE.md
  "capsule_context": load_capsule_specs()    # Capsule specs
}

# 3. Call BridgeHub relay
result = await bridgehub_relay(
  from="mobile-app",
  to="codex",
  message=content,
  context=context
)

# 4. Store response in session
session.add_message("user", content)
session.add_message("assistant", result.reply)
session.agent_tasks.extend(result.tasks)
db.save_session(session)

# 5. Stream back to iOS
for chunk in result.chunks:
  ws.send_json({"type": "message", "content": chunk})
```

## 4. Data Storage Layers (Current vs. Fixed)

### Current (Broken)

```
iOS Device                  Server                Desktop Jarvis
─────────                  ──────                ──────────
UserDefaults          No persistent storage     CLAUDE.md + MCP
(device-local)        (Zero history)            (Full context)
│                        │                         │
│                        │                         │
│ No sync               │ No session DB            │ No awareness
│ Device-isolated       │ No message store         │ of mobile
│ Not shared            │ No task tracking         │ context
│                        │                         │
└────────────┬───────────┴──────────┬──────────────┘
             │                      │
          DISCONNECTED - Each system operates alone
```

### Fixed (BridgeHub Relay)

```
iOS Device                  Server                Desktop Jarvis
─────────                  ──────                ──────────
UserDefaults          Session Database        CLAUDE.md + MCP
(cache)               - Messages               - Full context
│                     - Agent tasks            - Agent state
│                     - Context                - Task tracking
│                     - Device metadata        - Memory
│                        │                        │
│ ◄────────────────────────────────────────────► │
│        Bidirectional Sync via BridgeHub Relay
│                        │                        │
└────────────┬───────────┴──────────┬──────────────┘
             │                      │
        INTEGRATED - Full agent coordination
```

## 5. Session Lifecycle (Fixed)

```
1. iOS App Creates Session
   │
   ▼
   User enters API key, enables coordination mode
   │
   ▼
   generateSessionID() → "mobile-sess-abc123"
   Store locally in UserDefaults
   │
   ▼

2. First Message
   │
   ▼
   Send: {"session_id": "mobile-sess-abc123", "content": "Hello"}
   │
   ▼
   Server: Check if session exists
   │       No → Create session in database
   │       Yes → Load session
   │
   ▼

3. Message Processing
   │
   ▼
   Build context from:
   ├─ Previous messages in session
   ├─ Agent task history
   ├─ System context (CLAUDE.md)
   ├─ Capsule context
   └─ Device metadata
   │
   ▼
   Call BridgeHub Relay with full context
   │
   ▼
   Jarvis processes with awareness
   │
   ▼

4. Store Results
   │
   ▼
   Add message to session
   Add any agent tasks
   Update context state
   Save to database
   │
   ▼

5. Multi-Turn Conversation
   │
   ▼
   Each subsequent message
   loads session history
   includes all previous context
   agents are aware of prior turns
   │
   ▼

6. Session Lifecycle
   │
   ▼
   Active: Last message < 24 hours
   Idle: Last message > 24 hours
   Archived: User-initiated or > 7 days
   │
   ▼
   Can retrieve anytime
   Full history preserved
   Can resume conversation
```

## 6. Agent Execution Flow (Current vs. Fixed)

### Current (Broken)

```
Claude responds:
"I'm delegating to 📱 Mobile Dev to build the UI..."
│
▼
Mobile App receives response
│
▼
ClaudeCodeParser.extractAgentDelegation()
│
▼
Extracts: agent="📱 Mobile Dev", task="build the UI"
│
▼
Displays to user:
"📱 Mobile Dev → Building the UI"
│
▼
❌ NOTHING HAPPENS ❌
│
Agent never executes
No results returned
Task never tracked
```

### Fixed (BridgeHub Relay)

```
Claude (via BridgeHub) responds:
"I'm delegating to 📱 Mobile Dev to build the UI..."
│
▼
Server receives:
- Response text
- Agent task: {"agent": "📱 Mobile Dev", "task": "build the UI", "task_id": "task-456"}
│
▼
BridgeHub Relay executes agent:
- Invokes 📱 Mobile Dev agent
- Passes full context
- Waits for completion
- Captures results
│
▼
Agent executes:
- Receives: context + task + history
- Performs work
- Returns: {"status": "complete", "results": "..."}
│
▼
Server stores:
- Agent task result
- Updated context
- Execution metadata
│
▼
Stream to iOS:
- [Executing: 📱 Mobile Dev...]
- [✅ Complete: Mobile Dev built UI]
- [Results: ...]
│
▼
Mobile app displays:
- Agent status updates
- Execution progress
- Final results
- Can reference results in future messages
```

---

## Summary: The Gap

**Current:** Stateless message relay
- One message in
- One response out
- No history
- No agents
- No coordination

**Needed:** Stateful agent coordination
- Full conversation history
- Agent delegation + execution
- Multi-turn context
- Session persistence
- BridgeHub relay integration
