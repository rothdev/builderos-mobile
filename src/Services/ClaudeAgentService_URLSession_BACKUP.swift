//
//  ClaudeAgentService.swift
//  BuilderOS
//
//  Claude Agent SDK integration for real-time chat with full BuilderOS context
//

import Foundation
import Combine
import os.log

/// Chat message model for Claude Agent conversations
struct ClaudeChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date

    init(text: String, isUser: Bool, timestamp: Date = Date()) {
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }

    static func == (lhs: ClaudeChatMessage, rhs: ClaudeChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

/// Response from Claude Agent WebSocket
struct ClaudeResponse: Codable {
    let type: String
    let content: String
    let timestamp: String
}

/// Service for managing Claude Agent SDK WebSocket connections
@MainActor
class ClaudeAgentService: ObservableObject {
    // MARK: - Published Properties

    @Published var messages: [ClaudeChatMessage] = []
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var connectionStatus: String = "Disconnected"

    // MARK: - Private Properties

    private var webSocket: URLSessionWebSocketTask?
    private var currentResponseText: String = ""

    // MARK: - Initialization

    init() {
        // Load any saved messages from disk (future enhancement)
    }

    // MARK: - Connection Management

    /// Connect to Claude Agent WebSocket endpoint
    func connect() async throws {
        guard !isConnected else {
            print("⚠️ Already connected to Claude Agent")
            return
        }

        // Build WebSocket URL
        let baseURL = APIConfig.baseURL
        // Convert http:// to ws:// and https:// to wss://
        let wsBase = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        guard let wsURL = URL(string: wsBase + "/api/claude/ws") else {
            throw ClaudeAgentError.invalidURL
        }

        os_log("🔌 Connecting to Claude Agent at: %{public}@", log: .default, type: .info, wsURL.absoluteString)
        print("🔌 Connecting to Claude Agent at: \(wsURL)")
        connectionStatus = "Connecting..."

        // Create WebSocket task
        webSocket = URLSession.shared.webSocketTask(with: wsURL)
        print("📋 WebSocket created: \(webSocket != nil)")
        webSocket?.resume()
        print("▶️ WebSocket resumed")

        // CRITICAL: URLSessionWebSocketTask doesn't actually connect until first I/O
        // Send a ping and WAIT for it to complete before continuing
        print("🏓 Sending ping to force connection...")

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            webSocket?.sendPing { error in
                if let error = error {
                    print("❌ Ping failed: \(error)")
                } else {
                    print("✅ Ping succeeded - connection established")
                }
                continuation.resume()
            }
        }

        print("📊 WebSocket state after ping: \(webSocket?.state.rawValue ?? -1)")

        // Authenticate with API key
        let apiKey = APIConfig.apiToken
        print("🔑 Retrieved API key from Keychain (length: \(apiKey.count))")

        // Validate API key exists
        guard !apiKey.isEmpty else {
            print("❌ API key is empty!")
            connectionStatus = "Error: No API key"
            throw ClaudeAgentError.authenticationFailed
        }

        // Check WebSocket state before sending
        if let ws = webSocket {
            print("📊 WebSocket state before send: \(ws.state.rawValue)")
            // 0 = connecting, 1 = open, 2 = closing, 3 = closed
        }

        print("📤 Sending API key (first 8 chars: \(String(apiKey.prefix(8)))...)...")
        os_log("📤 Sending API key (length: %d)", log: .default, type: .info, apiKey.count)

        do {
            try await send(text: apiKey)
            print("✅ API key sent to WebSocket")

            // Verify state after send
            if let ws = webSocket {
                print("📊 WebSocket state after send: \(ws.state.rawValue)")
            }
        } catch {
            print("❌ Failed to send API key: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(String(describing: error))")
            connectionStatus = "Error: \(error.localizedDescription)"
            throw error
        }

        // Wait for authentication response
        print("👂 Waiting for auth response...")
        let authResponse = try await receiveText()
        print("📬 Received auth response: \(authResponse)")

        guard authResponse == "authenticated" else {
            throw ClaudeAgentError.authenticationFailed
        }

        print("✅ Authenticated with Claude Agent")

        // Wait for ready message
        let readyMessage = try await receiveJSON()

        if readyMessage.type == "ready" {
            print("✅ Claude Agent ready: \(readyMessage.content)")
            isConnected = true
            connectionStatus = "Connected"

            // Start listening for messages
            Task { await listen() }
        } else {
            throw ClaudeAgentError.connectionFailed
        }
    }

    /// Disconnect from Claude Agent
    func disconnect() {
        guard isConnected else { return }

        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        isConnected = false
        connectionStatus = "Disconnected"

        print("👋 Disconnected from Claude Agent")
    }

    // MARK: - Message Handling

    /// Send message to Claude Agent
    func sendMessage(_ text: String) async throws {
        guard isConnected else {
            throw ClaudeAgentError.notConnected
        }

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        print("📤 Sending message: \(text.prefix(50))...")

        // Add user message to UI
        let userMessage = ClaudeChatMessage(text: text, isUser: true)
        messages.append(userMessage)

        // Send to WebSocket
        let messageJSON = ["content": text]
        let data = try JSONEncoder().encode(messageJSON)
        let jsonString = String(data: data, encoding: .utf8)!

        try await send(text: jsonString)

        // Set loading state
        isLoading = true
        currentResponseText = ""
    }

    /// Listen for messages from Claude Agent
    private func listen() async {
        while isConnected {
            do {
                let response = try await receiveJSON()

                switch response.type {
                case "message":
                    // Append to current response (streaming)
                    currentResponseText += response.content

                    // Update or create Claude message
                    if let lastMessage = messages.last, !lastMessage.isUser {
                        // Update existing message
                        messages[messages.count - 1] = ClaudeChatMessage(
                            text: currentResponseText,
                            isUser: false
                        )
                    } else {
                        // Create new message
                        messages.append(ClaudeChatMessage(
                            text: currentResponseText,
                            isUser: false
                        ))
                    }

                case "error":
                    print("❌ Claude Agent error: \(response.content)")
                    isLoading = false

                    // Show error message
                    messages.append(ClaudeChatMessage(
                        text: "Error: \(response.content)",
                        isUser: false
                    ))

                case "ready":
                    print("✅ Claude Agent ready")

                default:
                    print("⚠️ Unknown message type: \(response.type)")
                }

                // Reset loading state after receiving message
                isLoading = false

            } catch {
                print("❌ Error receiving message: \(error)")
                isConnected = false
                connectionStatus = "Disconnected"
                isLoading = false
                break
            }
        }
    }

    // MARK: - WebSocket Helpers

    private func send(text: String) async throws {
        guard let webSocket = webSocket else {
            throw ClaudeAgentError.notConnected
        }

        let message = URLSessionWebSocketTask.Message.string(text)
        try await webSocket.send(message)
    }

    private func receiveText() async throws -> String {
        guard let webSocket = webSocket else {
            throw ClaudeAgentError.notConnected
        }

        let message = try await webSocket.receive()

        switch message {
        case .string(let text):
            return text
        case .data(let data):
            return String(data: data, encoding: .utf8) ?? ""
        @unknown default:
            throw ClaudeAgentError.invalidMessageFormat
        }
    }

    private func receiveJSON() async throws -> ClaudeResponse {
        let text = try await receiveText()
        let data = text.data(using: .utf8)!
        return try JSONDecoder().decode(ClaudeResponse.self, from: data)
    }

    // MARK: - Utility Methods

    /// Clear all messages
    func clearMessages() {
        messages.removeAll()
        currentResponseText = ""
    }
}

// MARK: - Errors

enum ClaudeAgentError: LocalizedError {
    case invalidURL
    case authenticationFailed
    case connectionFailed
    case notConnected
    case invalidMessageFormat

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .authenticationFailed:
            return "Failed to authenticate with Claude Agent"
        case .connectionFailed:
            return "Failed to connect to Claude Agent"
        case .notConnected:
            return "Not connected to Claude Agent"
        case .invalidMessageFormat:
            return "Invalid message format received"
        }
    }
}
