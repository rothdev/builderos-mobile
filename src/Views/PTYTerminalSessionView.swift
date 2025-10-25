//
//  PTYTerminalSessionView.swift
//  BuilderOS
//
//  Reusable PTY terminal session view backed by the Cloudflare WebSocket.
//

import SwiftUI
import UIKit
import SwiftTerm
import Inject
import os.log

private let logger = Logger(subsystem: "com.ty.builderos", category: "PTYTerminalView")

struct PTYTerminalSessionView: View {
    @ObservedObject var manager: PTYTerminalManager
    let profile: TerminalProfile
    let onHeaderTap: (() -> Void)?

    @State private var showQuickActions = false
    @State private var showReconnectButton = false
    @State private var hasDispatchedInitialCommand = false
    @State private var showSlashCommands = false
    @State private var currentInput = ""
    @State private var slashCommandSuggestions: [SlashCommand] = []
    @ObserveInjection var inject

    var body: some View {
        ZStack {
            terminalBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                actionToolbar

                // Terminal output
                TerminalViewWrapper(
                    outputData: manager.terminalOutput,
                    onInput: { data in
                        guard !data.isEmpty else {
                            logger.error("❌ onInput - EMPTY DATA, returning")
                            return
                        }
                        manager.sendBytes(data)
                    },
                    onSpecialKey: { key in
                        let data = Data(key.bytes)
                        guard !data.isEmpty else {
                            logger.error("❌ onSpecialKey - EMPTY DATA, returning")
                            return
                        }
                        manager.sendBytes(data)
                    },
                    onSlashCommand: {
                        // Show slash command suggestions
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            slashCommandSuggestions = SlashCommand.search("/")
                            showSlashCommands = true
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !manager.isConnected && showReconnectButton {
                    reconnectButton
                }
            }
        }
        .onAppear {
            manager.connect()
        }
        .onDisappear {
            manager.disconnect()
        }
        .onChange(of: manager.isConnected) { _, newValue in
            if newValue {
                showReconnectButton = false

                // Always run initial command on connect (including reconnects)
                if let command = profile.initialCommand {
                    hasDispatchedInitialCommand = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        manager.sendCommand(command)
                    }
                }
            } else {
                // Reset flag so initial command runs again on reconnect
                hasDispatchedInitialCommand = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if !manager.isConnected {
                        showReconnectButton = true
                    }
                }
            }
        }
        .sheet(isPresented: $showQuickActions) {
            QuickActionsSheet(actions: QuickAction.all) { action in
                if action.command.contains(where: { $0.isControl }) {
                    manager.sendBytes(Data(action.command.utf8))
                } else {
                    manager.sendCommand(action.command)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showSlashCommands && !slashCommandSuggestions.isEmpty {
                VStack {
                    Spacer()
                    SlashCommandSuggestionView(
                        commands: slashCommandSuggestions,
                        onSelect: { command in
                            // Insert the command into terminal
                            let commandText = command.name + "\n"
                            manager.sendCommand(commandText)
                            showSlashCommands = false
                            currentInput = ""
                        },
                        onDismiss: {
                            showSlashCommands = false
                            currentInput = ""
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .enableInjection()
    }

    private var terminalBackground: some View {
        ZStack {
            Color(red: 0.04, green: 0.055, blue: 0.102)

            RadialGradient(
                colors: [
                    profile.color.opacity(0.18),
                    Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.12),
                    Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 320
            )
            .scaleEffect(1.25)

            scanlinesOverlay
                .opacity(0.25)
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

    private var terminalHeader: some View {
        HStack(spacing: 12) {
            if profile.isCustomIcon {
                Image(profile.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundColor(profile.color)
            } else {
                Image(systemName: profile.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(profile.color)
            }

            Text("\(profile.name.uppercased())")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            profile.color,
                            Color(red: 0.376, green: 0.937, blue: 1.0),
                            Color(red: 1.0, green: 0.42, blue: 0.616)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .onTapGesture {
                    onHeaderTap?()
                }

            Spacer()

            Circle()
                .fill(manager.isConnected ? profile.color : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: (manager.isConnected ? profile.color : .red).opacity(0.55), radius: 4)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: manager.isConnected)

            Text(manager.isConnected ? "CONNECTED" : "DISCONNECTED")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(manager.isConnected ? profile.color : .red)
                .tracking(0.6)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(red: 0.04, green: 0.055, blue: 0.102).opacity(0.85)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.102, green: 0.137, blue: 0.196),
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

    private var actionToolbar: some View {
        HStack(spacing: 12) {
            Button {
                showQuickActions = true
            } label: {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .semibold))
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

            Spacer()

            if let workingDirectory = profile.workingDirectory {
                Text(workingDirectory)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.terminalCode)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Button {
                hideKeyboard()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.cyan.opacity(0.7))
                    .frame(width: 36, height: 36)
            }

            Button {
                manager.disconnect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    manager.connect()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(manager.isConnected ? .cyan.opacity(0.7) : .cyan)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.32))
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var reconnectButton: some View {
        Button {
            showReconnectButton = false
            manager.connect()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 20))

                Text("Reconnect")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.376, green: 0.937, blue: 1.0),
                        Color(red: 1.0, green: 0.42, blue: 0.616)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.5),
                                        Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.3)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.35), radius: 12)
        }
        .padding(.bottom, 20)
    }

}

private extension Character {
    var isControl: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.generalCategory == .control
    }
}

// MARK: - SwiftTerm Wrapper

final class InteractiveTerminalView: TerminalView {
    override var canBecomeFirstResponder: Bool {
        true
    }

