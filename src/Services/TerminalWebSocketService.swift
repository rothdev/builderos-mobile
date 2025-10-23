//
//  TerminalWebSocketService.swift
//  BuilderOS
//
//  WebSocket service for real-time terminal connection to BuilderOS API
//

import Foundation
import Combine

class TerminalWebSocketService: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var output: String = ""
    @Published var error: String?

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private let apiKey: String
    private let baseURL: String

    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        super.init()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    func connect() {
        disconnect()

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

        print("🔌 Connecting to WebSocket: \(url.absoluteString)")

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        // Send API key as first message
        sendAPIKey()

        // Start receiving messages
        receiveMessage()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func sendAPIKey() {
        let message = URLSessionWebSocketTask.Message.string(apiKey)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("❌ Failed to send API key: \(error)")
                self?.error = "Authentication failed: \(error.localizedDescription)"
                self?.isConnected = false
            } else {
                print("✅ API key sent")
            }
        }
    }

    func sendInput(_ input: String) {
        guard isConnected else { return }

        let data = input.data(using: .utf8) ?? Data()
        let message = URLSessionWebSocketTask.Message.data(data)

        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("❌ Failed to send input: \(error)")
                self?.error = "Failed to send: \(error.localizedDescription)"
            }
        }
    }

    func sendBytes(_ data: Data) {
        guard isConnected else { return }

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
            }
        }
    }

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
                            print("✅ Terminal authenticated")
                        } else if text.starts(with: "error:") {
                            self.error = String(text.dropFirst(6))
                            self.isConnected = false
                        }
                    }

                case .data(let data):
                    // Terminal output
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.output += text
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
                }
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension TerminalWebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket opened")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("⚠️ WebSocket closed with code: \(closeCode)")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}
