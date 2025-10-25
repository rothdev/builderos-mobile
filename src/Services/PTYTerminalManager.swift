//
//  PTYTerminalManager.swift
//  BuilderOS
//
//  Manages WebSocket connection to BuilderOS API terminal endpoint
//  Uses PTY protocol (binary data with ANSI escape codes)
//  This is a READ-ONLY terminal viewer for watching Claude Code/Codex output
//

import Foundation
import SwiftTerm
import Combine

/// Manages WebSocket connection and feeds PTY data to a terminal view
@MainActor
class PTYTerminalManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var isConnected = false
    @Published var connectionError: String?
    @Published var terminalOutput: Data = Data()

    // MARK: - WebSocket

    private var webSocket: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectTimer: Timer?
    private var pingTimer: Timer?

    // CRITICAL FIX: Lazy properties to avoid Keychain access during init
    // This prevents blocking main thread on app launch
    private var baseURL: String {
        return APIConfig.tunnelURL
    }

    private var apiKey: String {
        return APIConfig.apiToken
    }

    // MARK: - Initialization

    override init() {
        super.init()

        // Configure URLSession
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60  // Increased from 30s to 60s
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    // MARK: - Connection Management

    func connect() {
        guard !isConnected else { return }

        // Construct WebSocket URL
        var wsURL = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")

        if !wsURL.hasSuffix("/") {
            wsURL += "/"
        }
        wsURL += "api/terminal/ws"

        guard let url = URL(string: wsURL) else {
            connectionError = "Invalid WebSocket URL"
            return
        }

        // Create WebSocket task
        webSocket = urlSession.webSocketTask(with: url)
        webSocket?.resume()

        // Send API key as first message (authentication)
        sendAuthentication()
    }

    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        isConnected = false
        reconnectAttempts = 0
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        pingTimer?.invalidate()
        pingTimer = nil
    }

    // FIX: Use async/await to avoid blocking main thread
    private func sendAuthentication() {
        Task {
            do {
                guard let webSocket = webSocket else { return }
                try await webSocket.send(.string(apiKey))

                // Start receiving messages after auth
                await MainActor.run {
                    self.receiveMessage()
                }
            } catch {
                await MainActor.run {
                    self.connectionError = "Auth failed: \(error.localizedDescription)"
                    self.attemptReconnect()
                }
            }
        }
    }

    // MARK: - Message Handling

    // FIX: Use async/await loop instead of recursive callbacks to prevent stack overflow
    private func receiveMessage() {
        Task {
            await receiveLoop()
        }
    }

    private func receiveLoop() async {
        while isConnected || webSocket != nil {
            do {
                guard let webSocket = webSocket else {
                    break
                }

                let message = try await webSocket.receive()

                await MainActor.run {
                    switch message {
                    case .string(let text):
                        // Check for authentication confirmation
                        if text == "authenticated" {
                            self.isConnected = true
                            self.reconnectAttempts = 0
                            self.connectionError = nil
                            self.startPingTimer()  // Start keepalive
                        }

                    case .data(let data):
                        // PTY output - append to output buffer (on main thread for @Published)
                        self.terminalOutput.append(data)

                    @unknown default:
                        break
                    }
                }
            } catch {
                await MainActor.run {
                    self.connectionError = "Connection error: \(error.localizedDescription)"
                    self.isConnected = false
                    self.attemptReconnect()
                }
                break
            }
        }
    }

    // MARK: - Auto-Reconnect

    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            connectionError = "Max reconnection attempts reached"
            return
        }

        reconnectAttempts += 1

        // Exponential backoff: 2s, 4s, 8s, 16s, 32s
        let delay = pow(2.0, Double(reconnectAttempts))

        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.connect()
            }
        }
    }

    // MARK: - Keepalive Ping

    private func startPingTimer() {
        // Stop any existing timer
        pingTimer?.invalidate()

        // Send ping every 30 seconds to keep connection alive
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    @MainActor
    private func sendPing() {
        guard isConnected, let webSocket = webSocket else { return }

        Task {
            webSocket.sendPing { [weak self] error in
                if let error = error {
                    Task { @MainActor in
                        self?.connectionError = "Ping failed: \(error.localizedDescription)"
                        self?.isConnected = false
                        self?.attemptReconnect()
                    }
                }
            }
        }
    }

    // MARK: - Manual Input (for testing)

    /// Send raw keyboard bytes directly to the remote PTY session.
    // FIX: Use async/await to avoid blocking main thread
    func sendBytes(_ data: Data) {
        guard isConnected else { return }
        guard !data.isEmpty else { return }

        Task {
            do {
                guard let webSocket = webSocket else { return }
                try await webSocket.send(.data(data))
            } catch {
                await MainActor.run {
                    self.connectionError = "Send failed: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Convenience helper for quick actions that should submit a full command.
    func sendCommand(_ command: String) {
        guard isConnected else { return }

        let commandWithNewline = command.hasSuffix("\n") ? command : command + "\n"

        guard let data = commandWithNewline.data(using: .utf8) else { return }

        sendBytes(data)
    }

    // MARK: - Terminal Resize

    func sendResize(rows: Int, cols: Int) {
        guard isConnected else { return }

        let resize = [
            "type": "resize",
            "rows": rows,
            "cols": cols
        ] as [String : Any]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: resize) else {
            return
        }

        webSocket?.send(.data(jsonData)) { error in
            // Silently handle resize errors
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension PTYTerminalManager: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // WebSocket opened
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            self.isConnected = false
        }
    }
}
