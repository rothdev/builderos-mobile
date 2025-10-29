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
import UIKit

/// Response from Claude Agent WebSocket
struct ClaudeResponse: Codable {
    let type: String
    let content: String
    let timestamp: String
}

/// Service for managing Claude Agent SDK WebSocket connections using Starscream
@MainActor
class ClaudeAgentService: ChatAgentServiceBase, @preconcurrency WebSocketDelegate {

    // MARK: - Private Properties

    private var webSocket: WebSocket?
    private var currentResponseText: String = ""
    private var authenticationComplete = false
    private var authenticationReceived = false
    private let persistenceManager = ChatPersistenceManager()
    private var heartbeatTimer: Timer?
    private var reconnectionTask: Task<Void, Never>?
    private var connectionTask: Task<Void, Error>?  // NEW: Store connection task to prevent cancellation
    private var isUserInitiatedDisconnect = false
    private var isConnecting = false
    private var firstUserMessageSent = false  // NEW: Track if user has sent their first message

    private let heartbeatInterval: TimeInterval = 25
    private let reconnectDelay: TimeInterval = 2.0

    // Session persistence fields
    private let sessionId: String
    private let deviceId: String

    // MARK: - Initialization

    init(sessionId: String) {
        // Generate persistent device ID (survives app reinstalls via identifierForVendor)
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            self.deviceId = vendorId
        } else {
            // Fallback to stored UUID if identifierForVendor unavailable
            if let storedDeviceId = UserDefaults.standard.string(forKey: "builderos_device_id") {
                self.deviceId = storedDeviceId
            } else {
                let newDeviceId = UUID().uuidString
                UserDefaults.standard.set(newDeviceId, forKey: "builderos_device_id")
                self.deviceId = newDeviceId
            }
        }

        // Use provided session ID (unique per chat)
        self.sessionId = sessionId

        super.init()

