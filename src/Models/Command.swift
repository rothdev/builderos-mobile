//
//  Command.swift
//  BuilderOS
//
//  Command suggestion model for terminal autocomplete
//

import Foundation

struct Command: Identifiable {
    let id: String
    let name: String
    let description: String
    let category: String
    let icon: String  // SF Symbol name

    init(
        id: String? = nil,
        name: String,
        description: String,
        category: String,
        icon: String = "command"
    ) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.description = description
        self.category = category
        self.icon = icon
    }
}

// MARK: - Pre-configured Commands

extension Command {
    // BuilderOS Commands
    static let builderOSCommands = [
        Command(name: "/claude", description: "Start Claude Code session", category: "AI", icon: "brain"),
        Command(name: "/codex", description: "Consult with Codex AI", category: "AI", icon: "message.and.waveform.fill"),
        Command(name: "/nav", description: "Navigate to capsule", category: "Navigation", icon: "location"),
        Command(name: "/capsules", description: "List all capsules", category: "Navigation", icon: "cube.box"),
        Command(name: "/agents", description: "List available agents", category: "BuilderOS", icon: "person.3"),
        Command(name: "/status", description: "System status", category: "BuilderOS", icon: "chart.bar"),
        Command(name: "/help", description: "Show help", category: "General", icon: "questionmark.circle"),
        Command(name: "/clear", description: "Clear terminal", category: "General", icon: "clear"),
    ]

    // Common Shell Commands
    static let shellCommands = [
        Command(name: "ls", description: "List directory contents", category: "Shell", icon: "list.bullet"),
        Command(name: "ls -la", description: "List all files with details", category: "Shell", icon: "list.bullet.rectangle"),
        Command(name: "cd", description: "Change directory", category: "Shell", icon: "folder"),
        Command(name: "pwd", description: "Print working directory", category: "Shell", icon: "folder.badge.questionmark"),
        Command(name: "cat", description: "Display file contents", category: "Shell", icon: "doc.text"),
        Command(name: "mkdir", description: "Create directory", category: "Shell", icon: "folder.badge.plus"),
        Command(name: "rm", description: "Remove file/directory", category: "Shell", icon: "trash"),
        Command(name: "cp", description: "Copy files", category: "Shell", icon: "doc.on.doc"),
        Command(name: "mv", description: "Move/rename files", category: "Shell", icon: "arrow.right.doc.on.clipboard"),
    ]

    // Git Commands
    static let gitCommands = [
        Command(name: "git status", description: "Git status", category: "Git", icon: "arrow.triangle.branch"),
        Command(name: "git log", description: "Git commit history", category: "Git", icon: "clock.arrow.circlepath"),
        Command(name: "git diff", description: "Show changes", category: "Git", icon: "doc.text.magnifyingglass"),
        Command(name: "git add .", description: "Stage all changes", category: "Git", icon: "plus.circle"),
        Command(name: "git commit -m \"", description: "Commit changes", category: "Git", icon: "checkmark.circle"),
        Command(name: "git push", description: "Push to remote", category: "Git", icon: "arrow.up.circle"),
        Command(name: "git pull", description: "Pull from remote", category: "Git", icon: "arrow.down.circle"),
    ]

    static let all = builderOSCommands + shellCommands + gitCommands
}
