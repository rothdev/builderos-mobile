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

    // Maximum messages to keep in memory (prevents unbounded growth)
    // REDUCED from 100 to 50 for better memory stability on physical devices
    private let maxMessagesInMemory: Int = 50

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
                print("📱 App entered background - starting background task to maintain connection")
                // Mark connection state but don't disconnect
                self?.shouldMaintainConnection = self?.isConnected ?? false
                self?.beginBackgroundTask()
            }
            .store(in: &lifecycleObservers)

        // Observe when app enters foreground
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("📱 App entering foreground - ending background task")

                // End background task
                self.endBackgroundTask()

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

    // MARK: - Background Task Management

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    /// Begin background task to keep connection alive (iOS gives ~30 seconds)
    private func beginBackgroundTask() {
        guard backgroundTaskID == .invalid else {
            print("⚠️ Background task already running")
            return
        }

        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "WebSocketConnection") { [weak self] in
            print("⏰ Background task expiring - cleaning up")
            self?.endBackgroundTask()
        }

        print("✅ Background task started (ID: \(backgroundTaskID.rawValue)) - connection will stay alive for ~30s")
    }

    /// End background task
    private func endBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }

        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
        print("✅ Background task ended")
    }

    // MARK: - Lifecycle (override in subclasses)

    func connect() async throws {
        fatalError("Subclasses must override connect()")
    }

    func disconnect() {
        shouldMaintainConnection = false  // Explicit disconnect
        // Subclasses should override and call super.disconnect()
    }

    func sendMessage(_ text: String, attachments: [ChatAttachment]) async throws {
        fatalError("Subclasses must override sendMessage(_:attachments:)")
    }

    func sendMessage(_ text: String) async throws {
        try await sendMessage(text, attachments: [])
    }

    func clearMessages() {
        messages.removeAll()
        isLoading = false
    }

    // MARK: - Memory Management

    /// Trim old messages if array exceeds maximum size (prevents unbounded memory growth)
    func trimMessagesIfNeeded() {
        guard messages.count > maxMessagesInMemory else { return }

        let messagesToRemove = messages.count - maxMessagesInMemory
        let trimmedMessages = Array(messages.suffix(maxMessagesInMemory))

        print("⚠️ Trimming \(messagesToRemove) old messages (keeping most recent \(maxMessagesInMemory))")
        messages = trimmedMessages
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

    /// Reconnect all active chat services
    /// Forces disconnection first to ensure clean reconnection even if services think they're still connected
    func reconnectAll() async {
        print("🔄🔄🔄 RECONNECT ALL CALLED 🔄🔄🔄")
        print("📊 Active Claude services: \(claudeServices.count)")
        print("📊 Active Codex services: \(codexServices.count)")

        var reconnectCount = 0
        var successCount = 0

        // Reconnect all Claude services
        for (sessionId, service) in claudeServices {
            reconnectCount += 1
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🔄 RECONNECTING Claude service #\(reconnectCount)")
            print("   Session ID: \(sessionId)")

            // Check state before disconnect
            let wasConnected = await MainActor.run { service.isConnected }
            print("   State before disconnect: isConnected=\(wasConnected)")

            // Force disconnect first to clear any stale connection state
            print("   ⚡ Calling disconnect()...")
            service.disconnect()

            // Wait for disconnect to fully complete and propagate
            print("   ⏱️ Waiting 200ms for disconnect to complete...")
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms

            // Verify disconnected state
            let afterDisconnect = await MainActor.run { service.isConnected }
            print("   State after disconnect: isConnected=\(afterDisconnect)")

            do {
                print("   ⚡ Calling connect()...")
                try await service.connect()
                successCount += 1
                let afterConnect = await MainActor.run { service.isConnected }
                print("   ✅ Claude service reconnected successfully! isConnected=\(afterConnect)")
            } catch {
                print("   ❌ Failed to reconnect Claude service: \(error)")
                print("   ❌ Error details: \(error.localizedDescription)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }

        // Reconnect all Codex services
        for (sessionId, service) in codexServices {
            reconnectCount += 1
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🔄 RECONNECTING Codex service #\(reconnectCount)")
            print("   Session ID: \(sessionId)")

            // Check state before disconnect
            let wasConnected = await MainActor.run { service.isConnected }
            print("   State before disconnect: isConnected=\(wasConnected)")

            // Force disconnect first to clear any stale connection state
            print("   ⚡ Calling disconnect()...")
            service.disconnect()

            // Wait for disconnect to fully complete and propagate
            print("   ⏱️ Waiting 200ms for disconnect to complete...")
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms

            // Verify disconnected state
            let afterDisconnect = await MainActor.run { service.isConnected }
            print("   State after disconnect: isConnected=\(afterDisconnect)")

            do {
                print("   ⚡ Calling connect()...")
                try await service.connect()
                successCount += 1
                let afterConnect = await MainActor.run { service.isConnected }
                print("   ✅ Codex service reconnected successfully! isConnected=\(afterConnect)")
            } catch {
                print("   ❌ Failed to reconnect Codex service: \(error)")
                print("   ❌ Error details: \(error.localizedDescription)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }

        if reconnectCount == 0 {
            print("⚠️⚠️⚠️ NO ACTIVE CHAT SERVICES TO RECONNECT ⚠️⚠️⚠️")
            print("   Tip: Open a chat screen first to establish connections")
            print("   Then the reconnect button will work")
        } else {
            print("🎉🎉🎉 RECONNECTION COMPLETE 🎉🎉🎉")
            print("   Success: \(successCount)/\(reconnectCount) services reconnected")
        }
    }
}
