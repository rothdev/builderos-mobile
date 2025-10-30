//
//  CodexAgentService.swift
//  BuilderOS
//
//  WebSocket transport for Codex CLI sessions (via Cloudflare tunnel).
//

import Foundation
import os.log
import Starscream
import UIKit

/// Manages Codex CLI WebSocket connections using Starscream.
@MainActor
class CodexAgentService: ChatAgentServiceBase, @preconcurrency WebSocketDelegate {
    private var webSocket: WebSocket?
    private var authenticationComplete = false
    private var authenticationReceived = false
    private var currentResponseText: String = ""

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

    init(sessionId: String) {
        // Generate persistent device ID (shared with ClaudeAgentService)
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

        print("📋 Codex session ID: \(self.sessionId)")
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

    override func connect() async throws {
        // Create detached task to prevent view lifecycle cancellation
        connectionTask = Task.detached { [weak self] in
            guard let self else { throw CodexAgentError.connectionFailed }
            try await self.connectInternal(cancelExistingTask: true)
        }
        try await connectionTask?.value
    }

    private func connectInternal(cancelExistingTask: Bool) async throws {
        let currentlyConnected = await MainActor.run { isConnected }
        guard !currentlyConnected else {
            print("⚠️ Already connected to Codex")
            return
        }

        let currentlyConnecting = await MainActor.run { isConnecting }
        guard !currentlyConnecting else {
            print("⏳ Codex connection already in progress")
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

        let baseURL = APIConfig.baseURL
        let wsBase = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")

        guard let wsURL = URL(string: wsBase + "/api/codex/ws") else {
            throw CodexAgentError.invalidURL
        }

        os_log("🔌 Connecting to Codex at: %{public}@", log: .default, type: .info, wsURL.absoluteString)
        print("🔌 Connecting to Codex at: \(wsURL)")
        await MainActor.run { connectionStatus = "Connecting..." }

        var request = URLRequest(url: wsURL)
        request.timeoutInterval = 120  // Increase timeout for long Codex CLI responses (can take 60+ seconds)

        let socket = WebSocket(request: request)
        socket.delegate = self
        socket.respondToPingWithPong = true
        await MainActor.run { webSocket = socket }

        socket.connect()
        print("▶️ Codex WebSocket connecting...")

        var attempts = 0
        while await MainActor.run(body: { !isConnected }) && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }

        let finalConnected = await MainActor.run { isConnected }
        guard finalConnected else {
            print("❌ Codex WebSocket timed out")
            throw CodexAgentError.connectionFailed
        }

        print("✅ Codex WebSocket connected")

        let apiKey = APIConfig.apiToken
        guard !apiKey.isEmpty else {
            print("❌ API key is empty for Codex")
            await MainActor.run { connectionStatus = "Error: No API key" }
            throw CodexAgentError.authenticationFailed
        }

        await MainActor.run {
            authenticationReceived = false
            webSocket?.write(string: apiKey)
        }
        print("📤 API key sent to Codex WebSocket")

        // Wait for "authenticated" text response (max 5 seconds)
        attempts = 0
        print("⏳ Waiting for Codex authentication confirmation...")
        while await MainActor.run(body: { !authenticationReceived }) && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }

        let finalAuthReceived = await MainActor.run { authenticationReceived }
        guard finalAuthReceived else {
            print("❌ Codex authentication timeout (no 'authenticated' message)")
            throw CodexAgentError.authenticationFailed
        }
        print("✅ Codex authentication confirmed by server")

        // Send session configuration with working directory
        let sessionConfig: [String: Any] = [
            "working_directory": "/Users/Ty/BuilderOS"
        ]
        let configData = try JSONSerialization.data(withJSONObject: sessionConfig)
        let configString = String(data: configData, encoding: .utf8)!
        print("📤 Sending Codex session config: \(configString)")
        await MainActor.run { webSocket?.write(string: configString) }
        print("✅ Codex session config sent (working_directory: /Users/Ty/BuilderOS)")

        // Wait for "ready" JSON message (max 5 seconds)
        await MainActor.run { authenticationComplete = false }
        attempts = 0
        print("⏳ Waiting for Codex 'ready' message...")
        while await MainActor.run(body: { !authenticationComplete }) && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }

        let finalAuthComplete = await MainActor.run { authenticationComplete }
        guard finalAuthComplete else {
            print("❌ Codex ready timeout")
            throw CodexAgentError.authenticationFailed
        }

