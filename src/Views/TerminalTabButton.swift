//
//  TerminalTabButton.swift
//  BuilderOS
//
//  Individual terminal tab button for multi-tab interface
//

import SwiftUI
import Inject

struct TerminalTabButton: View {
    let tab: TerminalTab
    let isSelected: Bool
    let onTap: () -> Void
    let onClose: () -> Void
    let canClose: Bool
    @ObserveInjection var inject

    var body: some View{
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Profile icon
                if tab.profile.isCustomIcon {
                    Image(tab.profile.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(isSelected ? .white : tab.profile.color)
                } else {
                    Image(systemName: tab.profile.icon)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .white : tab.profile.color)
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
                    .fill(isSelected ? tab.profile.color.opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? tab.profile.color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .enableInjection()
    }
}

#Preview {
    HStack {
        TerminalTabButton(
            tab: TerminalTab(profile: .shell),
            isSelected: true,
            onTap: {},
            onClose: {},
            canClose: true
        )

        TerminalTabButton(
            tab: TerminalTab(profile: .claude),
            isSelected: false,
            onTap: {},
            onClose: {},
            canClose: true
        )
    }
    .padding()
    .background(Color.black)
}
