//
//  TerminalTab.swift
//  BuilderOS
//
//  Terminal tab model for multi-tab terminal interface
//

import SwiftUI

struct TerminalTab: Identifiable {
    let id: UUID
    let profile: TerminalProfile
    var title: String  // e.g., "Shell", "Claude", "Codex"

    init(profile: TerminalProfile) {
        self.id = UUID()
        self.profile = profile
        self.title = profile.name
    }
}
