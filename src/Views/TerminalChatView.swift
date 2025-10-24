//
//  TerminalChatView.swift
//  BuilderOS
//
//  Terminal-style chat interface with full aesthetic design
//  Design Reference: /docs/design/TERMINAL_CHAT_SPECS.md
//
//  IMPLEMENTATION NOTES:
//  - Uses JetBrains Mono font family (see TerminalColors.swift)
//  - Color system matches terminal design specs
//  - Structured output format for status blocks (emoji + label + value grid)
//  - Animations: slide-in entries, pulsing connection status, scanlines effect
//

import SwiftUI

struct TerminalMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct TerminalChatView: View {
    @State private var messages: [TerminalMessage] = []
    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var showQuickActions = false

    var body: some View {
        ZStack {
            // Terminal dark background with gradient
            terminalBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Terminal header
                terminalHeader

                // Messages area or empty state
                if messages.isEmpty {
                    terminalEmptyState
                } else {
                    terminalMessagesView
                }

                // Input bar
                terminalInputBar
            }
        }
        .sheet(isPresented: $showQuickActions) {
            QuickActionsSheet(onSelect: handleQuickAction)
        }
    }

    // MARK: - Background with Gradient Effect
    private var terminalBackground: some View {
        ZStack {
            // Base dark background
            Color(red: 0.04, green: 0.055, blue: 0.102) // #0a0e1a
                .ignoresSafeArea()

            // Radial gradient overlay (pulsing effect)
            RadialGradient(
                colors: [
                    Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.15), // #60efff
                    Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.1),   // #ff6b9d
                    Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.05),      // #ff3366
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .scaleEffect(1.2)
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: messages.count)

            // Scanlines effect (subtle)
            scanlinesOverlay
                .opacity(0.3)
                .allowsHitTesting(false)
        }
    }

    private var scanlinesOverlay: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                ForEach(0..<Int(geometry.size.height / 3), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
    }

    // MARK: - Terminal Header
    private var terminalHeader: some View {
        HStack {
            Text("$ BuilderOS")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.376, green: 0.937, blue: 1.0), // #60efff cyan
                            Color(red: 1.0, green: 0.42, blue: 0.616),  // #ff6b9d pink
                            Color(red: 1.0, green: 0.2, blue: 0.4)       // #ff3366 red
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Spacer()

            // Connection status
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(red: 0.0, green: 1.0, blue: 0.533)) // #00ff88 green
                    .frame(width: 8, height: 8)
                    .shadow(color: Color(red: 0.0, green: 1.0, blue: 0.533).opacity(0.6), radius: 4)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())

                Text("CONNECTED")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.533))
                    .tracking(0.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(red: 0.04, green: 0.055, blue: 0.102).opacity(0.8)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.102, green: 0.137, blue: 0.196), // #1a2332
                            Color(red: 0.102, green: 0.137, blue: 0.196)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2),
            alignment: .bottom
        )
    }

    // MARK: - Empty State with Terminal Aesthetic
    private var terminalEmptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            // Builder logo with border
            ZStack {
                // Glow effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.3),
                                Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.2),
                                Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                // Logo container
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.04, green: 0.055, blue: 0.102).opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.376, green: 0.937, blue: 1.0),
                                            Color(red: 1.0, green: 0.42, blue: 0.616),
                                            Color(red: 1.0, green: 0.2, blue: 0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.3), radius: 20)
                        .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.2), radius: 40)

                    Text("🏗️")
                        .font(.system(size: 48))

                    // Terminal prompt in corner
                    VStack {
                        HStack {
                            Text(">")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0))
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Text("_")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.616))
                                .opacity(0.8)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: UUID())
                        }
                    }
                    .padding(8)
                }
                .frame(width: 100, height: 100)
            }

            // Title with gradient
            Text("$ BUILDEROS")
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .tracking(1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.376, green: 0.937, blue: 1.0),
                            Color(red: 1.0, green: 0.42, blue: 0.616),
                            Color(red: 1.0, green: 0.2, blue: 0.4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Subtitle
            Text("// Your mobile companion for managing capsules,\ncoordinating agents, and monitoring the\nBuilder System on the go.")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(Color(red: 0.478, green: 0.608, blue: 0.753)) // #7a9bc0
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .tracking(0.3)
                .frame(maxWidth: 280)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Messages View
    private var terminalMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(messages) { message in
                        terminalMessageView(message: message)
                            .id(message.id)
                    }

                    if isProcessing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.376, green: 0.937, blue: 1.0)))
                                .scaleEffect(0.8)
                            Text("Processing...")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: messages.count) {
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func terminalMessageView(message: TerminalMessage) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                // Prompt symbol
                Text(message.isUser ? ">" : "$")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(message.isUser ? Color(red: 0.0, green: 1.0, blue: 0.533) : Color(red: 0.376, green: 0.937, blue: 1.0))

                // Message content
                Text(message.content)
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(message.isUser ? 1.0 : 0.9))
                    .textSelection(.enabled)
            }

            // Timestamp (for system messages)
            if !message.isUser {
                Text(formatTime(message.timestamp))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.leading, 26)
            }
        }
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Terminal Input Bar
    private var terminalInputBar: some View {
        HStack(spacing: 12) {
            // Quick actions button
            Button {
                showQuickActions = true
            } label: {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.376, green: 0.937, blue: 1.0),
                                Color(red: 1.0, green: 0.42, blue: 0.616)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
            }

            // Input field
            TextField("$ _", text: $inputText)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.102, green: 0.137, blue: 0.196).opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color(red: 0.165, green: 0.247, blue: 0.373), lineWidth: 1)
                        )
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    sendMessage()
                }

            // Send button with gradient
            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.376, green: 0.937, blue: 1.0),
                                Color(red: 1.0, green: 0.42, blue: 0.616),
                                Color(red: 1.0, green: 0.2, blue: 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.4), radius: 12)
            }
            .disabled(inputText.isEmpty || isProcessing)
            .opacity(inputText.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 34)
        .background(
            Color(red: 0.04, green: 0.055, blue: 0.102).opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color(red: 0.102, green: 0.137, blue: 0.196))
                .frame(height: 2),
            alignment: .top
        )
    }

    // MARK: - Message Handling
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = TerminalMessage(
            content: inputText,
            isUser: true,
            timestamp: Date()
        )

        withAnimation(.easeOut(duration: 0.2)) {
            messages.append(userMessage)
        }

        let command = inputText
        inputText = ""

        // Simulate processing
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isProcessing = false

            let response = generateResponse(for: command)
            let systemMessage = TerminalMessage(
                content: response,
                isUser: false,
                timestamp: Date()
            )

            withAnimation(.easeOut(duration: 0.2)) {
                messages.append(systemMessage)
            }
        }
    }

    private func handleQuickAction(_ action: String) {
        inputText = action
        sendMessage()
    }

    // MARK: - Structured Output Helper
    /// Formats structured status output matching design specs
    /// Grid format: emoji (16px) | label (flex) | value (cyan/green, bold)
    /// Reference: TERMINAL_CHAT_SPECS.md Section 3 - Status Blocks
    private func formatStatusBlock(_ items: [(emoji: String, label: String, value: String)]) -> String {
        items.map { item in
            // Emoji (16px width) + Label (padded) + Value (aligned)
            "\(item.emoji)  \(item.label.padding(toLength: 12, withPad: " ", startingAt: 0))\(item.value)"
        }.joined(separator: "\n")
    }

    private func generateResponse(for command: String) -> String {
        let lowercased = command.lowercased()

        if lowercased.contains("status") || lowercased.contains("health") {
            // Use structured output format matching design specs
            return formatStatusBlock([
                (emoji: "⚡", label: "System", value: "OPERATIONAL"),
                (emoji: "🏗️", label: "Capsules", value: "7 active"),
                (emoji: "💾", label: "Memory", value: "64%"),
                (emoji: "🌐", label: "Tailscale", value: "Connected"),
                (emoji: "📊", label: "Uptime", value: "7d 14h")
            ])
        } else if lowercased.contains("capsule") || lowercased.contains("list") {
            return """
Active Capsules:
• jellyfin-server-ops (Running)
• brandjack (Active)
• builder-system-mobile (Development)
• ecommerce (Production)
• jar-label-automation (Active)
"""
        } else if lowercased.contains("help") {
            return """
Available commands:
  status - Show system status
  capsules - List all capsules
  help - Show this help

Or chat naturally with Jarvis!
"""
        } else {
            return "Command received: '\(command)'\n\nChat integration with Jarvis/Codex coming soon. For now, try: status, capsules, help"
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Quick Actions Sheet
struct QuickActionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (String) -> Void

    let quickActions = [
        ("📊", "System Status", "status"),
        ("🏗️", "List Capsules", "capsules"),
        ("🚀", "Deploy", "deploy"),
        ("🔍", "Search Logs", "search logs"),
        ("🧠", "Memory Query", "memory"),
        ("⚙️", "Settings", "settings")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                // Actions grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(quickActions, id: \.2) { icon, label, command in
                        Button {
                            onSelect(command)
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                Text(icon)
                                    .font(.system(size: 28))
                                Text(label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

#Preview("Terminal Chat") {
    TerminalChatView()
}

#Preview("Quick Actions") {
    QuickActionsSheet(onSelect: { _ in })
}
