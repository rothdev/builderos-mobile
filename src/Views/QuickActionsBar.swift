//
//  QuickActionsBar.swift
//  BuilderOS
//
//  Quick action buttons for common terminal operations
//

import SwiftUI
import Inject

struct QuickActionsBar: View {
    let actions: [QuickAction]
    let onAction: (QuickAction) -> Void
    @ObserveInjection var inject

    var body: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(actions) { action in
                    QuickActionButton(action: action, onTap: { onAction(action) })
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(height: 70)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.1),
                            Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1),
            alignment: .top
        )
        .enableInjection()
    }
}

struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    @ObserveInjection var inject

    var body: some View{
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: action.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0))

                Text(action.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(width: 68, height: 54)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .enableInjection()
    }
}

#Preview {
    VStack {
        Spacer()

        QuickActionsBar(
            actions: QuickAction.all,
            onAction: { action in
                print("Executed: \(action.title)")
            }
        )
    }
    .background(Color(red: 0.04, green: 0.055, blue: 0.102))
}