        await MainActor.run { connectionStatus = "Connected" }
        print("✅ Codex session ready")
        await startHeartbeat()
        await cancelReconnect()
    }

    override func disconnect() {
        print("🔴 Disconnecting Codex session: \(sessionId)")
        print("   Setting isUserInitiatedDisconnect = true")

        isUserInitiatedDisconnect = true
        super.disconnect()  // Mark shouldMaintainConnection = false

        Task { @MainActor in
            print("   @MainActor: Cancelling reconnection task...")
            reconnectionTask?.cancel()
            reconnectionTask = nil
            print("   @MainActor: Invalidating heartbeat timer...")
            heartbeatTimer?.invalidate()
            heartbeatTimer = nil
        }

        print("   Disconnecting Codex WebSocket...")
        webSocket?.delegate = nil  // Clear delegate to break retain cycle
        webSocket?.disconnect()
        webSocket = nil

        // CRITICAL: Set connection state on MainActor to avoid race conditions
        Task { @MainActor in
            print("   @MainActor: Setting isConnected = false")
            isConnected = false
            authenticationComplete = false
            connectionStatus = "Disconnected"
            print("   @MainActor: Disconnect state changes complete")
        }

        // Send backend API request to close session
        Task {
            await closeBackendSession()
        }

        print("👋 Disconnected from Codex")
    }

    /// Close the backend CLI session via API
    private func closeBackendSession() async {
        let baseURL = APIConfig.baseURL
        let closeURL = "\(baseURL)/api/codex/session/\(sessionId)/close"

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

    override func sendMessage(_ text: String, attachments: [ChatAttachment]) async throws {
        guard isConnected else {
            throw CodexAgentError.notConnected
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        // Mark that user has sent their first message (enables error display)
        if !firstUserMessageSent {
            firstUserMessageSent = true
            print("✅ First user message sent - error display now enabled")
        }

        print("📤 Sending Codex message: \(trimmed.prefix(60))…")
        if !attachments.isEmpty {
            print("📎 Sending \(attachments.count) attachment(s) with Codex message")
        }

        let sanitizedAttachments = attachments.filter { $0.remoteURL != nil }
        let userMessage = ClaudeChatMessage(
            text: trimmed,
            isUser: true,
            attachments: sanitizedAttachments
        )
        messages.append(userMessage)
        trimMessagesIfNeeded()  // Prevent unbounded memory growth

        // Send to WebSocket with session persistence fields
        var payload: [String: Any] = [
            "content": trimmed,
            "session_id": self.sessionId,
            "device_id": self.deviceId,
            "chat_type": "codex"
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
                payload["attachments"] = attachmentsPayload
            }
        }
        let data = try JSONSerialization.data(withJSONObject: payload)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw CodexAgentError.invalidMessageFormat
        }

        print("📤 Codex JSON with session fields: \(jsonString)")
        webSocket?.write(string: jsonString)

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
                    print("🏓 Sending heartbeat ping to Codex")
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
            print("🔌 Codex reconnect skipped (user initiated disconnect)")
            isUserInitiatedDisconnect = false
            return
        }

        guard !isConnecting, !isConnected else {
            print("🔌 Codex reconnect skipped (already connecting or connected)")
            return
        }

        if reconnectionTask != nil {
            print("🔁 Codex reconnect already scheduled")
            return
        }

        print("🔁 Scheduling Codex reconnect in \(reconnectDelay)s (reason: \(reason))")
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
                    print("⚠️ Codex auto-reconnect failed: \(error.localizedDescription)")
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

    // MARK: - WebSocketDelegate

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("✅ Codex WebSocket connected (headers: \(headers))")
            Task { @MainActor in
                self.isConnected = true
                await self.cancelReconnect()
            }

        case .disconnected(let reason, let code):
            print("👋 Codex WebSocket disconnected - Code: \(code), Reason: \(reason)")
            Task { @MainActor in
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
            print("📬 Codex received text: \(text.prefix(120))…")
            Task { @MainActor in
                await self.handleReceivedText(text)
            }

        case .binary(let data):
            print("📦 Codex received binary data (\(data.count) bytes)")

        case .ping:
            print("🏓 Codex ping received")

        case .pong:
            print("🏓 Codex pong received")

        case .viabilityChanged(let isViable):
            print("🔄 Codex viability changed: \(isViable)")

        case .reconnectSuggested(let shouldReconnect):
            print("🔄 Codex reconnect suggested: \(shouldReconnect)")
            if shouldReconnect {
                Task { @MainActor in
                    self.scheduleReconnect(reason: "Starscream suggested reconnect")
                }
            }

        case .cancelled:
            print("❌ Codex connection cancelled")
            Task { @MainActor in
                self.isConnected = false
                self.authenticationComplete = false
                await self.stopHeartbeat()
                self.webSocket?.delegate = nil
                self.webSocket = nil
                self.scheduleReconnect(reason: "Connection cancelled")
            }

        case .error(let error):
            print("❌ Codex WebSocket error: \(String(describing: error))")
            Task { @MainActor in
                self.connectionStatus = "Error: \(error?.localizedDescription ?? "Unknown")"
                self.isLoading = false
                await self.stopHeartbeat()
                self.webSocket?.delegate = nil
                self.webSocket = nil
                self.scheduleReconnect(reason: "Error: \(error?.localizedDescription ?? "unknown")")
            }

        case .peerClosed:
            print("👋 Codex peer closed connection")
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

    /// Remove TTS tags only (lightweight, safe for streaming)
    private func removeTTSTags(_ text: String) -> String {
        return text.replacingOccurrences(
            of: "<tts-summary>.*?</tts-summary>",
            with: "",
            options: .regularExpression
        )
    }

    private func handleReceivedText(_ text: String) async {
        print("🔍 [DEBUG] ========================================")
        print("🔍 [DEBUG] Codex handleReceivedText called")
        print("🔍 [DEBUG] Full text length: \(text.count)")
        print("🔍 [DEBUG] Full text: \(text)")
        print("🔍 [DEBUG] Current message count: \(messages.count)")
        print("🔍 [DEBUG] isLoading: \(isLoading), authComplete: \(authenticationComplete), authReceived: \(authenticationReceived)")
        print("🔍 [DEBUG] ========================================")

        if text == "error:invalid_api_key" {
            print("❌ Codex authentication failed: invalid API key")
            connectionStatus = "Error: Invalid API key"
            isLoading = false
            authenticationComplete = false
            authenticationReceived = false
            return
        } else if text.hasPrefix("error:") {
            print("❌ Codex server returned error: \(text)")
            let errorMessage = text.replacingOccurrences(of: "error:", with: "").capitalized
            connectionStatus = "Error: \(errorMessage)"
            isLoading = false
            authenticationComplete = false
            authenticationReceived = false
            return
        }

        if text == "authenticated" {
            print("✅ Codex authentication acknowledged")
            authenticationReceived = true
            return
        }

        // Handle session config confirmation (server may echo back the config we sent)
        if text.contains("working_directory") && !authenticationComplete {
            print("📋 Received Codex session config confirmation/echo, ignoring")
            return
        }

        guard let data = text.data(using: .utf8),
              let response = try? JSONDecoder().decode(CodexResponse.self, from: data) else {
            print("⚠️ Codex failed to decode message as JSON")
            print("🔍 [DEBUG] Raw text that failed to decode: \(text)")
            print("🔍 [DEBUG] authenticationComplete: \(authenticationComplete)")
            print("🔍 [DEBUG] firstUserMessageSent: \(firstUserMessageSent)")

            // DEFENSIVE FIX: Only show errors after user has started chatting
            // This prevents protocol-level messages (connection handshake, authentication, etc.)
            // from appearing as error messages in the UI during the connection phase.
            //
            // Rationale:
            // - Connection phase may produce non-JSON messages (e.g., protocol confirmations)
            // - These should NEVER be visible to users as "Invalid message format" errors
            // - Real chat errors only happen AFTER user starts interacting
            // - If there's a genuine error, backend will send proper JSON with type="error"
            if firstUserMessageSent && authenticationComplete {
                print("⚠️ Codex unparseable message received AFTER user interaction - showing error")
                let errorMsg = ClaudeChatMessage(
                    text: "Error: Invalid message format",
                    isUser: false
                )
                messages.append(errorMsg)
                trimMessagesIfNeeded()  // Prevent unbounded memory growth
            } else {
                print("🔍 [DEBUG] Ignoring unparseable message (connection phase or pre-interaction)")
            }
            return
        }

        switch response.type {
        case "message", "stream":
            // Both "message" and "stream" events contain content that should be accumulated
            currentResponseText += response.content

            // During streaming, remove TTS tags for mobile display
            let displayText = removeTTSTags(currentResponseText)

            if let last = messages.last, !last.isUser {
                messages[messages.count - 1] = ClaudeChatMessage(
                    id: last.id,
                    text: displayText,
                    isUser: false
                )
            } else {
                messages.append(ClaudeChatMessage(
                    text: displayText,
                    isUser: false
                ))
                trimMessagesIfNeeded()  // Prevent unbounded memory growth
            }

        case "complete":
            print("✅ Codex message complete (usage: \(String(describing: response.usage)))")
            isLoading = false
            currentResponseText = ""

        case "ready":
            print("✅ Codex session ready: \(response.content)")
            authenticationComplete = true

        case "error":
            print("❌ Codex error: \(response.content)")
            isLoading = false
            currentResponseText = ""
            messages.append(ClaudeChatMessage(
                text: "Error: \(response.content)",
                isUser: false
            ))
            trimMessagesIfNeeded()  // Prevent unbounded memory growth

        default:
            print("⚠️ Codex unknown message type: \(response.type)")
        }
    }

    // MARK: - Cleanup

    override func clearMessages() {
        super.clearMessages()
        currentResponseText = ""
    }
}

// MARK: - Models & Errors

private struct CodexResponse: Codable {
    let type: String
    let content: String
    let timestamp: String
    let usage: CodexUsage?
}

private struct CodexUsage: Codable {
    let input_tokens: Int?
    let cached_input_tokens: Int?
    let output_tokens: Int?
}

enum CodexAgentError: LocalizedError {
    case invalidURL
    case authenticationFailed
    case connectionFailed
    case notConnected
    case invalidMessageFormat

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Codex WebSocket URL"
        case .authenticationFailed:
            return "Failed to authenticate with Codex"
        case .connectionFailed:
            return "Codex connection failed"
        case .notConnected:
            return "Not connected to Codex"
        case .invalidMessageFormat:
            return "Invalid message format"
        }
    }
}
