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
    private var currentResponseText: String = ""

    private var heartbeatTimer: Timer?
    private var reconnectionTask: Task<Void, Never>?
    private var connectionTask: Task<Void, Error>?  // NEW: Store connection task to prevent cancellation
    private var isUserInitiatedDisconnect = false
    private var isConnecting = false

    private let heartbeatInterval: TimeInterval = 25
    private let reconnectDelay: TimeInterval = 2.0

    // Session persistence fields
    private let sessionId: String
    private let deviceId: String

    override init() {
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

        // Generate or load persistent session ID
        if let savedSessionId = UserDefaults.standard.string(forKey: "codex_session_id") {
            self.sessionId = savedSessionId
        } else {
            let newSessionId = "\(self.deviceId)-codex"
            UserDefaults.standard.set(newSessionId, forKey: "codex_session_id")
            self.sessionId = newSessionId
        }

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
        request.timeoutInterval = 30

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

        await MainActor.run { webSocket?.write(string: apiKey) }
        print("📤 API key sent to Codex WebSocket")

        await MainActor.run { authenticationComplete = false }
        attempts = 0
        while await MainActor.run(body: { !authenticationComplete }) && attempts < 50 {
            try await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }

        let finalAuthComplete = await MainActor.run { authenticationComplete }
        guard finalAuthComplete else {
            print("❌ Codex authentication timeout")
            throw CodexAgentError.authenticationFailed
        }

        await MainActor.run { connectionStatus = "Connected" }
        print("✅ Codex authenticated successfully")
        await startHeartbeat()
        await cancelReconnect()
    }

    override func disconnect() {
        print("🔴🔴🔴 CODEX DISCONNECT CALLED - THIS SHOULD NOT HAPPEN DURING TAB SWITCHES 🔴🔴🔴")
        print("   Full call stack:")
        Thread.callStackSymbols.forEach { print("     \($0)") }
        print("   Current state: isConnected=\(isConnected), isUserInitiatedDisconnect=\(isUserInitiatedDisconnect)")

        isUserInitiatedDisconnect = true
        super.disconnect()  // Mark shouldMaintainConnection = false

        Task { @MainActor in
            reconnectionTask?.cancel()
            reconnectionTask = nil
            heartbeatTimer?.invalidate()
            heartbeatTimer = nil
        }

        print("   Disconnecting Codex WebSocket...")
        webSocket?.disconnect()
        webSocket = nil
        isConnected = false
        authenticationComplete = false
        connectionStatus = "Disconnected"

        print("👋 Disconnected from Codex")
    }

    // MARK: - Message Handling

    override func sendMessage(_ text: String) async throws {
        guard isConnected else {
            throw CodexAgentError.notConnected
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        print("📤 Sending Codex message: \(trimmed.prefix(60))…")

        let userMessage = ClaudeChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)

        // Send to WebSocket with session persistence fields
        let payload: [String: Any] = [
            "content": trimmed,
            "session_id": self.sessionId,
            "device_id": self.deviceId,
            "chat_type": "codex"
        ]
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

    private func handleReceivedText(_ text: String) async {
        if text == "error:invalid_api_key" {
            print("❌ Codex authentication failed: invalid API key")
            connectionStatus = "Error: Invalid API key"
            isLoading = false
            authenticationComplete = false
            return
        } else if text.hasPrefix("error:") {
            print("❌ Codex server returned error: \(text)")
            let errorMessage = text.replacingOccurrences(of: "error:", with: "").capitalized
            connectionStatus = "Error: \(errorMessage)"
            isLoading = false
            authenticationComplete = false
            return
        }

        if !authenticationComplete && text == "authenticated" {
            print("✅ Codex authentication acknowledged")
            authenticationComplete = true
            return
        }

        guard let data = text.data(using: .utf8),
              let response = try? JSONDecoder().decode(CodexResponse.self, from: data) else {
            print("⚠️ Codex failed to decode JSON: \(text)")
            return
        }

        switch response.type {
        case "message":
            currentResponseText += response.content
            if let last = messages.last, !last.isUser {
                messages[messages.count - 1] = ClaudeChatMessage(
                    id: last.id,
                    text: currentResponseText,
                    isUser: false
                )
            } else {
                messages.append(ClaudeChatMessage(
                    text: currentResponseText,
                    isUser: false
                ))
            }

        case "stream":
            print("🔄 Codex stream event: \(response.content)")

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
