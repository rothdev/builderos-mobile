//
//  ProfileSwitcher.swift
//  BuilderOS
//
//  Horizontal scrollable profile chip selector
//

import SwiftUI

struct ProfileSwitcher: View {
    @Binding var selectedProfile: TerminalProfile
    let profiles: [TerminalProfile]
    let onProfileChange: (TerminalProfile) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(profiles) { profile in
                    ProfileChip(
                        profile: profile,
                        isSelected: selectedProfile.id == profile.id,
                        onTap: { onProfileChange(profile) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 52)
        .background(Color.black.opacity(0.2))
    }
}

struct ProfileChip: View {
    let profile: TerminalProfile
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: profile.icon)
                    .font(.system(size: 14, weight: .semibold))

                Text(profile.name)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : profile.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? profile.color : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(profile.color, lineWidth: isSelected ? 0 : 1.5)
                    )
            )
            .shadow(
                color: isSelected ? profile.color.opacity(0.3) : .clear,
                radius: 8,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Selected Shell
        ProfileSwitcher(
            selectedProfile: .constant(.shell),
            profiles: TerminalProfile.all,
            onProfileChange: { _ in }
        )

        // Selected Claude
        ProfileSwitcher(
            selectedProfile: .constant(.claude),
            profiles: TerminalProfile.all,
            onProfileChange: { _ in }
        )

        // Selected Codex
        ProfileSwitcher(
            selectedProfile: .constant(.codex),
            profiles: TerminalProfile.all,
            onProfileChange: { _ in }
        )
    }
    .background(Color.black)
}
