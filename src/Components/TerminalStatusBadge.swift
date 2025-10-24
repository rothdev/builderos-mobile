//
//  TerminalStatusBadge.swift
//  BuilderOS
//
//  Pulsing status indicator with glow effect
//  Matches TerminalChatView connection status design
//

import SwiftUI

struct TerminalStatusBadge: View {
    let text: String
    let color: Color
    var shouldPulse: Bool = true

    @State private var pulseAnimation = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.6), radius: shouldPulse ? 4 : 0)
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .animation(
                    shouldPulse ?
                        .easeInOut(duration: 2).repeatForever(autoreverses: true) :
                        .default,
                    value: pulseAnimation
                )

            Text(text)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(color)
                .tracking(0.5)
        }
        .onAppear {
            if shouldPulse {
                pulseAnimation = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TerminalStatusBadge(text: "CONNECTED", color: .terminalGreen)

        TerminalStatusBadge(text: "DISCONNECTED", color: .terminalRed, shouldPulse: false)

        TerminalStatusBadge(text: "OPERATIONAL", color: .terminalCyan)
    }
    .padding()
    .background(Color.terminalDark)
}
