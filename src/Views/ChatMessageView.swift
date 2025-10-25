//
//  ChatMessageView.swift
//  BuilderOS
//
//  Individual message rendering for chat-style terminal
//

import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    let onToggleThinking: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch message.type {
            case .command:
                commandView
            case .output:
                outputView
            case .thinking:
                thinkingView
            case .toolCall:
                toolCallView
            case .agentDelegation:
                agentDelegationView
            case .error:
                errorView
            case .prompt:
                promptView
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Message Type Views

    private var commandView: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(">")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.green)

            Text(message.content)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
                .textSelection(.enabled)
        }
    }

    private var outputView: some View {
        Text(message.content)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.secondary)
            .textSelection(.enabled)
            .padding(.leading, 16) // Indent output
    }

    private var thinkingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: {
                onToggleThinking(message.id)
            }) {
                HStack {
                    Image(systemName: message.isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption)
                    Text("Thinking...")
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }

            if !message.isCollapsed {
                Text(message.content)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .textSelection(.enabled)
            }
        }
        .padding(.leading, 16)
    }

    private var toolCallView: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("🔧")
                .font(.body)

            VStack(alignment: .leading, spacing: 2) {
                if let tool = message.metadata?["tool"] {
                    Text(tool)
                        .font(.system(.callout, design: .monospaced, weight: .semibold))
                        .foregroundColor(.orange)
                }

                if let args = message.metadata?["args"], !args.isEmpty {
                    Text(args)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemOrange).opacity(0.1))
        .cornerRadius(8)
        .padding(.leading, 16)
    }

    private var agentDelegationView: some View {
        HStack(alignment: .top, spacing: 8) {
            if let agent = message.metadata?["agent"] {
                Text(agent)
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let task = message.metadata?["task"] {
                    Text(task)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.purple)
                }
            }
        }
        .padding(8)
        .background(Color(.systemPurple).opacity(0.1))
        .cornerRadius(8)
        .padding(.leading, 16)
    }

    private var errorView: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(message.content)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.red)
        }
        .padding(8)
        .background(Color(.systemRed).opacity(0.1))
        .cornerRadius(8)
        .padding(.leading, 16)
    }

    private var promptView: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.blue)

            Text(message.content)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(Color(.systemBlue).opacity(0.1))
        .cornerRadius(8)
        .padding(.leading, 16)
    }
}

// MARK: - Preview

#Preview("Command") {
    ChatMessageView(message: .mockCommand, onToggleThinking: { _ in })
        .padding()
}

#Preview("Output") {
    ChatMessageView(message: .mockOutput, onToggleThinking: { _ in })
        .padding()
}

#Preview("Thinking - Collapsed") {
    ChatMessageView(message: .mockThinking, onToggleThinking: { _ in })
        .padding()
}

#Preview("Thinking - Expanded") {
    var expandedThinking = ChatMessage.mockThinking
    expandedThinking.isCollapsed = false

    return ChatMessageView(message: expandedThinking, onToggleThinking: { _ in })
        .padding()
}

#Preview("Tool Call") {
    ChatMessageView(message: .mockToolCall, onToggleThinking: { _ in })
        .padding()
}

#Preview("Agent Delegation") {
    ChatMessageView(message: .mockAgentDelegation, onToggleThinking: { _ in })
        .padding()
}

#Preview("Prompt") {
    ChatMessageView(message: .mockPrompt, onToggleThinking: { _ in })
        .padding()
}

#Preview("All Types") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(ChatMessage.mockList) { message in
                ChatMessageView(message: message, onToggleThinking: { _ in })
            }
        }
        .padding()
    }
}
