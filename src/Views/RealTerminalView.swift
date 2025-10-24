//
//  RealTerminalView.swift
//  BuilderOS - WebSocket Terminal Implementation (Single File)
//

import SwiftUI
import Foundation
import Combine

// MARK: - WebSocket Terminal Service
class LiveTerminalService: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var output: String = ""

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    var apiKey: String
    var baseURL: String

    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        super.init()

        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect() {
        var wsURL = baseURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        if !wsURL.hasSuffix("/") { wsURL += "/" }
        wsURL += "api/terminal/ws"
        
        guard let url = URL(string: wsURL) else { return }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        let message = URLSessionWebSocketTask.Message.string(apiKey)
        webSocketTask?.send(message) { _ in }
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
    
    func sendInput(_ input: String) {
        guard isConnected else { return }
        let data = input.data(using: .utf8) ?? Data()
        webSocketTask?.send(.data(data)) { _ in }
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
                        }
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.output += text
                        }
                    }
                @unknown default:
                    break
                }
                self.receiveMessage()
            case .failure:
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            }
        }
    }
}

extension LiveTerminalService: URLSessionWebSocketDelegate {}

// MARK: - Real Terminal View
struct RealTerminalView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @StateObject private var terminal = LiveTerminalService(baseURL: "", apiKey: "")
    @State private var inputText = ""
    @State private var hasInitialized = false

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.055, blue: 0.102).ignoresSafeArea()

            VStack(spacing: 0) {
                // Status bar
                HStack {
                    Circle()
                        .fill(terminal.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(terminal.isConnected ? "CONNECTED" : "DISCONNECTED")
                        .font(.system(size: 12, weight: .bold).monospaced())
                        .foregroundColor(terminal.isConnected ? .green : .red)
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.3))

                // Terminal output
                ScrollView {
                    Text(terminal.output)
                        .font(.system(size: 14).monospaced())
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }

                // Input bar
                HStack {
                    Text(">")
                        .font(.system(size: 16, weight: .bold).monospaced())
                        .foregroundColor(.green)

                    TextField("", text: $inputText)
                        .font(.system(size: 14).monospaced())
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .onSubmit {
                            terminal.sendInput(inputText + "\n")
                            inputText = ""
                        }
                }
                .padding()
                .background(Color.black.opacity(0.3))
            }
        }
        .onAppear {
            // Initialize connection once with apiClient values
            if !hasInitialized {
                terminal.baseURL = apiClient.tunnelURL
                terminal.apiKey = apiClient.apiKey
                terminal.connect()
                hasInitialized = true
            }
        }
        .onDisappear {
            terminal.disconnect()
        }
    }
}
