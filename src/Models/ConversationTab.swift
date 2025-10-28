//
//  ConversationTab.swift
//  BuilderOS
//
//  Conversation tab model for multi-tab chat interface
//

import SwiftUI

struct ConversationTab: Identifiable {
    let id: UUID
    let provider: ChatProvider
    var title: String

    enum ChatProvider: String, CaseIterable {
        case claude
        case codex

        var displayName: String {
            switch self {
            case .claude: return "Jarvis"
            case .codex: return "Codex"
            }
        }

        var icon: String {
            switch self {
            case .claude: return "claude-logo"  // Custom asset
            case .codex: return "openai-logo"   // Custom asset
            }
        }

        var isCustomIcon: Bool {
            return true  // Both use custom assets
        }

        var accentColor: Color {
            switch self {
            case .claude: return .terminalPink
            case .codex: return .terminalCyan
            }
        }

        var inputPlaceholder: String {
            switch self {
            case .claude: return "Message Jarvis..."
            case .codex: return "Message Codex..."
            }
        }
    }

    init(provider: ChatProvider, title: String? = nil) {
        self.id = UUID()
        self.provider = provider
        self.title = title ?? provider.displayName
    }
}
