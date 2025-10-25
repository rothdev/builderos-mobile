//
//  ChatTerminalViewModel.swift
//  BuilderOS
//
//  State management for chat-style terminal interface
//

import Foundation
import Combine

@MainActor
class ChatTerminalViewModel: ObservableObject {
    // MARK: - Published State

    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var commandHistory: [String] = []
    @Published var historyIndex: Int = -1
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false

    // MARK: - Dependencies

    private let apiClient: BuilderOSAPIClient
    private var cancellables = Set<AnyCancellable>()

    // WebSocket connection
    private var webSocket: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var isReceiving = false

    // MARK: - Initialization

    init(apiClient: BuilderOSAPIClient) {
        self.apiClient = apiClient

        // Configure URLSession for WebSocket
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        self.urlSession = URLSession(configuration: configuration)

        setupBindings()
        loadMockMessages()

        // Auto-connect to terminal
        Task {
            await connect()
        }
    }

    // MARK: - Setup

    private func setupBindings() {
        // Bind API client connection status
        apiClient.$isConnected
            .assign(to: &$isConnected)
    }

    private func loadMockMessages() {
        // Load some initial mock messages for testing
        messages = [
            ChatMessage(type: .output, content: "BuilderOS Chat Terminal v1.0"),
            ChatMessage(type: .output, content: "Ready. Type a command or use voice input."),
        ]
    }

    // MARK: - Public Methods

    /// Send a command to the terminal
    func sendCommand(_ command: String) {
        guard !command.isEmpty else { return }

        // Add command to history
        commandHistory.append(command)
        historyIndex = commandHistory.count

        // Parse and add command message
        let commandMessage = ClaudeCodeParser.parseCommand(command)
        messages.append(commandMessage)

        // Clear input
        currentInput = ""

        // Send to API (stub for now)
        Task {
            await executeCommand(command)
        }
    }

    /// Navigate command history up (older)
    func navigateHistoryUp() {
        guard !commandHistory.isEmpty else { return }

        if historyIndex > 0 {
            historyIndex -= 1
            currentInput = commandHistory[historyIndex]
        }
    }

    /// Navigate command history down (newer)
    func navigateHistoryDown() {
        guard !commandHistory.isEmpty else { return }

        if historyIndex < commandHistory.count - 1 {
            historyIndex += 1
            currentInput = commandHistory[historyIndex]
        } else {
            historyIndex = commandHistory.count
            currentInput = ""
        }
    }

    /// Toggle collapsed state for thinking blocks
    func toggleThinkingBlock(messageId: UUID) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isCollapsed.toggle()
        }
    }

    /// Handle voice input completion
    func handleVoiceInput(_ text: String) {
        currentInput = text
        // Auto-send after voice input? Or let user review first?
        // For now, just populate the input field
    }

    /// Respond to interactive prompt (y/n)
    func respondToPrompt(_ response: String) {
        sendCommand(response)
    }

    /// Clear all messages
    func clearMessages() {
        messages = []
        loadMockMessages()
    }

    // MARK: - Private Methods

    /// Connect to WebSocket terminal
    private func connect() async {
        guard webSocket == nil else { return }

        // Construct WebSocket URL
        var wsURL = APIConfig.tunnelURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")

        if !wsURL.hasSuffix("/") {
            wsURL += "/"
        }
        wsURL += "api/terminal/ws"

        guard let url = URL(string: wsURL) else {
            print("❌ Invalid WebSocket URL: \(wsURL)")
            return
        }

        print("🔌 Connecting to: \(wsURL)")

        // Create WebSocket task
        webSocket = urlSession.webSocketTask(with: url)
        webSocket?.resume()

        // Authenticate
        do {
            try await webSocket?.send(.string(APIConfig.apiToken))
            isConnected = true
            print("✅ WebSocket connected and authenticated")

            // Start receiving messages
            await receiveMessages()
        } catch {
            print("❌ WebSocket connection error: \(error)")
            isConnected = false
        }
    }

    /// Disconnect from WebSocket
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        isConnected = false
        isReceiving = false
        print("🔌 WebSocket disconnected")
    }

    /// Receive messages from WebSocket
    private func receiveMessages() async {
        guard !isReceiving else { return }
        isReceiving = true

        while let webSocket = webSocket {
            do {
                let message = try await webSocket.receive()

                switch message {
                case .string(let text):
                    // Parse Claude Code output and add to messages
                    let parsedMessages = ClaudeCodeParser.parseOutput(text)
                    messages.append(contentsOf: parsedMessages)
                    print("📥 Received: \(text.prefix(100))...")

                case .data(let data):
                    // Convert binary to string
                    if let text = String(data: data, encoding: .utf8) {
                        let parsedMessages = ClaudeCodeParser.parseOutput(text)
                        messages.append(contentsOf: parsedMessages)
                    }

                @unknown default:
                    break
                }
            } catch {
                print("❌ WebSocket receive error: \(error)")
                isConnected = false
                isReceiving = false
                break
            }
        }
    }

    /// Execute command via WebSocket
    private func executeCommand(_ command: String) async {
        isLoading = true
        defer { isLoading = false }

        guard let webSocket = webSocket else {
            print("❌ Not connected to WebSocket")
            // Show error message
            let errorMessage = ChatMessage(type: .error, content: "Not connected. Reconnecting...")
            messages.append(errorMessage)

            // Try to reconnect
            await connect()
            return
        }

        do {
            // Send command to WebSocket
            try await webSocket.send(.string(command))
            print("📤 Sent command: \(command)")
        } catch {
            print("❌ Failed to send command: \(error)")
            let errorMessage = ChatMessage(type: .error, content: "Failed to send: \(error.localizedDescription)")
            messages.append(errorMessage)
        }
    }

    // MARK: - Preview Helpers

    static func mockWithMessages() -> ChatTerminalViewModel {
        let client = BuilderOSAPIClient.mockWithData()
        let viewModel = ChatTerminalViewModel(apiClient: client)
        viewModel.messages = ChatMessage.mockList
        viewModel.isConnected = true
        return viewModel
    }

    static func mockDisconnected() -> ChatTerminalViewModel {
        let client = BuilderOSAPIClient.mockDisconnected()
        let viewModel = ChatTerminalViewModel(apiClient: client)
        viewModel.isConnected = false
        return viewModel
    }
}
