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
    let icon: String  // SF Symbol name
    let color: Color
    let initialCommand: String?  // Command to run on connect
    let workingDirectory: String?
    let environmentVars: [String: String]?

    init(
        id: String? = nil,
        name: String,
        icon: String,
        color: Color,
        initialCommand: String? = nil,
        workingDirectory: String? = nil,
        environmentVars: [String: String]? = nil
    ) {
        self.id = id ?? name.lowercased().replacingOccurrences(of: " ", with: "-")
        self.name = name
        self.icon = icon
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
        name: "Claude",
        icon: "brain",
        color: Color(red: 0.659, green: 0.333, blue: 0.969), // #A855F7
        initialCommand: "cd /Users/Ty/BuilderOS && claude",
        workingDirectory: "/Users/Ty/BuilderOS"
    )

    static let codex = TerminalProfile(
        id: "codex",
        name: "Codex",
        icon: "message.and.waveform.fill",
        color: Color(red: 0.231, green: 0.51, blue: 0.965), // #3B82F6
        initialCommand: "cd /Users/Ty/BuilderOS && echo 'Type your message for Codex, then press Ctrl+D:' && read -d '' message && node /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js --request '{\"version\":\"bridgehub/1.0\",\"action\":\"freeform\",\"capsule\":\"'$(pwd)'\",\"session\":\"mobile-'$(date +%s)'\",\"payload\":{\"message\":\"'\"$message\"'\"}}'",
        workingDirectory: "/Users/Ty/BuilderOS"
    )

    static let all: [TerminalProfile] = [shell, claude, codex]
}
