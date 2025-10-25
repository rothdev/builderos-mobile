//
//  TerminalGradientText.swift
//  BuilderOS
//
//  Text with terminal gradient (cyan → pink → red)
//  Matches TerminalChatView branding
//

import SwiftUI
import Inject

struct TerminalGradientText: View {
    @ObserveInjection var inject

    let text: String
    var fontSize: CGFloat = 22
    var fontWeight: Font.Weight = .black

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: fontWeight, design: .monospaced))
            .tracking(1)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.terminalCyan, Color.terminalPink, Color.terminalRed],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .enableInjection()
    }
}

#Preview {
    VStack(spacing: 20) {
        TerminalGradientText(text: "BUILDEROS")

        TerminalGradientText(text: "Welcome Back", fontSize: 32, fontWeight: .bold)

        TerminalGradientText(text: "SYSTEM ONLINE", fontSize: 18, fontWeight: .semibold)
    }
    .padding()
    .background(Color.terminalDark)
}
