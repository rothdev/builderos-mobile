//
//  ChatPersistenceManager.swift
//  BuilderOS
//
//  Local persistence for Claude Agent chat messages using UserDefaults
//

import Foundation
import Combine

@MainActor
class ChatPersistenceManager: ObservableObject {
    // MARK: - Constants

    private let userDefaultsKeyPrefix = "builderos_claude_chat_history_"
    private let maxMessages = 200 // Keep last 200 messages to prevent storage bloat

    // MARK: - Published Properties

    @Published var messages: [ClaudeChatMessage] = []

    // MARK: - Initialization

    init() {
        // No longer auto-load messages - must call loadMessages(for:) with sessionId
    }

    // MARK: - Public Methods

    /// Save a new message to persistent storage for a specific session
    func saveMessage(_ message: ClaudeChatMessage, sessionId: String) {
        var sessionMessages = loadMessages(for: sessionId)
        sessionMessages.append(message)
        setMessages(sessionMessages, for: sessionId)
    }

    /// Load messages from persistent storage for a specific session
    func loadMessages(for sessionId: String) -> [ClaudeChatMessage] {
        let key = userDefaultsKeyPrefix + sessionId
        guard let data = UserDefaults.standard.data(forKey: key) else {
            print("📂 No saved chat history found for session: \(sessionId)")
            return []
        }

        do {
            let decoded = try JSONDecoder().decode([ClaudeChatMessage].self, from: data)
            print("✅ Loaded \(decoded.count) messages from storage for session: \(sessionId)")
            return decoded
        } catch {
            print("❌ Failed to decode chat history for session \(sessionId): \(error)")
            return []
        }
    }

    /// Clear all messages from storage for a specific session
    func clearMessages(for sessionId: String) {
        let key = userDefaultsKeyPrefix + sessionId
        UserDefaults.standard.removeObject(forKey: key)
        print("🗑️ Cleared all chat messages for session: \(sessionId)")
    }

    /// Replace entire message array for a specific session (useful for bulk operations)
    func setMessages(_ newMessages: [ClaudeChatMessage], for sessionId: String) {
        let key = userDefaultsKeyPrefix + sessionId
        var trimmedMessages = newMessages

        // Trim messages to maximum limit (keep most recent)
        if trimmedMessages.count > maxMessages {
            let excessCount = trimmedMessages.count - maxMessages
            trimmedMessages.removeFirst(excessCount)
            print("✂️ Trimmed \(excessCount) old messages for session \(sessionId) (keeping last \(maxMessages))")
        }

        do {
            let encoded = try JSONEncoder().encode(trimmedMessages)
            UserDefaults.standard.set(encoded, forKey: key)
            print("💾 Saved \(trimmedMessages.count) messages to storage for session: \(sessionId)")
        } catch {
            print("❌ Failed to encode messages for session \(sessionId): \(error)")
        }
    }

    /// Delete all stored sessions (for full app reset)
    func deleteAllSessions() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(userDefaultsKeyPrefix) {
            UserDefaults.standard.removeObject(forKey: key)
            print("🗑️ Deleted session: \(key)")
        }
    }
}
