//
//  SlashCommand.swift
//  BuilderOS
//
//  BuilderOS Claude Code slash commands for mobile terminal
//

import Foundation

struct SlashCommand: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let category: String

    init(name: String, description: String, category: String = "General") {
        self.id = name
        self.name = name
        self.description = description
        self.category = category
    }
}

// MARK: - BuilderOS Slash Commands

extension SlashCommand {
    // Common BuilderOS slash commands synced from .claude/commands/
    static let all: [SlashCommand] = [
        // Mobile-specific
        SlashCommand(
            name: "/mobile",
            description: "Navigate to builderos-mobile capsule",
            category: "Navigation"
        ),

        // Supabase Toolkit
        SlashCommand(
            name: "/supabase-toolkit:supabase-schema-sync",
            description: "Sync database schema with Supabase",
            category: "Supabase"
        ),
        SlashCommand(
            name: "/supabase-toolkit:supabase-migration-assistant",
            description: "Generate and manage database migrations",
            category: "Supabase"
        ),
        SlashCommand(
            name: "/supabase-toolkit:supabase-data-explorer",
            description: "Explore and analyze database data",
            category: "Supabase"
        ),
        SlashCommand(
            name: "/supabase-toolkit:supabase-backup-manager",
            description: "Manage database backups",
            category: "Supabase"
        ),
        SlashCommand(
            name: "/supabase-toolkit:supabase-performance-optimizer",
            description: "Optimize database performance",
            category: "Supabase"
        ),

        // Git & Development
        SlashCommand(
            name: "/commit",
            description: "Create a git commit with conventional format",
            category: "Git"
        ),
        SlashCommand(
            name: "/pr",
            description: "Create a pull request",
            category: "Git"
        ),

        // System
        SlashCommand(
            name: "/help",
            description: "Show available slash commands",
            category: "System"
        ),
        SlashCommand(
            name: "/clear",
            description: "Clear terminal output",
            category: "System"
        )
    ]

    static func search(_ query: String) -> [SlashCommand] {
        guard query.hasPrefix("/") else { return [] }

        let searchTerm = String(query.dropFirst()).lowercased()

        if searchTerm.isEmpty {
            return Array(all.prefix(8))  // Show first 8 commands
        }

        return all.filter { command in
            let commandName = command.name.dropFirst().lowercased()
            return commandName.contains(searchTerm)
        }
    }
}
