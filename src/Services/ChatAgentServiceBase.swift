import Foundation
import Combine
import UIKit

/// Shared chat message model used by BuilderOS chat providers.
struct ClaudeChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    var attachments: [ChatAttachment]

    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date(), attachments: [ChatAttachment] = []) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.attachments = attachments
    }

    static func == (lhs: ClaudeChatMessage, rhs: ClaudeChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

/// Base class for chat provider services (Claude, Codex, etc.).
@MainActor
class ChatAgentServiceBase: ObservableObject {
    @Published var messages: [ClaudeChatMessage] = []
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    @Published var connectionStatus: String = "Disconnected"

    // App lifecycle observers
    private var lifecycleObservers: Set<AnyCancellable> = []
    private var shouldMaintainConnection: Bool = false

    init() {
        setupLifecycleObservers()
    }

    // MARK: - App Lifecycle Management

    /// Setup observers for iOS app lifecycle events to prevent unwanted disconnections
    private func setupLifecycleObservers() {
        // Observe when app will resign active (e.g., tab switch, lock screen)
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                print("📱 App will resign active - maintaining WebSocket connection")
                // Don't disconnect - just mark that we should maintain connection
                self?.shouldMaintainConnection = self?.isConnected ?? false
            }
            .store(in: &lifecycleObservers)

        // Observe when app becomes active again
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("📱 App did become active - checking connection status")

                // If we were connected before and should maintain connection, reconnect if needed
                if self.shouldMaintainConnection && !self.isConnected {
                    print("🔄 Reconnecting after app became active...")
                    Task { @MainActor in
                        try? await self.connect()
                    }
                }
            }
            .store(in: &lifecycleObservers)

        // Observe when app enters background
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                print("📱 App entered background - connection will be maintained if possible")
                // Mark connection state but don't disconnect
                self?.shouldMaintainConnection = self?.isConnected ?? false
            }
            .store(in: &lifecycleObservers)

        // Observe when app enters foreground
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("📱 App entering foreground - verifying connection")

                // Verify connection is still alive, reconnect if needed
                if self.shouldMaintainConnection && !self.isConnected {
                    print("🔄 Auto-reconnecting after foreground...")
                    Task { @MainActor in
                        try? await self.connect()
                    }
                }
            }
            .store(in: &lifecycleObservers)

        print("✅ App lifecycle observers configured for persistent connections")
    }

    // MARK: - Lifecycle (override in subclasses)

    func connect() async throws {
        fatalError("Subclasses must override connect()")
    }

    func disconnect() {
        shouldMaintainConnection = false  // Explicit disconnect
        // Subclasses should override and call super.disconnect()
    }

    func sendMessage(_ text: String) async throws {
        fatalError("Subclasses must override sendMessage(_:)")
    }

    func clearMessages() {
        messages.removeAll()
        isLoading = false
    }
}

// MARK: - Persistent Service Manager

/// Singleton manager that maintains multiple service instances per session
@MainActor
class ChatServiceManager: ObservableObject {
    static let shared = ChatServiceManager()

    // Store multiple instances keyed by sessionId
    @Published private(set) var claudeServices: [String: ClaudeAgentService] = [:]
    @Published private(set) var codexServices: [String: CodexAgentService] = [:]

    private var observers: Set<AnyCancellable> = []

    private init() {
        print("🏗️ ChatServiceManager initialized (singleton)")
    }

    func getOrCreateClaudeService(sessionId: String) -> ClaudeAgentService {
        if let existing = claudeServices[sessionId] {
            print("♻️ Reusing existing Claude service for session: \(sessionId)")
            return existing
        }

        print("🆕 Creating new Claude service for session: \(sessionId)")
        let service = ClaudeAgentService(sessionId: sessionId)
        claudeServices[sessionId] = service

        // Observe changes for SwiftUI updates
        service.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &observers)

        return service
    }

    func getOrCreateCodexService(sessionId: String) -> CodexAgentService {
        if let existing = codexServices[sessionId] {
            print("♻️ Reusing existing Codex service for session: \(sessionId)")
            return existing
        }

        print("🆕 Creating new Codex service for session: \(sessionId)")
        let service = CodexAgentService(sessionId: sessionId)
        codexServices[sessionId] = service

        // Observe changes for SwiftUI updates
        service.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &observers)

        return service
    }

    func removeClaudeService(sessionId: String) {
        if let service = claudeServices[sessionId] {
            print("🗑️ Removing Claude service for session: \(sessionId)")
            service.disconnect()
            claudeServices.removeValue(forKey: sessionId)
        }
    }

    func removeCodexService(sessionId: String) {
        if let service = codexServices[sessionId] {
            print("🗑️ Removing Codex service for session: \(sessionId)")
            service.disconnect()
            codexServices.removeValue(forKey: sessionId)
        }
    }

    func disconnectAll() {
        print("🔌 Disconnecting all services")
        for service in claudeServices.values {
            service.disconnect()
        }
        for service in codexServices.values {
            service.disconnect()
        }
        claudeServices.removeAll()
        codexServices.removeAll()
    }
}
