//
//  TerminalGradientText.swift
//  BuilderOS
//
//  Text with terminal gradient (cyan → pink → red)
//  Matches TerminalChatView branding
//

import SwiftUI

struct TerminalGradientText: View {
    let text: String
    var fontSize: CGFloat = 22
    var fontWeight: Font.Weight = .black

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: fontWeight, design: .monospaced))
            .tracking(1)
            .foregroundStyle(
                LinearGradient(
                    colors: [.terminalCyan, .terminalPink, .terminalRed],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        TerminalGradientText(text: "$ BUILDEROS")

        TerminalGradientText(text: "Welcome Back", fontSize: 32, fontWeight: .bold)

        TerminalGradientText(text: "SYSTEM ONLINE", fontSize: 18, fontWeight: .semibold)
    }
    .padding()
    .background(Color.terminalDark)
}