    override var canResignFirstResponder: Bool {
        true
    }
}

final class TerminalInputDelegate: NSObject, TerminalViewDelegate {
    var onInput: ((Data) -> Void)?

    func send(source: TerminalView, data: ArraySlice<UInt8>) {

        let dataToSend = Data(data)
        onInput?(dataToSend)
    }

    func scrolled(source: TerminalView, position: Double) {}
    func setTerminalTitle(source: TerminalView, title: String) {}
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {}
    func clipboardCopy(source: TerminalView, content: Data) {}
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
    func requestOpenLink(source: TerminalView, link: String, params: [String : String]) {}
    func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}

    func bell(source: TerminalView) {
#if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
#endif
    }

    func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}
}

struct TerminalViewWrapper: UIViewRepresentable {
    let outputData: Data
    let onInput: ((Data) -> Void)?
    let onSpecialKey: ((TerminalKey) -> Void)?
    let onSlashCommand: (() -> Void)?

    func makeUIView(context: Context) -> InteractiveTerminalView {

        let terminalView = InteractiveTerminalView(frame: .zero)
        terminalView.backgroundColor = UIColor(red: 0.04, green: 0.055, blue: 0.102, alpha: 1.0)
        terminalView.isUserInteractionEnabled = true

        // Keyboard toolbar temporarily disabled (focusing on chat terminal)
        // let keyboardToolbar = TerminalKeyboardAccessoryView(
        //     onKeyPress: { key in
        //         context.coordinator.onSpecialKey?(key)
        //     },
        //     onDismiss: {
        //         terminalView.resignFirstResponder()
        //     }
        // )
        // terminalView.inputAccessoryView = keyboardToolbar
        terminalView.inputAccessoryView = nil

        // Add tap gesture to focus terminal and show keyboard
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tapGesture.numberOfTapsRequired = 1
        terminalView.addGestureRecognizer(tapGesture)

        let delegate = TerminalInputDelegate()
        delegate.onInput = onInput
        terminalView.terminalDelegate = delegate
        context.coordinator.inputDelegate = delegate
        context.coordinator.onSpecialKey = onSpecialKey
        context.coordinator.onSlashCommand = onSlashCommand
        context.coordinator.terminalView = terminalView

        return terminalView
    }

    func updateUIView(_ uiView: InteractiveTerminalView, context: Context) {
        if outputData.count > context.coordinator.lastDataCount {
            let newData = outputData.suffix(from: context.coordinator.lastDataCount)

            uiView.getTerminal().feed(byteArray: [UInt8](newData))
            context.coordinator.lastDataCount = outputData.count
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        weak var terminalView: InteractiveTerminalView?
        var inputDelegate: TerminalInputDelegate?
        var lastDataCount: Int = 0
        var onSpecialKey: ((TerminalKey) -> Void)?
        var onSlashCommand: (() -> Void)?

        @objc func specialKeyPressed(_ sender: UIBarButtonItem) {
            guard sender.tag >= 0, sender.tag < TerminalKey.allCases.count else { return }
            let key = TerminalKey.allCases[sender.tag]
            terminalView?.getTerminal().feed(byteArray: key.bytes)
            onSpecialKey?(key)
        }

        @objc func slashCommandPressed() {
            onSlashCommand?()
        }

        @objc func handleTap() {
            let _ = terminalView?.becomeFirstResponder() ?? false
        }

        @objc func dismissKeyboard() {
            let _ = terminalView?.resignFirstResponder()
        }
    }
}
