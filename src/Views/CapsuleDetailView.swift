//
//  CapsuleDetailView.swift
//  BuilderOS
//

import SwiftUI
import Inject

struct CapsuleDetailView: View {
    let capsule: Capsule
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection var inject

    var body: some View {
        ZStack {
            // Terminal background
            Color.terminalDark
                .ignoresSafeArea()

            // Subtle radial gradient overlay
            RadialGradient(
                colors: [
                    Color.terminalCyan.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    TerminalCard {
                        VStack(alignment: .leading, spacing: 8) {
                            TerminalGradientText(text: capsule.title, fontSize: 20, fontWeight: .bold)

                            Text(capsule.name)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.terminalCode)
                                .lineLimit(1)
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        TerminalSectionHeader(title: "PURPOSE")

                        TerminalCard {
                            Text(capsule.purpose)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color.terminalText)
                        }
                    }

                    Spacer()
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .enableInjection()
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    @ObserveInjection var inject

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color.terminalCode)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.terminalCyan)
        }
        .enableInjection()
    }
}
