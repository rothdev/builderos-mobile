//
//  ClaudeCodeParser.swift
//  BuilderOS
//
//  Parser for Claude Code output streams into structured ChatMessage blocks
//

import Foundation

class ClaudeCodeParser {

    // MARK: - Parsing Methods

    /// Parse raw terminal output into structured ChatMessage objects
    static func parseOutput(_ output: String) -> [ChatMessage] {
        var messages: [ChatMessage] = []

        // Split by lines but preserve structure
        let lines = output.components(separatedBy: .newlines)
        var currentBlock = ""
        var currentType: ChatMessageType = .output

        for line in lines {
            // Detect thinking blocks
            if line.contains("<thinking>") {
                if !currentBlock.isEmpty {
                    messages.append(ChatMessage(type: currentType, content: currentBlock))
                    currentBlock = ""
                }
                currentType = .thinking
                currentBlock = line.replacingOccurrences(of: "<thinking>", with: "")
                continue
            }

            if line.contains("</thinking>") {
                currentBlock += "\n" + line.replacingOccurrences(of: "</thinking>", with: "")
                messages.append(ChatMessage(type: .thinking, content: currentBlock.trimmingCharacters(in: .whitespacesAndNewlines), isCollapsed: true))
                currentBlock = ""
                currentType = .output
                continue
            }

            // Detect tool calls (e.g., "🔧 Read(path)")
            if line.contains("🔧") || line.hasPrefix("Tool:") {
                if !currentBlock.isEmpty {
                    messages.append(ChatMessage(type: currentType, content: currentBlock))
                    currentBlock = ""
                }

                let toolMatch = extractToolCall(from: line)
                messages.append(ChatMessage(
                    type: .toolCall,
                    content: line,
                    metadata: toolMatch
                ))
                currentType = .output
                continue
            }

            // Detect agent delegations (e.g., "📱 Mobile Dev(task)")
            if line.contains("📱") || line.contains("🎨") || line.contains("🏛️") {
                if !currentBlock.isEmpty {
                    messages.append(ChatMessage(type: currentType, content: currentBlock))
                    currentBlock = ""
                }

                let agentMatch = extractAgentDelegation(from: line)
                messages.append(ChatMessage(
                    type: .agentDelegation,
                    content: line,
                    metadata: agentMatch
                ))
                currentType = .output
                continue
            }

            // Detect interactive prompts (y/n questions)
            if line.contains("(y/n)") || line.contains("(Y/N)") || line.contains("[y/n]") {
                if !currentBlock.isEmpty {
                    messages.append(ChatMessage(type: currentType, content: currentBlock))
                    currentBlock = ""
                }

                messages.append(ChatMessage(type: .prompt, content: line))
                currentType = .output
                continue
            }

            // Accumulate regular output
            if !line.isEmpty {
                currentBlock += (currentBlock.isEmpty ? "" : "\n") + line
            }
        }

        // Add remaining block
        if !currentBlock.isEmpty {
            messages.append(ChatMessage(type: currentType, content: currentBlock))
        }

        return messages
    }

    /// Parse user command input
    static func parseCommand(_ command: String) -> ChatMessage {
        return ChatMessage(type: .command, content: command)
    }

    // MARK: - Helper Methods

    /// Extract tool name and arguments from tool call line
    private static func extractToolCall(from line: String) -> [String: String]? {
        // Simple regex-like extraction
        // Example: "🔧 Read(/path/to/file)" -> tool: "Read", args: "/path/to/file"

        let cleaned = line.replacingOccurrences(of: "🔧", with: "").trimmingCharacters(in: .whitespaces)

        if let openParen = cleaned.firstIndex(of: "("),
           let closeParen = cleaned.lastIndex(of: ")") {
            let tool = String(cleaned[..<openParen])
            let args = String(cleaned[cleaned.index(after: openParen)..<closeParen])

            return ["tool": tool, "args": args]
        }

        return ["tool": cleaned, "args": ""]
    }

    /// Extract agent name and task from delegation line
    private static func extractAgentDelegation(from line: String) -> [String: String]? {
        // Example: "📱 Mobile Dev(Build chat interface)" -> agent: "📱 Mobile Dev", task: "Build chat interface"

        if let openParen = line.firstIndex(of: "("),
           let closeParen = line.lastIndex(of: ")") {
            let agent = String(line[..<openParen]).trimmingCharacters(in: .whitespaces)
            let task = String(line[line.index(after: openParen)..<closeParen])

            return ["agent": agent, "task": task]
        }

        return ["agent": line.trimmingCharacters(in: .whitespaces), "task": ""]
    }

    /// Detect ANSI color codes and preserve them
    static func preserveANSIColors(in text: String) -> String {
        // For now, just return as-is
        // Future: Convert ANSI codes to SwiftUI AttributedString colors
        return text
    }
}
