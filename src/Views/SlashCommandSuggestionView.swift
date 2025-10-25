//
//  SlashCommandSuggestionView.swift
//  BuilderOS
//
//  Slash command autocomplete suggestions popup
//

import SwiftUI

struct SlashCommandSuggestionView: View {
    let commands: [SlashCommand]
    let onSelect: (SlashCommand) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "command")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.terminalCyan)

                Text("Slash Commands")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.terminalText)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.terminalDim)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.terminalDark.opacity(0.95))

            Divider()
                .background(Color.terminalCyan.opacity(0.3))

            // Command list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(commands) { command in
                        SlashCommandRow(command: command, onSelect: onSelect)
                    }

                    if commands.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(.terminalDim)
                                .padding(.top, 32)

                            Text("No matching commands")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.terminalDim)
                                .padding(.bottom, 32)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxHeight: 280)
        }
        .background(
            Color.terminalDark.opacity(0.98)
                .background(.ultraThinMaterial)
        )
        .cornerRadius(12)
        .shadow(color: .terminalCyan.opacity(0.2), radius: 20, y: -5)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

struct SlashCommandRow: View {
    let command: SlashCommand
    let onSelect: (SlashCommand) -> Void

    var body: some View {
        Button(action: { onSelect(command) }) {
            HStack(alignment: .top, spacing: 12) {
                // Command name
                Text(command.name)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.terminalCyan)
                    .frame(minWidth: 100, alignment: .leading)

                // Description
                Text(command.description)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.terminalCode)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                // Category badge
                Text(command.category)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor(for: command.category))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color.terminalDim.opacity(0.0)
            )
        }
        .buttonStyle(.plain)
        .background(
            Color.terminalCyan.opacity(0.05)
                .opacity(0)  // Subtle hover effect would go here
        )

        Divider()
            .background(Color.terminalDim.opacity(0.2))
            .padding(.leading, 16)
    }

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Navigation": return Color(red: 0.0, green: 1.0, blue: 0.533)  // Green
        case "Supabase": return Color(red: 0.376, green: 0.937, blue: 1.0)  // Cyan
        case "Git": return Color(red: 1.0, green: 0.42, blue: 0.616)  // Pink
        case "System": return Color(red: 1.0, green: 0.8, blue: 0.0)  // Yellow
        default: return Color(red: 0.6, green: 0.6, blue: 0.6)  // Gray
        }
    }
}

#Preview {
    SlashCommandSuggestionView(
        commands: SlashCommand.all,
        onSelect: { _ in },
        onDismiss: {}
    )
    .background(Color.black)
}
