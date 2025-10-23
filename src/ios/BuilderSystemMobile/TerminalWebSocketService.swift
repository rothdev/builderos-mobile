//
//  TerminalWebSocketService.swift
//  BuilderSystemMobile
//
//  Enhanced WebSocket service for real-time terminal connection
//  Supports auto-reconnect, resize, and scrollback buffer management
//

import Foundation
import Combine

class TerminalWebSocketService: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var output: String = ""
    @Published var error: String?
    @Published var connectionAttempt = 0

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private let apiKey: String
    private let baseURL: String
    private let maxScrollbackLines = 1000
    private var reconnectTimer: Timer?
    private var reconnectDelay: TimeInterval = 1.0
    private let maxReconnectDelay: TimeInterval = 30.0

    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        super.init()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    deinit {
        disconnect()
    }

    // MARK: - Connection Management

    func connect() {
        disconnect()
        connectionAttempt += 1

        // Convert HTTP/HTTPS URL to WS/WSS
        var wsURL = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")

        // Add terminal WebSocket endpoint
        if !wsURL.hasSuffix("/") {
            wsURL += "/"
        }
        wsURL += "api/terminal/ws"

        guard let url = URL(string: wsURL) else {
            error = "Invalid WebSocket URL: \(wsURL)"
            return
        }

        print("🔌 Connecting to WebSocket (attempt \(connectionAttempt)): \(url.absoluteString)")

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        // Send API key as first message
        sendAPIKey()

        // Start receiving messages
        receiveMessage()
    }

    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func scheduleReconnect() {
        guard reconnectTimer == nil else { return }

        print("⏱️ Scheduling reconnect in \(reconnectDelay)s")

        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.reconnectTimer = nil
            self.connect()
        }

        // Exponential backoff with max delay
        reconnectDelay = min(reconnectDelay * 2, maxReconnectDelay)
    }

    // MARK: - Message Sending

    private func sendAPIKey() {
        let message = URLSessionWebSocketTask.Message.string(apiKey)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("❌ Failed to send API key: \(error)")
                self?.error = "Authentication failed: \(error.localizedDescription)"
                self?.isConnected = false
                self?.scheduleReconnect()
            } else {
                print("✅ API key sent")
            }
        }
    }

    func sendInput(_ input: String) {
        guard isConnected else {
            print("⚠️ Cannot send input: not connected")
            return
        }

        let data = input.data(using: .utf8) ?? Data()
        let message = URLSessionWebSocketTask.Message.data(data)

        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("❌ Failed to send input: \(error)")
                self?.error = "Failed to send: \(error.localizedDescription)"
            }
        }
    }

    func sendBytes(_ bytes: [UInt8]) {
        guard isConnected else {
            print("⚠️ Cannot send bytes: not connected")
            return
        }

        let data = Data(bytes)
        let message = URLSessionWebSocketTask.Message.data(data)

        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("❌ Failed to send bytes: \(error)")
                self?.error = "Failed to send: \(error.localizedDescription)"
            }
        }
    }

    func sendResize(rows: Int, cols: Int) {
        guard isConnected else { return }

        let resizeCmd = "{\"type\":\"resize\",\"rows\":\(rows),\"cols\":\(cols)}"
        let message = URLSessionWebSocketTask.Message.string(resizeCmd)

        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ Failed to send resize: \(error)")
            } else {
                print("📐 Terminal resized to \(rows)x\(cols)")
            }
        }
    }

    func clearOutput() {
        DispatchQueue.main.async {
            self.output = ""
        }
    }

    // MARK: - Message Receiving

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        if text == "authenticated" {
                            self.isConnected = true
                            self.error = nil
                            self.reconnectDelay = 1.0 // Reset backoff on success
                            print("✅ Terminal authenticated")
                        } else if text.starts(with: "error:") {
                            self.error = String(text.dropFirst(6))
                            self.isConnected = false
                            self.scheduleReconnect()
                        }
                    }

                case .data(let data):
                    // Terminal output
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.appendOutput(text)
                        }
                    }

                @unknown default:
                    break
                }

                // Continue receiving
                self.receiveMessage()

            case .failure(let error):
                print("❌ WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self.error = "Connection error: \(error.localizedDescription)"
                    self.isConnected = false
                    self.scheduleReconnect()
                }
            }
        }
    }

    // MARK: - Output Management

    private func appendOutput(_ text: String) {
        output += text

        // Trim to max scrollback lines
        let lines = output.split(separator: "\n", omittingEmptySubsequences: false)
        if lines.count > maxScrollbackLines {
            let startIndex = lines.count - maxScrollbackLines
            let trimmedLines = lines[startIndex...]
            output = trimmedLines.joined(separator: "\n")
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension TerminalWebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket opened")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "unknown"
        print("⚠️ WebSocket closed with code: \(closeCode), reason: \(reasonString)")
        DispatchQueue.main.async {
            self.isConnected = false
            self.scheduleReconnect()
        }
    }
}
