//
//  ConversationTabButton.swift
//  BuilderOS
//
//  Individual conversation tab button for multi-tab chat interface
//

import SwiftUI
import Inject

struct ConversationTabButton: View {
    let tab: ConversationTab
    let isSelected: Bool
    let onTap: () -> Void
    let onClose: () -> Void
    let canClose: Bool
    @ObserveInjection var inject

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    // Provider icon
                    if tab.provider.isCustomIcon {
                        Image(tab.provider.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(isSelected ? .white : tab.provider.accentColor)
                    } else {
                        Image(systemName: tab.provider.icon)
                            .font(.system(size: 12))
                            .foregroundColor(isSelected ? .white : tab.provider.accentColor)
                    }

                    // Tab title
                    Text(tab.title)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))

                    // Close button
                    if canClose {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? tab.provider.accentColor.opacity(0.3) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? tab.provider.accentColor : Color.clear, lineWidth: 1)
                )

                // Animated underline bar
                Rectangle()
                    .fill(tab.provider.accentColor)
                    .frame(height: 2)
                    .frame(width: isSelected ? nil : 0)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isSelected)
        .enableInjection()
    }
}

#Preview {
    HStack {
        ConversationTabButton(
            tab: ConversationTab(provider: .claude),
            isSelected: true,
            onTap: {},
            onClose: {},
            canClose: true
        )

        ConversationTabButton(
            tab: ConversationTab(provider: .codex),
            isSelected: false,
            onTap: {},
            onClose: {},
            canClose: true
        )
    }
    .padding()
    .background(Color.black)
}
