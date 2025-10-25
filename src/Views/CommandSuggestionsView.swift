//
//  CommandSuggestionsView.swift
//  BuilderOS
//
//  Dropdown command suggestions for terminal autocomplete
//

import SwiftUI
import Inject

struct CommandSuggestionsView: View {
    let suggestions: [Command]
    let onSelect: (Command) -> Void
    @ObserveInjection var inject

    var body: some View {
        VStack(spacing: 0) {
            ForEach(suggestions.prefix(5)) { cmd in
                Button(action: { onSelect(cmd) }) {
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: cmd.icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0))
                            .frame(width: 28)

                        // Command info
                        VStack(alignment: .leading, spacing: 3) {
                            Text(cmd.name)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundColor(.white)

                            Text(cmd.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Category badge
                        Text(cmd.category)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.376, green: 0.937, blue: 1.0))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.15))
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.clear)
                }
                .buttonStyle(.plain)

                if cmd.id != suggestions.prefix(5).last?.id {
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.376, green: 0.937, blue: 1.0).opacity(0.3),
                            Color(red: 1.0, green: 0.42, blue: 0.616).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 16, y: 4)
        .padding(.horizontal, 16)
        .enableInjection()
    }
}

#Preview {
    VStack {
        Spacer()

        CommandSuggestionsView(
            suggestions: Array(Command.all.prefix(5)),
            onSelect: { cmd in
                print("Selected: \(cmd.name)")
            }
        )

        Spacer()
            .frame(height: 100)
    }
    .background(Color(red: 0.04, green: 0.055, blue: 0.102))
}
