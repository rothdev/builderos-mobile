//
//  TerminalBorder.swift
//  BuilderOS
//
//  View modifier for terminal-style borders
//  Matches TerminalChatView border styling
//

import SwiftUI
import Inject

struct TerminalBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    var borderColor: Color = .terminalInputBorder
    var lineWidth: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: lineWidth)
            )
    }
}

extension View {
    /// Apply terminal-style border with rounded corners
    func terminalBorder(cornerRadius: CGFloat = 12, color: Color = .terminalInputBorder, lineWidth: CGFloat = 1) -> some View {
        modifier(TerminalBorderModifier(cornerRadius: cornerRadius, borderColor: color, lineWidth: lineWidth))
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Standard Border")
            .padding()
            .background(Color.terminalInputBackground)
            .terminalBorder()

        Text("Gradient Border")
            .padding()
            .background(Color.terminalInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.terminalCyan, Color.terminalPink, Color.terminalRed],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
    .padding()
    .background(Color.terminalDark)
}
