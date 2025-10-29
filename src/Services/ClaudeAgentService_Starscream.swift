//
//  ClaudeAgentService.swift (Starscream Implementation)
//  BuilderOS
//
//  Claude Agent SDK integration using Starscream WebSocket library
//  Replaces broken URLSessionWebSocketTask
//

import Foundation
import Combine
import os.log
import Starscream

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

/// Service for managing Claude Agent SDK WebSocket connections using Starscream
@MainActor
class ClaudeAgentService: ObservableObject, WebSocketDelegate {
    // MARK: - Published Properties

    @Published var messages: [ClaudeChatMessage] = []
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var connectionStatus: String = "Disconnected"

    // MARK: - Private Properties

    private var webSocket: WebSocket?
    private var currentResponseText: String = ""
    private var authenticationComplete = false

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
        let wsBase = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        guard let wsURL = URL(string: wsBase + "/api/claude/ws") else {
            throw ClaudeAgentError.invalidURL
        }

        os_log("🔌 Connecting to Claude Agent at: %{public}@", log: .default, type: .info, wsURL.absoluteString)
        print("🔌 Connecting to Claude Agent at: \(wsURL)")
        connectionStatus = "Connecting..."

        // Create Starscream WebSocket
        var request = URLRequest(url: wsURL)
        request.timeoutInterval = 10

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self

        print("📋 WebSocket created with Starscream")
        webSocket?.connect()
        print("▶️ WebSocket connecting...")

        // Wait for connection (max 5 seconds)
        var attempts = 0
        while !isConnected && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            attempts += 1
        }

        guard isConnected else {
            print("❌ WebSocket failed to connect after 5 seconds")
            throw ClaudeAgentError.connectionFailed
        }

        print("✅ WebSocket connected!")

        // Send API key
        let apiKey = APIConfig.apiToken
        print("🔑 Retrieved API key from Keychain (length: \(apiKey.count))")

        guard !apiKey.isEmpty else {
            print("❌ API key is empty!")
            connectionStatus = "Error: No API key"
            throw ClaudeAgentError.authenticationFailed
        }

        print("📤 Sending API key (first 8 chars: \(String(apiKey.prefix(8)))...)...")
        webSocket?.write(string: apiKey)
        print("✅ API key sent to WebSocket")

        // Wait for authentication response (max 5 seconds)
        authenticationComplete = false
        attempts = 0
        while !authenticationComplete && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            attempts += 1
        }

        guard authenticationComplete else {
            print("❌ Authentication timeout")
            throw ClaudeAgentError.authenticationFailed
        }

        print("✅ Successfully connected and authenticated!")
        connectionStatus = "Connected"
    }

    /// Disconnect from Claude Agent
    func disconnect() {
        guard isConnected else { return }

        webSocket?.disconnect()
        webSocket = nil
        isConnected = false
        authenticationComplete = false
        connectionStatus = "Disconnected"

        print("👋 Disconnected from Claude Agent")
    }

    // MARK: - Message Handling

    /// Send message to Claude Agent
    func sendMessage(_ text: String, attachments: [ChatAttachment]) async throws {
        guard isConnected else {
            throw ClaudeAgentError.notConnected
        }

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        print("📤 Sending message: \(text.prefix(50))...")
        if !attachments.isEmpty {
            print("📎 Attachments will be ignored in backup Starscream implementation")
        }

        // Add user message to UI
        let userMessage = ClaudeChatMessage(text: text, isUser: true)
        messages.append(userMessage)

        // Send to WebSocket
        let messageJSON = ["content": text]
        let data = try JSONEncoder().encode(messageJSON)
        let jsonString = String(data: data, encoding: .utf8)!

        webSocket?.write(string: jsonString)

        // Set loading state
        isLoading = true
        currentResponseText = ""
    }

    // MARK: - WebSocketDelegate Methods

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("✅ Starscream: WebSocket connected")
            print("📋 Headers: \(headers)")
            Task { @MainActor in
                self.isConnected = true
            }

        case .disconnected(let reason, let code):
            print("👋 Starscream: WebSocket disconnected - Code: \(code), Reason: \(reason)")
            Task { @MainActor in
                self.isConnected = false
                self.authenticationComplete = false
                self.connectionStatus = "Disconnected"
                self.isLoading = false
            }

        case .text(let text):
            print("📬 Starscream: Received text: \(text.prefix(100))...")
            Task { @MainActor in
                await self.handleReceivedText(text)
            }

        case .binary(let data):
            print("📦 Starscream: Received binary data: \(data.count) bytes")

        case .ping:
            print("🏓 Starscream: Received ping")

        case .pong:
            print("🏓 Starscream: Received pong")

        case .viabilityChanged(let isViable):
            print("🔄 Starscream: Viability changed: \(isViable)")

        case .reconnectSuggested(let shouldReconnect):
            print("🔄 Starscream: Reconnect suggested: \(shouldReconnect)")

        case .cancelled:
            print("❌ Starscream: Connection cancelled")
            Task { @MainActor in
                self.isConnected = false
                self.authenticationComplete = false
            }

        case .error(let error):
            print("❌ Starscream: Error: \(String(describing: error))")
            Task { @MainActor in
                self.connectionStatus = "Error: \(error?.localizedDescription ?? "Unknown")"
            }

        case .peerClosed:
            print("👋 Starscream: Peer closed connection")
            Task { @MainActor in
                self.isConnected = false
                self.authenticationComplete = false
            }
        }
    }

    // MARK: - Message Processing

    private func handleReceivedText(_ text: String) async {
        // First message after API key should be "authenticated"
        if !authenticationComplete && text == "authenticated" {
            print("✅ Authentication successful!")
            authenticationComplete = true
            return
        }

        // Try to decode as JSON response
        guard let data = text.data(using: .utf8),
              let response = try? JSONDecoder().decode(ClaudeResponse.self, from: data) else {
            print("⚠️ Failed to decode message as JSON: \(text)")
            return
        }

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

        case "ready":
            print("✅ Claude Agent ready: \(response.content)")
            authenticationComplete = true

        case "error":
            print("❌ Claude Agent error: \(response.content)")
            isLoading = false

            // Show error message
            messages.append(ClaudeChatMessage(
                text: "Error: \(response.content)",
                isUser: false
            ))

        default:
            print("⚠️ Unknown message type: \(response.type)")
        }

        // Reset loading state after receiving message
        isLoading = false
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
