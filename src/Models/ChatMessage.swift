//
//  ChatMessage.swift
//  BuilderOS
//
//  Chat message model for chat-style terminal interface
//

import Foundation

enum ChatMessageType {
    case command           // User input command
    case output            // Regular terminal output
    case thinking          // <thinking>...</thinking> blocks
    case toolCall          // 🔧 Tool(args) calls
    case agentDelegation   // 📱 Agent(task) delegations
    case error             // Error messages
    case prompt            // Interactive prompts (y/n questions)
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let type: ChatMessageType
    let content: String
    let timestamp: Date
    var isCollapsed: Bool  // For thinking blocks
    var metadata: [String: String]?  // Additional data (e.g., tool args, agent name)

    init(
        id: UUID = UUID(),
        type: ChatMessageType,
        content: String,
        timestamp: Date = Date(),
        isCollapsed: Bool = true,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.isCollapsed = isCollapsed
        self.metadata = metadata
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data
extension ChatMessage {
    static let mockCommand = ChatMessage(
        type: .command,
        content: "ls -la"
    )

    static let mockOutput = ChatMessage(
        type: .output,
        content: """
        total 32
        drwxr-xr-x  5 user  staff   160 Oct 24 20:48 .
        drwxr-xr-x  8 user  staff   256 Oct 24 16:58 ..
        -rw-r--r--  1 user  staff  1234 Oct 24 16:06 README.md
        """
    )

    static let mockThinking = ChatMessage(
        type: .thinking,
        content: "I need to check the current directory structure to understand the project layout...",
        isCollapsed: true
    )

    static let mockToolCall = ChatMessage(
        type: .toolCall,
        content: "Read(/Users/Ty/BuilderOS/README.md)",
        metadata: ["tool": "Read", "args": "/Users/Ty/BuilderOS/README.md"]
    )

    static let mockAgentDelegation = ChatMessage(
        type: .agentDelegation,
        content: "Delegating to Mobile Dev: Build chat terminal interface",
        metadata: ["agent": "📱 Mobile Dev", "task": "Build chat terminal interface"]
    )

    static let mockPrompt = ChatMessage(
        type: .prompt,
        content: "Do you want to proceed with this change? (y/n)"
    )

    static let mockList: [ChatMessage] = [
        mockCommand,
        mockThinking,
        mockToolCall,
        mockOutput,
        mockAgentDelegation,
        mockPrompt
    ]
}
