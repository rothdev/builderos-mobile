//
//  QuickActionsSheet.swift
//  BuilderOS
//
//  Shared sheet for launching predefined terminal actions.
//

import SwiftUI
import Inject

struct QuickActionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let actions: [QuickAction]
    let onSelect: (QuickAction) -> Void
    @ObserveInjection var inject

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(actions) { action in
                        Button {
                            onSelect(action)
                            dismiss()
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: action.icon)
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0))
                                Text(action.title.uppercased())
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .enableInjection()
    }
}

#Preview {
    QuickActionsSheet(actions: QuickAction.all, onSelect: { _ in })
}
