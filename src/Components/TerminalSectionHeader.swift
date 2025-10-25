//
//  TerminalSectionHeader.swift
//  BuilderOS
//
//  Monospaced section header with terminal cyan color
//  Matches TerminalChatView typography
//

import SwiftUI
import Inject

struct TerminalSectionHeader: View {
    @ObserveInjection var inject

    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .bold, design: .monospaced))
            .foregroundColor(.terminalCyan)
            .tracking(0.5)
            .enableInjection()
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        TerminalSectionHeader(title: "SYSTEM STATUS")

        TerminalSectionHeader(title: "CAPSULES")

        TerminalSectionHeader(title: "CLOUDFLARE TUNNEL")
    }
    .padding()
    .background(Color.terminalDark)
}
