//
//  QuickAction.swift
//  BuilderOS
//
//  Quick action buttons for common terminal operations
//

import Foundation

struct QuickAction: Identifiable {
    let id: String
    let title: String
    let icon: String  // SF Symbol name
    let command: String  // Command to execute

    init(
        id: String? = nil,
        title: String,
        icon: String,
        command: String
    ) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.icon = icon
        self.command = command
    }
}

// MARK: - Pre-configured Quick Actions

extension QuickAction {
    static let all = [
        QuickAction(title: "Clear", icon: "clear", command: "clear\n"),
        QuickAction(title: "Capsules", icon: "cube.box", command: "ls -la capsules/\n"),
        QuickAction(title: "Git Status", icon: "arrow.triangle.branch", command: "git status\n"),
        QuickAction(title: "Agents", icon: "person.3", command: "ls -la global/agents/\n"),
        QuickAction(title: "Kill", icon: "xmark.circle", command: "\u{03}"), // Ctrl+C
        QuickAction(title: "Home", icon: "house", command: "cd /Users/Ty/BuilderOS\n"),
        QuickAction(title: "PWD", icon: "folder.badge.questionmark", command: "pwd\n"),
        QuickAction(title: "Tools", icon: "wrench.and.screwdriver", command: "ls -la tools/\n"),
    ]
}
