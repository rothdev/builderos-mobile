//
//  WebSocketTerminalView.swift
//  BuilderOS
//
//  Real terminal emulator with WebSocket connection to BuilderOS API
//  Single-profile terminal view (used within MultiTabTerminalView)
//

import SwiftUI

struct WebSocketTerminalView: View {
    @StateObject private var terminal: TerminalWebSocketService
    let profile: TerminalProfile
    @State private var inputText: String = ""
    @State private var displayText: AttributedString = AttributedString()
    @FocusState private var isInputFocused: Bool
    @State private var terminalSize: CGSize = .zero

    // Command suggestions
    @State private var showingSuggestions = false
    @State private var filteredSuggestions: [Command] = []

    init(baseURL: String, apiKey: String, profile: TerminalProfile) {
        self.profile = profile
        _terminal = StateObject(wrappedValue: TerminalWebSocketService(baseURL: baseURL, apiKey: apiKey))
    }

    var body: some View {
        ZStack {
            // Terminal background with gradient (color coded by profile)
            terminalBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Connection status bar
                connectionStatusBar

                // Terminal output
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(displayText)
                                .font(.system(size: 14).monospaced())
                                .foregroundColor(profile.color)
                                .textSelection(.enabled)
                                .padding()
                                .id("terminalOutput")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: SizePreferenceKey.self,
                                    value: geo.size
                                )
                            }
                        )
                    }
                    .onChange(of: terminal.output) { _ in
                        updateDisplayText()
                        // Auto-scroll to bottom
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("terminalOutput", anchor: .bottom)
                        }
                    }
                }
                .onPreferenceChange(SizePreferenceKey.self) { size in
                    if size != terminalSize {
                        terminalSize = size
                        calculateAndSendTerminalSize()
                    }
                }

                // Command suggestions (appears when typing commands)
                if showingSuggestions && !filteredSuggestions.isEmpty {
                    CommandSuggestionsView(
                        suggestions: filteredSuggestions,
                        onSelect: insertCommand
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // Quick actions toolbar
                QuickActionsBar(
                    actions: QuickAction.all,
                    onAction: { action in
                        terminal.sendInput(action.command)
                    }
                )

                // Input bar
                terminalInputBar
            }
        }
        .onAppear {
            terminal.connect()
            isInputFocused = true

            // Auto-run profile's initial command after connection
            if let initialCmd = profile.initialCommand {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    terminal.sendInput(initialCmd + "\n")
                }
            }
        }
        .onDisappear {
            terminal.disconnect()
        }
    }

    // MARK: - Background
    private var terminalBackground: some View {
        ZStack {
            // Base dark background
            Color(red: 0.04, green: 0.055, blue: 0.102) // #0a0e1a
                .ignoresSafeArea()

            // Radial gradient overlay (color coded by profile)
            RadialGradient(
                colors: [
                    profile.color.opacity(0.15),
                    Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.10),
                    Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .scaleEffect(1.2)
        }
    }

    // MARK: - Connection Status Bar
    private var connectionStatusBar: some View {
        HStack(spacing: 12) {
            // Connection indicator
            Circle()
                .fill(terminal.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: terminal.isConnected ? .green : .red, radius: 4)

            Text(terminal.isConnected ? "CONNECTED" : "DISCONNECTED")
                .font(.system(size: 12, weight: .bold).monospaced())
                .foregroundColor(terminal.isConnected ? .green : .red)

            Spacer()

            if !terminal.isConnected {
                Button("Reconnect") {
                    terminal.connect()
                }
                .font(.system(size: 12, weight: .bold).monospaced())
                .foregroundColor(.cyan)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Terminal Input Bar
    private var terminalInputBar: some View {
        HStack(spacing: 12) {
            // Prompt indicator (color coded by profile)
            Text(">")
                .font(.system(size: 16, weight: .bold).monospaced())
                .foregroundColor(profile.color)

            // Input field
            TextField("", text: $inputText)
                .font(.system(size: 14).monospaced())
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($isInputFocused)
                .onChange(of: inputText) { newValue in
                    handleInputChange(newValue)
                }
                .onSubmit {
                    sendInput()
                }

            // Send button
            Button(action: sendInput) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(terminal.isConnected && !inputText.isEmpty ? profile.color : .gray)
            }
            .disabled(!terminal.isConnected || inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    profile.color.opacity(0.5),
                                    Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding()
    }

    // MARK: - Actions
    private func sendInput() {
        guard !inputText.isEmpty else { return }

        // Send input with newline (simulating Enter key)
        terminal.sendInput(inputText + "\n")
        inputText = ""
        showingSuggestions = false
    }


    private func calculateAndSendTerminalSize() {
        // Estimate terminal dimensions from view size
        // Average character width in monospaced font (14pt)
        let charWidth: CGFloat = 8.4
        let lineHeight: CGFloat = 18.0

        let cols = max(Int(terminalSize.width / charWidth), 40)
        let rows = max(Int(terminalSize.height / lineHeight), 10)

        terminal.sendResize(rows: rows, cols: cols)
    }

    private func updateDisplayText() {
        // Parse ANSI codes and update display
        displayText = ANSIParser.parse(terminal.output)
    }

    // MARK: - Command Suggestions
    private func handleInputChange(_ newValue: String) {
        // Check if user is typing a command that we can suggest
        let trimmed = newValue.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            showingSuggestions = false
            return
        }

        // Filter commands based on input
        let allCommands = Command.all
        let matches = allCommands.filter { cmd in
            cmd.name.lowercased().hasPrefix(trimmed.lowercased())
        }

        if !matches.isEmpty {
            filteredSuggestions = Array(matches.prefix(5))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showingSuggestions = true
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showingSuggestions = false
            }
        }
    }

    private func insertCommand(_ command: Command) {
        inputText = command.name + " "
        showingSuggestions = false

        // Refocus input
        isInputFocused = true
    }
}

// MARK: - Size Preference Key

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

#Preview {
    WebSocketTerminalView(
        baseURL: "https://selection-tunes-ontario-destinations.trycloudflare.com",
        apiKey: "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3",
        profile: .shell
    )
}
