//
//  CapsuleDetailView.swift
//  BuilderOS
//

import SwiftUI
import Inject

struct CapsuleDetailView: View {
    let capsule: Capsule
    var heroNamespace: Namespace.ID?
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
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .if(heroNamespace != nil) { view in
                        view.matchedGeometryEffect(id: capsule.id, in: heroNamespace!)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        TerminalSectionHeader(title: "PURPOSE")

                        TerminalCard {
                            Text(capsule.purpose)
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
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
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.bodyMedium)
                .fontWeight(.semibold)
        }
        .enableInjection()
    }
}

// Helper extension for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
