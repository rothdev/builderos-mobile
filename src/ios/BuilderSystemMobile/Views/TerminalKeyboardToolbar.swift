//
//  TerminalKeyboardToolbar.swift
//  BuilderSystemMobile
//
//  Custom keyboard accessory view for terminal with special keys
//

import SwiftUI

struct TerminalKeyboardToolbar: View {
    let onKeyPress: (TerminalKey) -> Void
    @State private var showFunctionKeys = false

    var body: some View {
        VStack(spacing: 0) {
            // Function keys row (collapsible)
            if showFunctionKeys {
                functionKeysRow
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Main special keys row
            mainKeysRow
        }
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1),
            alignment: .top
        )
    }

    // MARK: - Main Keys Row

    private var mainKeysRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Toggle function keys
                ToolbarButton(title: "F1-12", icon: showFunctionKeys ? "chevron.down" : "chevron.right") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showFunctionKeys.toggle()
                    }
                }

                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 4)

                // Special keys
                ToolbarButton(title: "ESC") {
                    onKeyPress(.escape)
                }

                ToolbarButton(title: "TAB") {
                    onKeyPress(.tab)
                }

                ToolbarButton(title: "CTRL") {
                    onKeyPress(.control)
                }

                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 4)

                // Arrow keys
                ToolbarButton(icon: "arrow.up") {
                    onKeyPress(.arrowUp)
                }

                ToolbarButton(icon: "arrow.down") {
                    onKeyPress(.arrowDown)
                }

                ToolbarButton(icon: "arrow.left") {
                    onKeyPress(.arrowLeft)
                }

                ToolbarButton(icon: "arrow.right") {
                    onKeyPress(.arrowRight)
                }

                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 4)

                // Common combos
                ToolbarButton(title: "^C", subtitle: "Cancel") {
                    onKeyPress(.ctrlC)
                }

                ToolbarButton(title: "^D", subtitle: "Exit") {
                    onKeyPress(.ctrlD)
                }

                ToolbarButton(title: "^Z", subtitle: "Suspend") {
                    onKeyPress(.ctrlZ)
                }

                ToolbarButton(title: "^L", subtitle: "Clear") {
                    onKeyPress(.ctrlL)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 50)
    }

    // MARK: - Function Keys Row

    private var functionKeysRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...12, id: \.self) { num in
                    ToolbarButton(title: "F\(num)") {
                        onKeyPress(.function(num))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 50)
    }
}

// MARK: - Toolbar Button

private struct ToolbarButton: View {
    let title: String?
    let subtitle: String?
    let icon: String?
    let action: () -> Void

    init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = nil
        self.action = action
    }

    init(icon: String, action: @escaping () -> Void) {
        self.title = nil
        self.subtitle = nil
        self.icon = icon
        self.action = action
    }

    init(title: String, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = nil
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let icon = icon {
                    if let title = title {
                        // Combined icon + text
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.system(size: 10))
                            Text(title)
                                .font(.system(size: 12, weight: .medium))
                        }
                    } else {
                        // Icon only
                        Image(systemName: icon)
                            .font(.system(size: 16))
                    }
                } else if let title = title {
                    // Text only
                    Text(title)
                        .font(.system(size: 12, weight: .semibold).monospaced())

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(minWidth: 44, minHeight: 34)
            .padding(.horizontal, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

// MARK: - Terminal Key Types

enum TerminalKey {
    case escape
    case tab
    case control
    case arrowUp
    case arrowDown
    case arrowLeft
    case arrowRight
    case ctrlC
    case ctrlD
    case ctrlZ
    case ctrlL
    case function(Int)

    /// Convert to byte sequence for sending to terminal
    var bytes: [UInt8] {
        switch self {
        case .escape:
            return [0x1B]  // ESC
        case .tab:
            return [0x09]  // TAB
        case .control:
            return []  // Modifier only, no direct byte
        case .arrowUp:
            return [0x1B, 0x5B, 0x41]  // ESC [ A
        case .arrowDown:
            return [0x1B, 0x5B, 0x42]  // ESC [ B
        case .arrowRight:
            return [0x1B, 0x5B, 0x43]  // ESC [ C
        case .arrowLeft:
            return [0x1B, 0x5B, 0x44]  // ESC [ D
        case .ctrlC:
            return [0x03]  // Ctrl+C (SIGINT)
        case .ctrlD:
            return [0x04]  // Ctrl+D (EOF)
        case .ctrlZ:
            return [0x1A]  // Ctrl+Z (SIGTSTP)
        case .ctrlL:
            return [0x0C]  // Ctrl+L (clear screen)
        case .function(let num):
            // Function keys F1-F12 (xterm sequences)
            switch num {
            case 1: return [0x1B, 0x4F, 0x50]  // F1: ESC O P
            case 2: return [0x1B, 0x4F, 0x51]  // F2: ESC O Q
            case 3: return [0x1B, 0x4F, 0x52]  // F3: ESC O R
            case 4: return [0x1B, 0x4F, 0x53]  // F4: ESC O S
            case 5: return [0x1B, 0x5B, 0x31, 0x35, 0x7E]  // F5: ESC [ 1 5 ~
            case 6: return [0x1B, 0x5B, 0x31, 0x37, 0x7E]  // F6: ESC [ 1 7 ~
            case 7: return [0x1B, 0x5B, 0x31, 0x38, 0x7E]  // F7: ESC [ 1 8 ~
            case 8: return [0x1B, 0x5B, 0x31, 0x39, 0x7E]  // F8: ESC [ 1 9 ~
            case 9: return [0x1B, 0x5B, 0x32, 0x30, 0x7E]  // F9: ESC [ 2 0 ~
            case 10: return [0x1B, 0x5B, 0x32, 0x31, 0x7E]  // F10: ESC [ 2 1 ~
            case 11: return [0x1B, 0x5B, 0x32, 0x33, 0x7E]  // F11: ESC [ 2 3 ~
            case 12: return [0x1B, 0x5B, 0x32, 0x34, 0x7E]  // F12: ESC [ 2 4 ~
            default: return []
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        TerminalKeyboardToolbar { key in
            print("Key pressed: \(key)")
        }
    }
}
