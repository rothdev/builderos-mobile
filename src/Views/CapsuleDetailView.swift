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
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                TerminalGradientText(text: capsule.name, fontSize: 20, fontWeight: .bold)

                                Text(capsule.path)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(Color.terminalCode)
                                    .lineLimit(1)
                            }

                            Spacer()

                            // Status Badge
                            TerminalStatusBadge(
                                text: capsule.status.displayName.uppercased(),
                                color: statusColor,
                                shouldPulse: capsule.status == .active
                            )
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        TerminalSectionHeader(title: "DESCRIPTION")

                        TerminalCard {
                            Text(capsule.description)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color.terminalText)
                        }
                    }

                    // Tags
                    if !capsule.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            TerminalSectionHeader(title: "TAGS")

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(capsule.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .foregroundColor(Color.terminalCyan)
                                            .background(Color.terminalInputBackground)
                                            .terminalBorder(cornerRadius: 8)
                                    }
                                }
                            }
                        }
                    }

                    // Metrics
                    VStack(alignment: .leading, spacing: 12) {
                        TerminalSectionHeader(title: "METRICS")

                        TerminalCard {
                            VStack(spacing: 12) {
                                MetricRow(label: "Created", value: formatDate(capsule.createdAt))
                                Divider().background(Color.terminalInputBorder)
                                MetricRow(label: "Updated", value: formatDate(capsule.updatedAt))
                                Divider().background(Color.terminalInputBorder)
                                MetricRow(label: "Tags", value: "\(capsule.tags.count)")
                            }
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

    private var statusColor: Color {
        switch capsule.status {
        case .active:
            return .terminalGreen
        case .development:
            return .terminalCyan
        case .testing:
            return .terminalPink
        case .archived:
            return Color.terminalDim
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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
