//
//  TerminalProfile.swift
//  BuilderOS
//
//  Terminal profile configurations for different shell environments
//

import SwiftUI

struct TerminalProfile: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String  // SF Symbol name or Asset name
    let isCustomIcon: Bool  // true if icon is an Asset, false if SF Symbol
    let color: Color
    let initialCommand: String?  // Command to run on connect
    let workingDirectory: String?
    let environmentVars: [String: String]?

    init(
        id: String? = nil,
        name: String,
        icon: String,
        isCustomIcon: Bool = false,
        color: Color,
        initialCommand: String? = nil,
        workingDirectory: String? = nil,
        environmentVars: [String: String]? = nil
    ) {
        self.id = id ?? name.lowercased().replacingOccurrences(of: " ", with: "-")
        self.name = name
        self.icon = icon
        self.isCustomIcon = isCustomIcon
        self.color = color
        self.initialCommand = initialCommand
        self.workingDirectory = workingDirectory
        self.environmentVars = environmentVars
    }

    static func == (lhs: TerminalProfile, rhs: TerminalProfile) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Pre-configured Profiles

extension TerminalProfile {
    static let shell = TerminalProfile(
        id: "shell",
        name: "Shell",
        icon: "terminal.fill",
        color: Color(red: 0.0, green: 1.0, blue: 0.533), // #00FF88
        initialCommand: nil,
        workingDirectory: "/Users/Ty/BuilderOS"
    )

    static let claude = TerminalProfile(
        id: "claude",
        name: "Jarvis",
        icon: "claude-logo",
        isCustomIcon: true,
        color: Color(red: 1.0, green: 0.42, blue: 0.616), // #FF6B9D - Pink/red matching UI theme
        initialCommand: "cd /Users/Ty/BuilderOS && printf '\\n\\033[1;35m  Jarvis\\033[0m v2.0.27\\n  \\033[0;90mSonnet 4.5 · Claude Max\\033[0m\\n  \\033[1;33m/Users/Ty/BuilderOS\\033[0m\\n\\n' && claude",
        workingDirectory: "/Users/Ty/BuilderOS"
    )

    static let codex = TerminalProfile(
        id: "codex",
        name: "Codex",
        icon: "openai-logo",
        isCustomIcon: true,
        color: Color(red: 0.231, green: 0.51, blue: 0.965), // #3B82F6
        initialCommand: "cd /Users/Ty/BuilderOS && printf '\\n  \\033[1;36m>_ OpenAI Codex\\033[0m (v0.47.0)\\n\\n  \\033[0;90mmodel:      \\033[1;37mgpt-5-codex\\033[0;90m     /model to change\\033[0m\\n  \\033[0;90mdirectory:  \\033[1;33m/Users/Ty/BuilderOS\\033[0m\\n\\n  \\033[1;32m>\\033[0m Type your message for Codex...\\n\\n'",
        workingDirectory: "/Users/Ty/BuilderOS"
    )

    static let all: [TerminalProfile] = [claude, codex, shell]  // Jarvis is default
}
