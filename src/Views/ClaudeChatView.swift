//
//  ClaudeChatView.swift
//  BuilderOS
//
//  Real Claude Agent chat interface with full BuilderOS context
//

import SwiftUI
import Inject

struct ClaudeChatView: View {
    @StateObject private var service = ClaudeAgentService()
    @ObserveInjection var inject
    @Binding var selectedTab: Int

    @State private var inputText: String = ""
    @State private var showingQuickActions = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            // Terminal dark background
            Color.terminalDark
                .ignoresSafeArea()

            // Subtle radial gradient overlay
            RadialGradient(
                colors: [
                    Color.terminalCyan.opacity(0.1),
                    Color.terminalPink.opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Message history (now gets full screen real estate)
                messageListView

                Divider()
                    .background(Color.terminalInputBorder)

                // Quick actions (horizontal scroll)
                quickActionsView

                Divider()
                    .background(Color.terminalInputBorder)

                // Input area
                inputView
            }

            // Floating back button (top-left)
            VStack {
                HStack {
                    backButton
                        .padding(.top, 8)
                        .padding(.leading, 16)
                    Spacer()
                }
                Spacer()
            }

            // Floating connection status indicator (top-right)
            VStack {
                HStack {
                    Spacer()
                    connectionStatusIndicator
                        .padding(.top, 8)
                        .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .onAppear {
            connectToClaudeAgent()
        }
        .onDisappear {
            service.disconnect()
        }
        .enableInjection()
    }

    // MARK: - Floating Back Button

    private var backButton: some View {
        Button(action: {
            selectedTab = 0  // Navigate to Dashboard tab
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                )
        }
    }

    // MARK: - Connection Status Indicator

    private var connectionStatusIndicator: some View {
        Button(action: {
            if !service.isConnected {
                connectToClaudeAgent()
            }
        }) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(service.isConnected ? .statusSuccess : .statusError)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .disabled(service.isConnected) // Only tappable when disconnected
    }

    // MARK: - Message List

    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(service.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }

                    // Loading indicator
                    if service.isLoading {
                        LoadingIndicatorView()
                    }
                }
                .padding()
            }
            .onChange(of: service.messages.count) {
                // Auto-scroll to latest message
                if let lastMessage = service.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickActionChip(
                    icon: "info.circle.fill",
                    text: "Status",
                    action: { sendQuickAction("What's the status of BuilderOS?") }
                )

                QuickActionChip(
                    icon: "wrench.and.screwdriver.fill",
                    text: "Tools",
                    action: { sendQuickAction("Show me available tools") }
                )

                QuickActionChip(
                    icon: "app.badge.fill",
                    text: "Capsules",
                    action: { sendQuickAction("List all capsules") }
                )

                QuickActionChip(
                    icon: "chart.bar.fill",
                    text: "Metrics",
                    action: { sendQuickAction("Show system metrics") }
                )

                QuickActionChip(
                    icon: "person.3.fill",
                    text: "Agents",
                    action: { sendQuickAction("List available agents") }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.terminalDark.opacity(0.5))
    }

    // MARK: - Input Area

    private var inputView: some View {
        HStack(spacing: 12) {
            // Text input
            TextField("Message Claude...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminalText)
                .padding(12)
                .background(Color.terminalInputBackground)
                .terminalBorder(cornerRadius: 20)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }
                .tint(.terminalCyan)

            // Voice button (disabled for now - VoiceManager needs to be added to target)
            // TODO: Re-enable when VoiceManager is added to BuilderOS target
            // Button(action: startVoiceInput) {
            //     Image(systemName: "mic")
            //         .font(.title3)
            //         .foregroundColor(.terminalCyan)
            //         .frame(width: 44, height: 44)
            //         .background(Color.terminalInputBackground)
            //         .clipShape(Circle())
            // }

            // Send button
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(canSend ? .terminalCyan : .terminalDim)
            }
            .disabled(!canSend)
        }
        .padding()
        .background(Color.terminalDark.opacity(0.9))
    }

    // MARK: - Computed Properties

    private var canSend: Bool {
        service.isConnected && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !service.isLoading
    }

    // MARK: - Actions

    private func connectToClaudeAgent() {
        Task {
            do {
                print("🔵 Starting connection attempt...")
                try await service.connect()
                print("✅ Connection successful!")
            } catch {
                print("❌ Failed to connect to Claude Agent: \(error)")
                print("❌ Error details: \(String(describing: error))")

                // Update UI to show error
                await MainActor.run {
                    service.connectionStatus = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func sendMessage() {
        guard canSend else { return }

        let messageText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        isInputFocused = false

        Task {
            do {
                try await service.sendMessage(messageText)
            } catch {
                print("❌ Failed to send message: \(error)")
            }
        }
    }

    private func sendQuickAction(_ message: String) {
        Task {
            do {
                try await service.sendMessage(message)
            } catch {
                print("❌ Failed to send quick action: \(error)")
            }
        }
    }

    // TODO: Re-enable when VoiceManager is added to BuilderOS target
    // private func startVoiceInput() {
    //     // Voice input implementation
    // }
}

// MARK: - Message Bubble

struct MessageBubbleView: View {
    let message: ClaudeChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(message.isUser ? .terminalText : .terminalText)
                    .padding(12)
                    .background(
                        message.isUser
                            ? LinearGradient(
                                colors: [Color.terminalCyan.opacity(0.3), Color.terminalPink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.terminalInputBackground, Color.terminalInputBackground],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .terminalBorder(cornerRadius: 16, color: message.isUser ? .terminalCyan : .terminalInputBorder)

                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.terminalDim)
            }

            if !message.isUser {
                Spacer()
            }
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Loading Indicator

struct LoadingIndicatorView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.terminalCyan)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
            Text("Claude is thinking...")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminalDim)
        }
        .padding(12)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 16)
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Quick Action Chip

struct QuickActionChip: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.terminalCyan)
                Text(text)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.terminalText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.terminalInputBackground)
            .terminalBorder(cornerRadius: 16)
        }
    }
}

// MARK: - Preview

#Preview {
    ClaudeChatView(selectedTab: .constant(1))
}
