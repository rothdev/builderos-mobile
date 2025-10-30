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
    let sessionId: String  // Unique backend session ID for this chat

    enum ChatProvider: String, CaseIterable {
        case claude
        case codex

        var displayName: String {
            switch self {
            case .claude: return "Claude"
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
            case .claude: return "Message Claude..."
            case .codex: return "Message Codex..."
            }
        }
    }

    init(provider: ChatProvider, title: String? = nil, sessionId: String? = nil) {
        let tabId = UUID()
        self.id = tabId
        self.provider = provider
        self.title = title ?? provider.displayName

        // Generate unique session ID per chat tab
        if let customSessionId = sessionId {
            self.sessionId = customSessionId
        } else {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

            // FIXED: Each tab gets its own unique session ID using tabId
            // This ensures each chat has isolated conversation history
            let uniqueSessionId = "\(deviceId)-\(provider.rawValue)-\(tabId.uuidString)"
            self.sessionId = uniqueSessionId
            print("💾 Created unique session ID for \(provider.rawValue) tab: \(uniqueSessionId)")
        }
    }
}
