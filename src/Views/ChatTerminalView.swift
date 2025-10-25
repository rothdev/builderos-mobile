//
//  ChatTerminalView.swift
//  BuilderOS
//
//  Chat-style terminal interface (alternative to PTYTerminalSessionView)
//

import SwiftUI
import Inject

struct ChatTerminalView: View {
    @StateObject private var viewModel: ChatTerminalViewModel
    // TODO: Re-enable VoiceManager when integrated properly
    // @StateObject private var voiceManager = VoiceManager()
    @ObserveInjection var inject

    @FocusState private var isInputFocused: Bool

    init(apiClient: BuilderOSAPIClient) {
        _viewModel = StateObject(wrappedValue: ChatTerminalViewModel(apiClient: apiClient))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Messages
            messagesView

            Divider()

            // Input Bar
            inputBar
        }
        .background(Color(.systemBackground))
        .enableInjection()
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Chat Terminal")
                .font(.headline)

            Spacer()

            connectionIndicator

            Button(action: {
                viewModel.clearMessages()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var connectionIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(viewModel.isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Messages

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatMessageView(
                            message: message,
                            onToggleThinking: { messageId in
                                viewModel.toggleThinkingBlock(messageId: messageId)
                            }
                        )
                        .id(message.id)
                    }

                    // Loading indicator
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Processing...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 16)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { oldValue, newValue in
                // Auto-scroll to bottom when new messages arrive
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .refreshable {
            // Pull-to-refresh reconnect
            // TODO: Implement reconnection logic
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            // Quick Actions (optional)
            if !viewModel.currentInput.isEmpty {
                quickActionsBar
            }

            // Main Input
            HStack(spacing: 12) {
                // Voice Input Button
                voiceButton

                // Text Input
                TextField("Type a command...", text: $viewModel.currentInput)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(20)
                    .focused($isInputFocused)
                    .onSubmit {
                        sendCommand()
                    }
                    .gesture(
                        // Swipe up for history navigation
                        DragGesture(minimumDistance: 20)
                            .onEnded { gesture in
                                if gesture.translation.height < 0 {
                                    // Swipe up - go to older command
                                    viewModel.navigateHistoryUp()
                                } else if gesture.translation.height > 0 {
                                    // Swipe down - go to newer command
                                    viewModel.navigateHistoryDown()
                                }
                            }
                    )

                // Send Button
                sendButton
            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
    }

    private var voiceButton: some View {
        // TODO: Re-enable when VoiceManager is properly integrated
        Button(action: {
            // Placeholder for voice input
            print("Voice input - TODO: Integrate VoiceManager")
        }) {
            Image(systemName: "mic.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .disabled(true)  // Disabled until VoiceManager is integrated
        .opacity(0.5)
    }

    private var sendButton: some View {
        Button(action: sendCommand) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.title2)
                .foregroundColor(viewModel.currentInput.isEmpty ? .secondary : .blue)
        }
        .disabled(viewModel.currentInput.isEmpty)
    }

    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                quickActionButton("ls -la", systemImage: "list.bullet")
                quickActionButton("pwd", systemImage: "folder")
                quickActionButton("git status", systemImage: "arrow.triangle.branch")
                quickActionButton("clear", systemImage: "trash")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.tertiarySystemBackground))
    }

    private func quickActionButton(_ command: String, systemImage: String) -> some View {
        Button(action: {
            viewModel.currentInput = command
        }) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(command)
                    .font(.system(.caption, design: .monospaced))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }

    // MARK: - Actions

    private func sendCommand() {
        viewModel.sendCommand(viewModel.currentInput)
        isInputFocused = true // Keep focus after sending
    }
}

// MARK: - Preview

#Preview("With Messages") {
    ChatTerminalView(apiClient: BuilderOSAPIClient.mockWithData())
}

#Preview("Disconnected") {
    ChatTerminalView(apiClient: BuilderOSAPIClient.mockDisconnected())
}

#Preview("Loading") {
    ChatTerminalView(apiClient: BuilderOSAPIClient.mockLoading())
}
