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

    private let userDefaultsKey = "builderos_claude_chat_history"
    private let maxMessages = 200 // Keep last 200 messages to prevent storage bloat

    // MARK: - Published Properties

    @Published var messages: [ClaudeChatMessage] = []

    // MARK: - Initialization

    init() {
        loadMessages()
    }

    // MARK: - Public Methods

    /// Save a new message to persistent storage
    func saveMessage(_ message: ClaudeChatMessage) {
        messages.append(message)
        trimMessagesIfNeeded()
        persistMessages()
    }

    /// Load messages from persistent storage
    func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("📂 No saved chat history found")
            messages = []
            return
        }

        do {
            let decoded = try JSONDecoder().decode([ClaudeChatMessage].self, from: data)
            messages = decoded
            print("✅ Loaded \(messages.count) messages from storage")
        } catch {
            print("❌ Failed to decode chat history: \(error)")
            messages = []
        }
    }

    /// Clear all messages from storage
    func clearMessages() {
        messages = []
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("🗑️ Cleared all chat messages")
    }

    /// Replace entire message array (useful for bulk operations)
    func setMessages(_ newMessages: [ClaudeChatMessage]) {
        messages = newMessages
        trimMessagesIfNeeded()
        persistMessages()
    }

    // MARK: - Private Methods

    /// Persist messages to UserDefaults
    private func persistMessages() {
        do {
            let encoded = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("💾 Saved \(messages.count) messages to storage")
        } catch {
            print("❌ Failed to encode messages: \(error)")
        }
    }

    /// Trim messages to maximum limit (keep most recent)
    private func trimMessagesIfNeeded() {
        guard messages.count > maxMessages else { return }

        let excessCount = messages.count - maxMessages
        messages.removeFirst(excessCount)
        print("✂️ Trimmed \(excessCount) old messages (keeping last \(maxMessages))")
    }
}
