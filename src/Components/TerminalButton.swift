//
//  TerminalButton.swift
//  BuilderOS
//
//  Terminal-themed button with gradient background and glow effect
//  Matches TerminalChatView design system
//

import SwiftUI
import Inject

struct TerminalButton: View {
    @ObserveInjection var inject

    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .background(
            isDisabled ?
                LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom) :
                LinearGradient(
                    colors: [Color.terminalCyan, Color.terminalPink, Color.terminalRed],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.terminalCyan.opacity(isDisabled ? 0 : 0.4), radius: 12)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .enableInjection()
    }
}

#Preview {
    VStack(spacing: 20) {
        TerminalButton(title: "Primary Action") {
            print("Button tapped")
        }

        TerminalButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
    .background(Color.terminalDark)
}