        // Load saved messages from persistence (using sessionId as key)
        messages = persistenceManager.loadMessages(for: sessionId)
        print("📂 Loaded \(messages.count) messages from persistence for session: \(sessionId)")
        print("📋 Claude session ID: \(self.sessionId)")
        print("📱 Device ID: \(self.deviceId)")
    }

    deinit {
        // Cancel tasks synchronously on deinit
        Task { @MainActor in
            heartbeatTimer?.invalidate()
            heartbeatTimer = nil
            reconnectionTask?.cancel()
            reconnectionTask = nil
        }
        connectionTask?.cancel()
    }

    // MARK: - Connection Management

    /// Connect to Claude Agent WebSocket endpoint
    override func connect() async throws {
        // Create detached task to prevent view lifecycle cancellation
        connectionTask = Task.detached { [weak self] in
            guard let self else { throw ClaudeAgentError.connectionFailed }
            try await self.connectInternal(cancelExistingTask: true)
        }
        try await connectionTask?.value
    }

    private func connectInternal(cancelExistingTask: Bool) async throws {
        let currentlyConnected = await MainActor.run { isConnected }
        guard !currentlyConnected else {
            print("⚠️ Already connected to Claude Agent")
            return
        }

        let currentlyConnecting = await MainActor.run { isConnecting }
        guard !currentlyConnecting else {
            print("⏳ Connection attempt already in progress")
            return
        }

        if cancelExistingTask {
            await cancelReconnect()
        }

        await MainActor.run {
            isUserInitiatedDisconnect = false
            isConnecting = true
        }
        defer {
            Task { @MainActor in
                isConnecting = false
            }
        }

        await stopHeartbeat()

        // Build WebSocket URL
        let baseURL = APIConfig.baseURL
        print("📋 DEBUG: APIConfig.baseURL = \(baseURL)")

        let wsBase = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        print("📋 DEBUG: WebSocket base = \(wsBase)")

        let fullWSURL = wsBase + "/api/claude/ws"
        print("📋 DEBUG: Full WebSocket URL = \(fullWSURL)")

        guard let wsURL = URL(string: fullWSURL) else {
            print("❌ ERROR: Invalid WebSocket URL: \(fullWSURL)")
            throw ClaudeAgentError.invalidURL
        }

        os_log("🔌 Connecting to Claude Agent at: %{public}@", log: .default, type: .info, wsURL.absoluteString)
        print("🔌 Connecting to Claude Agent at: \(wsURL)")
        await MainActor.run { connectionStatus = "Connecting..." }

        // Create Starscream WebSocket
        var request = URLRequest(url: wsURL)
        request.timeoutInterval = 120  // Increased to 120 seconds to handle long Claude CLI responses (can take 60+ seconds)

        let socket = WebSocket(request: request)
        socket.delegate = self
        socket.respondToPingWithPong = true
        await MainActor.run { webSocket = socket }

        print("📋 WebSocket created with Starscream")
        socket.connect()
        print("▶️ WebSocket connecting...")

        // Wait for connection (max 5 seconds)
        var attempts = 0
        print("⏳ Waiting for WebSocket connection (max 5 seconds)...")
        while await MainActor.run(body: { !isConnected }) && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            attempts += 1
            if attempts % 10 == 0 {
                let connected = await MainActor.run { isConnected }
                print("⏳ Still waiting... (\(Double(attempts) * 0.1)s elapsed, isConnected=\(connected))")
            }
        }

        let finalConnected = await MainActor.run { isConnected }
        guard finalConnected else {
            print("❌ WebSocket failed to connect after 5 seconds (attempts: \(attempts))")
            print("❌ Final state: isConnected = \(finalConnected)")
            throw ClaudeAgentError.connectionFailed
        }

        print("✅ WebSocket connected! (took \(Double(attempts) * 0.1)s)")

        // Send API key
        let apiKey = APIConfig.apiToken
        print("🔑 Retrieved API key from Keychain (length: \(apiKey.count))")

        guard !apiKey.isEmpty else {
            print("❌ API key is empty!")
            await MainActor.run { connectionStatus = "Error: No API key" }
            throw ClaudeAgentError.authenticationFailed
        }

        print("📤 Sending API key (first 8 chars: \(String(apiKey.prefix(8)))...)...")
        await MainActor.run {
            authenticationReceived = false
            webSocket?.write(string: apiKey)
        }
        print("✅ API key sent to WebSocket")

        // Wait for "authenticated" text response (max 5 seconds)
        attempts = 0
        print("⏳ Waiting for authentication confirmation...")
        while await MainActor.run(body: { !authenticationReceived }) && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            attempts += 1
        }

        let finalAuthReceived = await MainActor.run { authenticationReceived }
        guard finalAuthReceived else {
            print("❌ Authentication timeout (no 'authenticated' message received)")
            throw ClaudeAgentError.authenticationFailed
        }
        print("✅ Authentication confirmed by server")

        // Send session configuration with working directory
        let sessionConfig: [String: Any] = [
            "working_directory": "/Users/Ty/BuilderOS"
        ]
        let configData = try JSONSerialization.data(withJSONObject: sessionConfig)
        let configString = String(data: configData, encoding: .utf8)!
        print("📤 Sending session config: \(configString)")
        await MainActor.run { webSocket?.write(string: configString) }
        print("✅ Session config sent (working_directory: /Users/Ty/BuilderOS)")

        // Wait for "ready" message (max 15 seconds - server needs time to initialize Claude SDK)
        await MainActor.run { authenticationComplete = false }
        attempts = 0
        print("⏳ Waiting for 'ready' message from server (max 15 seconds)...")
        while await MainActor.run(body: { !authenticationComplete }) && attempts < 150 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            attempts += 1
            if attempts % 20 == 0 {
                let authComplete = await MainActor.run { authenticationComplete }
                print("⏳ Still waiting for ready... (\(Double(attempts) * 0.1)s elapsed, authenticationComplete=\(authComplete))")
            }
        }

        let finalAuthComplete = await MainActor.run { authenticationComplete }
        guard finalAuthComplete else {
            print("❌ Server initialization timeout (waited 15 seconds for 'ready' message)")
            print("❌ authenticationComplete = \(finalAuthComplete)")
            print("❌ Connection likely closed during initialization")
            throw ClaudeAgentError.authenticationFailed
        }

        print("✅ Successfully connected and authenticated! (took \(Double(attempts) * 0.1)s)")
        await MainActor.run { connectionStatus = "Connected" }
        await startHeartbeat()
        await cancelReconnect()
    }

    /// Disconnect from Claude Agent
    override func disconnect() {
        print("🔴 Disconnecting Claude Agent session: \(sessionId)")

        isUserInitiatedDisconnect = true
        super.disconnect()  // Mark shouldMaintainConnection = false

        Task { @MainActor in
            reconnectionTask?.cancel()
            reconnectionTask = nil
            heartbeatTimer?.invalidate()
            heartbeatTimer = nil
        }

        print("   Disconnecting WebSocket...")
        webSocket?.disconnect()
        webSocket = nil
        isConnected = false
        authenticationComplete = false
        connectionStatus = "Disconnected"

        // Send backend API request to close session
        Task {
            await closeBackendSession()
        }

        print("👋 Disconnected from Claude Agent")
    }

    /// Close the backend CLI session via API
    private func closeBackendSession() async {
        let baseURL = APIConfig.baseURL
        let closeURL = "\(baseURL)/api/claude/session/\(sessionId)/close"

        guard let url = URL(string: closeURL) else {
            print("❌ Invalid close session URL: \(closeURL)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(APIConfig.apiToken, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Backend session closed: \(sessionId)")
                } else {
                    print("⚠️ Backend session close returned status \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("⚠️ Failed to close backend session (will timeout naturally): \(error.localizedDescription)")
        }
    }

    // MARK: - Message Handling

    /// Send message to Claude Agent
    override func sendMessage(_ text: String, attachments: [ChatAttachment]) async throws {
        guard isConnected else {
            throw ClaudeAgentError.notConnected
        }

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Mark that user has sent their first message (enables error display)
        if !firstUserMessageSent {
            firstUserMessageSent = true
            print("✅ First user message sent - error display now enabled")
        }

        print("📤 Sending message: \(text.prefix(50))...")
        if !attachments.isEmpty {
            print("📎 Sending \(attachments.count) attachment(s)")
        }

        // Add user message to UI and persist
        let sanitizedAttachments = attachments.filter { $0.remoteURL != nil }
        let userMessage = ClaudeChatMessage(
            text: text,
            isUser: true,
            attachments: sanitizedAttachments
        )
        messages.append(userMessage)
        persistenceManager.saveMessage(userMessage, sessionId: self.sessionId)

        // Send to WebSocket with session persistence fields
        var messageJSON: [String: Any] = [
            "content": text,
            "session_id": self.sessionId,
            "device_id": self.deviceId,
            "chat_type": "jarvis"
        ]

        if !sanitizedAttachments.isEmpty {
            let attachmentsPayload: [[String: Any]] = sanitizedAttachments.compactMap { attachment in
                guard let remoteURL = attachment.remoteURL else { return nil }
                return [
                    "id": attachment.id.uuidString,
                    "filename": attachment.filename,
                    "mime_type": attachment.mimeType,
                    "size": attachment.size,
                    "type": attachment.type.rawValue,
                    "url": remoteURL
                ]
            }

            if !attachmentsPayload.isEmpty {
                messageJSON["attachments"] = attachmentsPayload
            }
        }
        let data = try JSONSerialization.data(withJSONObject: messageJSON)
        let jsonString = String(data: data, encoding: .utf8)!

        // DEBUG: Log exact JSON being sent
        print("📤 JSON length: \(jsonString.count)")
        print("📤 JSON with session fields: \(jsonString)")

        webSocket?.write(string: jsonString)

        // Set loading state
        isLoading = true
        currentResponseText = ""
    }

    // MARK: - Connection Keepalive & Recovery

    private func startHeartbeat() async {
        await stopHeartbeat()

        guard heartbeatInterval > 0 else { return }

        await MainActor.run {
            heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
                guard let self else { return }
                if self.isConnected, let socket = self.webSocket {
                    print("🏓 Sending heartbeat ping to Claude Agent")
                    socket.write(ping: Data())
                }
            }

            heartbeatTimer?.tolerance = 2
            if let timer = heartbeatTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }

    private func stopHeartbeat() async {
        await MainActor.run {
            heartbeatTimer?.invalidate()
            heartbeatTimer = nil
        }
    }

    private func scheduleReconnect(reason: String) {
        if isUserInitiatedDisconnect {
            print("🔌 Reconnect skipped (user initiated disconnect)")
            isUserInitiatedDisconnect = false
            return
        }

        guard !isConnecting, !isConnected else {
            print("🔌 Reconnect skipped (already connecting or connected)")
            return
        }

        if reconnectionTask != nil {
            print("🔁 Reconnect already scheduled")
            return
        }

        print("🔁 Scheduling reconnect in \(reconnectDelay)s (reason: \(reason))")
        reconnectionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.reconnectionTask = nil }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(self.reconnectDelay * 1_000_000_000))
                if Task.isCancelled {
                    return
                }

                do {
                    try await self.connectInternal(cancelExistingTask: false)
                    return
                } catch {
                    print("⚠️ Claude auto-reconnect failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func cancelReconnect() async {
        await MainActor.run {
            reconnectionTask?.cancel()
            reconnectionTask = nil
        }
    }

    // MARK: - WebSocketDelegate Methods

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("✅ Starscream: WebSocket connected")
            print("📋 Headers: \(headers)")
            print("📋 Client description: \(client)")
            Task { @MainActor in
                print("📋 Setting isConnected = true")
                self.isConnected = true
                await self.cancelReconnect()
            }

        case .disconnected(let reason, let code):
            print("👋 Starscream: WebSocket disconnected")
            print("   Code: \(code)")
            print("   Reason: \(reason)")
            print("   Previous state: isConnected=\(self.isConnected), authComplete=\(self.authenticationComplete)")
            Task { @MainActor in
                print("📋 Setting isConnected = false due to disconnection")
                self.isConnected = false
                self.authenticationComplete = false
                self.connectionStatus = "Disconnected: \(reason)"
                self.isLoading = false
                await self.stopHeartbeat()
                self.webSocket?.delegate = nil
                self.webSocket = nil
                self.scheduleReconnect(reason: "Server reported disconnect (\(reason))")
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
            if shouldReconnect {
                Task { @MainActor in
                    self.scheduleReconnect(reason: "Starscream suggested reconnect")
                }
            }

        case .cancelled:
            print("❌ Starscream: Connection cancelled")
            print("   Previous state: isConnected=\(self.isConnected), authComplete=\(self.authenticationComplete)")
            Task { @MainActor in
                print("📋 Setting isConnected = false due to cancellation")
                self.isConnected = false
                self.authenticationComplete = false
                await self.stopHeartbeat()
                self.webSocket?.delegate = nil
                self.webSocket = nil
                self.scheduleReconnect(reason: "Connection cancelled")
            }

        case .error(let error):
            print("❌ Starscream: Error occurred")
            print("   Error: \(String(describing: error))")
            if let err = error {
                print("   Localized: \(err.localizedDescription)")
            }
            print("   Previous state: isConnected=\(self.isConnected), authComplete=\(self.authenticationComplete)")
            Task { @MainActor in
                self.connectionStatus = "Error: \(error?.localizedDescription ?? "Unknown")"
                await self.stopHeartbeat()
                self.webSocket?.delegate = nil
                self.webSocket = nil
                self.scheduleReconnect(reason: "Error: \(error?.localizedDescription ?? "unknown")")
            }

        case .peerClosed:
            print("👋 Starscream: Peer closed connection")
            print("   Previous state: isConnected=\(self.isConnected), authComplete=\(self.authenticationComplete)")
            Task { @MainActor in
                self.isConnected = false
                self.authenticationComplete = false
                await self.stopHeartbeat()
                self.webSocket?.delegate = nil
                self.webSocket = nil
                self.scheduleReconnect(reason: "Peer closed connection")
            }
        }
    }

    // MARK: - Message Processing

    /// Clean up message text for display
    private func cleanMessageText(_ text: String) -> String {
        var cleaned = text

        // Remove <tts-summary> tags and their content
        cleaned = cleaned.replacingOccurrences(
            of: "<tts-summary>.*?</tts-summary>",
            with: "",
            options: .regularExpression
        )

        // Convert markdown headers to plain text
        cleaned = cleaned.replacingOccurrences(
            of: "### ",
            with: ""
        )
        cleaned = cleaned.replacingOccurrences(
            of: "## ",
            with: ""
        )
        cleaned = cleaned.replacingOccurrences(
            of: "# ",
            with: ""
        )

        // Convert markdown bold to plain text
        cleaned = cleaned.replacingOccurrences(
            of: "\\*\\*([^*]+)\\*\\*",
            with: "$1",
            options: .regularExpression
        )

        // Convert markdown italic to plain text
        cleaned = cleaned.replacingOccurrences(
            of: "\\*([^*]+)\\*",
            with: "$1",
            options: .regularExpression
        )

        // Remove markdown links but keep text
        cleaned = cleaned.replacingOccurrences(
            of: "\\[([^]]+)\\]\\([^)]+\\)",
            with: "$1",
            options: .regularExpression
        )

        // Clean up extra whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
    }

    private func handleReceivedText(_ text: String) async {
        // Device-specific diagnostic logging
        #if targetEnvironment(simulator)
        let environment = "SIMULATOR"
        #else
        let environment = "PHYSICAL DEVICE"
        #endif

        print("🔍 [DEBUG] ========================================")
        print("🔍 [DEBUG] Environment: \(environment)")
        print("🔍 [DEBUG] handleReceivedText called")
        print("🔍 [DEBUG] Full text length: \(text.count)")
        print("🔍 [DEBUG] Full text: \(text)")
        print("🔍 [DEBUG] Text encoding info: UTF8? \(text.data(using: .utf8) != nil)")
        print("🔍 [DEBUG] Text bytes (hex): \(text.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined(separator: " ") ?? "nil")")
        print("🔍 [DEBUG] Current message count: \(messages.count)")
        print("🔍 [DEBUG] isLoading: \(isLoading), authComplete: \(authenticationComplete), authReceived: \(authenticationReceived)")
        print("🔍 [DEBUG] ========================================")

        // Handle plain-text error responses (e.g., invalid API key) from the backend
        if text == "error:invalid_api_key" {
            print("❌ Authentication failed: invalid API key reported by server")
            connectionStatus = "Error: Invalid API key"
            isLoading = false
            authenticationComplete = false
            authenticationReceived = false
            return
        } else if text.hasPrefix("error:") {
            print("❌ Server returned error: \(text)")
            let errorMessage = text.replacingOccurrences(of: "error:", with: "").capitalized
            connectionStatus = "Error: \(errorMessage)"
            isLoading = false
            authenticationComplete = false
            authenticationReceived = false
            return
        }

        // First message after API key should be "authenticated"
        if text == "authenticated" {
            print("✅ Authentication successful! Received 'authenticated' confirmation")
            authenticationReceived = true
            return
        }

        // Handle session config confirmation (server may echo back the config we sent)
        if text.contains("working_directory") && !authenticationComplete {
            print("📋 Received session config confirmation/echo, ignoring")
            return
        }

        // Try to decode as JSON response
        guard let data = text.data(using: .utf8) else {
            print("⚠️ Failed to convert text to UTF8 data")
            print("🔍 [DEBUG] Text that failed UTF8 conversion: \(text)")
            print("🔍 [DEBUG] Text length: \(text.count)")
            return
        }

        // Try JSON decoding with detailed error reporting
        let decoder = JSONDecoder()
        guard let response = try? decoder.decode(ClaudeResponse.self, from: data) else {
            print("⚠️ Failed to decode message as JSON")
            print("🔍 [DEBUG] Raw text that failed to decode: \(text)")
            print("🔍 [DEBUG] Data size: \(data.count) bytes")
            print("🔍 [DEBUG] authenticationComplete: \(authenticationComplete)")
            print("🔍 [DEBUG] authenticationReceived: \(authenticationReceived)")

            // Try to decode as generic JSON to see what structure we got
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("🔍 [DEBUG] Message IS valid JSON but not ClaudeResponse structure")
                print("🔍 [DEBUG] JSON structure: \(jsonObject)")
            } else {
                print("🔍 [DEBUG] Message is NOT valid JSON at all")
                print("🔍 [DEBUG] Checking if it's a protocol message...")
                if text.contains("working_directory") {
                    print("🔍 [DEBUG] Contains 'working_directory' - might be config echo")
                }
                if text == "ready" || text == "authenticated" || text.hasPrefix("error:") {
                    print("🔍 [DEBUG] This is a known protocol message: \(text)")
                }
            }

            // DEFENSIVE FIX: Only show errors after user has started chatting
            // This prevents protocol-level messages (connection handshake, authentication, etc.)
            // from appearing as error messages in the UI during the connection phase.
            //
            // Rationale:
            // - Connection phase may produce non-JSON messages (e.g., protocol confirmations)
            // - These should NEVER be visible to users as "Invalid message format" errors
            // - Real chat errors only happen AFTER user starts interacting
            // - If there's a genuine error, backend will send proper JSON with type="error"
            if firstUserMessageSent {
                print("⚠️ Unparseable message received AFTER user interaction - showing error")
                let errorMsg = ClaudeChatMessage(
                    text: "Error: Invalid message format",
                    isUser: false
                )
                messages.append(errorMsg)
            } else {
                print("🔍 [DEBUG] Ignoring unparseable message during connection phase (no user interaction yet)")
            }
            return
        }

        switch response.type {
        case "message":
            // Append to current response (streaming)
            currentResponseText += response.content

            // Clean the accumulated text for display
            let cleanedText = cleanMessageText(currentResponseText)

            // Update or create Claude message
            if let lastMessage = messages.last, !lastMessage.isUser {
                // Update existing message (streaming)
                messages[messages.count - 1] = ClaudeChatMessage(
                    text: cleanedText,
                    isUser: false
                )
            } else {
                // Create new message
                messages.append(ClaudeChatMessage(
                    text: cleanedText,
                    isUser: false
                ))
            }
            // Keep loading until "complete" message

        case "complete":
            // Message complete - persist final message and reset loading state
            print("✅ Message complete")
            if let lastMessage = messages.last, !lastMessage.isUser {
                persistenceManager.saveMessage(lastMessage, sessionId: self.sessionId)
            }
            isLoading = false
            currentResponseText = ""

        case "ready":
            print("✅ Claude Agent ready: \(response.content)")
            authenticationComplete = true

        case "error":
            print("❌ Claude Agent error: \(response.content)")
            isLoading = false
            currentResponseText = ""

            // Show error message
            messages.append(ClaudeChatMessage(
                text: "Error: \(response.content)",
                isUser: false
            ))

        default:
            print("⚠️ Unknown message type: \(response.type)")
        }
    }

    // MARK: - Utility Methods

    /// Clear all messages from memory and persistent storage
    override func clearMessages() {
        super.clearMessages()
        currentResponseText = ""
        persistenceManager.clearMessages(for: self.sessionId)
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
