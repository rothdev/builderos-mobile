//
//  TerminalCard.swift
//  BuilderOS
//
//  Glassmorphic card component with terminal border styling
//  Matches TerminalChatView design system
//

import SwiftUI
import Inject

struct TerminalCard<Content: View>: View {
    @ObserveInjection var inject

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.terminalInputBorder, lineWidth: 1)
            )
            .enableInjection()
    }
}

#Preview {
    VStack(spacing: 16) {
        TerminalCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Card Title")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.terminalCyan)

                Text("Card content goes here with terminal styling")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.terminalText)
            }
        }

        TerminalCard {
            HStack {
                Circle()
                    .fill(Color.terminalGreen)
                    .frame(width: 8, height: 8)
                Text("Status Indicator")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.terminalText)
                Spacer()
            }
        }
    }
    .padding()
    .background(Color.terminalDark)
}
