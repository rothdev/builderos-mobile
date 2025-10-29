//
//  ClaudeChatView.swift
//  BuilderOS
//
//  Real Claude Agent chat interface with full BuilderOS context
//

import SwiftUI
import Inject
import Combine

struct ClaudeChatView: View {
    // Persistent service manager (survives tab changes)
    @StateObject private var serviceManager = ChatServiceManager.shared

    // Attachment service
    @StateObject private var attachmentService = AttachmentService()

    // Tab state
    @State private var tabs: [ConversationTab] = [ConversationTab(provider: .claude)]
    @State private var selectedTabId: UUID
    @State private var serviceInstances: [UUID: ChatAgentServiceBase] = [:]
    @State private var serviceObservers: [UUID: AnyCancellable] = [:]
    @State private var serviceVersion: Int = 0

    @ObserveInjection var inject
    @Binding var selectedTab: Int

    @State private var inputText: String = ""
    @State private var tabToClose: UUID?
    @State private var showingCloseConfirmation = false
    @FocusState private var isInputFocused: Bool

    // Initialize with first tab selected
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
        let initialTab = ConversationTab(provider: .claude)
        self._tabs = State(initialValue: [initialTab])
        self._selectedTabId = State(initialValue: initialTab.id)
    }

    // Current active tab and service
    private var activeTab: ConversationTab? {
        tabs.first { $0.id == selectedTabId }
    }

    private var activeService: ChatAgentServiceBase? {
        guard let tabId = activeTab?.id else { return nil }
        return serviceInstances[tabId]
    }

    private var activeProvider: ConversationTab.ChatProvider {
        activeTab?.provider ?? .claude
    }

    var body: some View {
        let _ = serviceVersion // force view refresh when services emit changes
        ZStack {
            // Terminal dark background
            Color.terminalDark
                .ignoresSafeArea()

            // Subtle radial gradient overlay
            RadialGradient(
                colors: [
                    Color.terminalCyan.opacity(0.1),
                    Color.terminalPink.opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab bar at top with connection status
                ConversationTabBar(
                    tabs: $tabs,
                    selectedTabId: $selectedTabId,
                    isConnected: activeService?.isConnected ?? false,
                    accentColor: activeProvider.accentColor,
                    onAddTab: { provider in
                        addNewTab(provider: provider)
                    },
                    onCloseTab: { tabId in
                        // Show confirmation before closing
                        tabToClose = tabId
                        showingCloseConfirmation = true
                    },
                    maxTabs: 5
                )

                // Message history
                if activeService != nil {
                    messageListView
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Dismiss keyboard when tapping chat area
                            isInputFocused = false
                        }
                } else {
                    // No service available (shouldn't happen)
                    Text("No conversation selected")
                        .foregroundColor(.terminalDim)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Divider()
                    .background(Color.terminalInputBorder)

                // Quick actions (horizontal scroll)
                quickActionsView

                Divider()
                    .background(Color.terminalInputBorder)

                // File preview chips (if any attachments selected)
                if !attachmentService.selectedAttachments.isEmpty {
                    filePreviewSection
                }

                // Input area
                inputView
            }

        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { gesture in
                    // Detect left-to-right swipe with some vertical tolerance
                    if gesture.translation.width > 100 && abs(gesture.translation.height) < 80 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedTab = 0  // Navigate to Dashboard
                        }
                    }
                }
        )
        .onAppear {
            print("🟢🟢🟢 ClaudeChatView.onAppear CALLED 🟢🟢🟢")
            print("   Current tab: \(activeProvider.displayName)")
            print("   Service instance: \(String(describing: activeService))")
            print("   Service connected: \(activeService?.isConnected ?? false)")

            // Initialize first tab's service
            if let firstTab = tabs.first {
                createServiceForTab(firstTab)
            }
        }
        .onDisappear {
            print("🔴🔴🔴 ClaudeChatView.onDisappear CALLED 🔴🔴🔴")
            print("   Current tab: \(activeProvider.displayName)")
            print("   Service instance: \(String(describing: activeService))")
            print("   Service connected: \(activeService?.isConnected ?? false)")
            print("   NOTE: NOT disconnecting - connections persist across tab switches")
        }
        .onChange(of: selectedTabId) {
            // Connect to service when tab changes
            if let service = serviceInstances[selectedTabId], !service.isConnected {
                Task {
                    try? await service.connect()
                }
            }
        }
        // NOTE: Removed .onDisappear disconnect logic
        // User directive: "there should be no timeout"
        // Connections should persist even when view is hidden
        // Only disconnect when user explicitly closes a tab
        .alert("Delete Conversation?", isPresented: $showingCloseConfirmation) {
            Button("Cancel", role: .cancel) {
                tabToClose = nil
            }
            Button("Delete", role: .destructive) {
                if let tabId = tabToClose {
                    removeTab(tabId)
                }
                tabToClose = nil
            }
        } message: {
            Text("This will permanently delete all messages in this conversation.")
        }
        .enableInjection()
    }


    // MARK: - Message List

    private var messageListView: some View {
        guard let service = activeService else {
            return AnyView(Text("No service available").foregroundColor(.terminalDim))
        }

        let providerName = activeProvider.displayName
        return AnyView(
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(service.messages) { message in
                            MessageBubbleView(message: message)
                                .transition(.messageBubble(isUser: message.isUser))
                                .id(message.id)
                        }

                        if service.isLoading {
                            EnhancedLoadingIndicator(providerName: providerName, accentColor: activeProvider.accentColor)
                        }
                    }
                    .padding()
                }
                .onChange(of: service.messages.count) {
                    if let lastMessage = service.messages.last {
                        withAnimation(AnimationPresets.tabTransition) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // Scroll to bottom when view appears (returning to chat tab)
                    if let lastMessage = service.messages.last {
                        // Small delay to ensure layout is complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        )
    }

    // MARK: - Quick Actions

    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickActionChip(
                    icon: "wrench.and.screwdriver.fill",
                    text: "Tools",
                    action: { sendQuickAction("Show me available tools") }
                )

                QuickActionChip(
                    icon: "app.badge.fill",
                    text: "Capsules",
                    action: { sendQuickAction("List all capsules") }
                )

                QuickActionChip(
                    icon: "chart.bar.fill",
                    text: "Metrics",
                    action: { sendQuickAction("Show system metrics") }
                )

                QuickActionChip(
                    icon: "person.3.fill",
                    text: "Agents",
                    action: { sendQuickAction("List available agents") }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.terminalDark.opacity(0.5))
    }

    // MARK: - File Preview Section

    private var filePreviewSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(attachmentService.selectedAttachments) { attachment in
                    FilePreviewChip(attachment: attachment) {
                        attachmentService.removeAttachment(attachment)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.terminalDark.opacity(0.5))
    }

    // MARK: - Input Area

    private var inputView: some View {
        HStack(spacing: 12) {
            // Attachment button
            AttachmentButton(
                onPhotoTap: { presentPhotoPicker() },
                onDocumentTap: { presentDocumentPicker() }
            )

            // Text input
            TextField(activeProvider.inputPlaceholder, text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminalText)
                .padding(12)
                .background(Color.terminalInputBackground)
                .terminalBorder(cornerRadius: 20)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }
                .tint(activeProvider.accentColor)

            // Voice button (disabled for now - VoiceManager needs to be added to target)
            // TODO: Re-enable when VoiceManager is added to BuilderOS target
            // Button(action: startVoiceInput) {
            //     Image(systemName: "mic")
            //         .font(.title3)
            //         .foregroundColor(.terminalCyan)
            //         .frame(width: 44, height: 44)
            //         .background(Color.terminalInputBackground)
            //         .clipShape(Circle())
            // }

            // Send button
           Button(action: sendMessage) {
               Image(systemName: "arrow.up.circle.fill")
                   .font(.title2)
                    .foregroundColor(canSend ? activeProvider.accentColor : .terminalDim)
           }
            .disabled(!canSend)
            .pressableButton()
        }
        .padding()
        .background(Color.terminalDark.opacity(0.9))
    }

    // MARK: - Computed Properties

    private var canSend: Bool {
        guard let service = activeService else { return false }
        return service.isConnected &&
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !service.isLoading
    }

    // MARK: - Actions

    private func createServiceForTab(_ tab: ConversationTab) {
        // Check if service already exists
        if serviceInstances[tab.id] != nil {
            print("⚠️ Service already exists for tab \(tab.provider.displayName), reusing it")
            return
        }

        print("📝 Creating persistent service for tab \(tab.provider.displayName) with session: \(tab.sessionId)")

        // Get persistent service from singleton manager (using unique sessionId per tab)
        let service: ChatAgentServiceBase
        switch tab.provider {
        case .claude:
            service = serviceManager.getOrCreateClaudeService(sessionId: tab.sessionId)
        case .codex:
            service = serviceManager.getOrCreateCodexService(sessionId: tab.sessionId)
        }

        serviceInstances[tab.id] = service

        // Observe changes so SwiftUI refreshes connection state and messages
        serviceObservers[tab.id]?.cancel()
        serviceObservers[tab.id] = service.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [self] _ in
                self.serviceVersion += 1
            }

        // Auto-connect (only if not already connected)
        // Note: The service's connect() method has its own guards for isConnecting/isConnected
        Task {
            // Check connection state before attempting
            let alreadyConnected = await MainActor.run { service.isConnected }

            guard !alreadyConnected else {
                print("⚠️ Skipping connection - service already connected for \(tab.provider.displayName)")
                return
            }

            do {
                print("🔵 Starting connection for \(tab.provider.displayName)...")
                try await service.connect()
                print("✅ \(tab.provider.displayName) connection successful!")
            } catch {
                print("❌ Failed to connect to \(tab.provider.displayName): \(error)")
                await MainActor.run {
                    service.connectionStatus = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func addNewTab(provider: ConversationTab.ChatProvider) {
        guard tabs.count < 5 else { return }

        let newTab = ConversationTab(provider: provider)
        tabs.append(newTab)
        createServiceForTab(newTab)
        selectedTabId = newTab.id
    }

    private func removeTab(_ tabId: UUID) {
        guard tabs.count > 1 else { return }

        // Find the tab to get its sessionId and provider
        guard let tab = tabs.first(where: { $0.id == tabId }) else { return }

        print("🗑️ Removing tab: \(tab.provider.displayName) with session: \(tab.sessionId)")

        // Remove service from manager (this disconnects and cleans up)
        switch tab.provider {
        case .claude:
            serviceManager.removeClaudeService(sessionId: tab.sessionId)
        case .codex:
            serviceManager.removeCodexService(sessionId: tab.sessionId)
        }

        // Remove tab from UI
        if let index = tabs.firstIndex(where: { $0.id == tabId }) {
            tabs.remove(at: index)
        }

        // Remove service reference
        serviceInstances.removeValue(forKey: tabId)

        // Cancel observer
        if let cancellable = serviceObservers[tabId] {
            cancellable.cancel()
            serviceObservers.removeValue(forKey: tabId)
        }

        // Select another tab if current was closed
        if selectedTabId == tabId {
            selectedTabId = tabs.first?.id ?? UUID()
        }
    }

    private func sendMessage() {
        guard canSend, let service = activeService else { return }

        let messageText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let attachmentsSnapshot = attachmentService.selectedAttachments

        Task { @MainActor in
            do {
                var attachmentsForMessage = attachmentsSnapshot

                if !attachmentsSnapshot.isEmpty {
                    try await attachmentService.uploadAllAttachments()
                    attachmentsForMessage = attachmentService.selectedAttachments

                    let failedAttachments = attachmentsForMessage.filter { $0.uploadState.isFailed || $0.remoteURL == nil }
                    guard failedAttachments.isEmpty else {
                        print("⚠️ Upload failed for attachments: \(failedAttachments.map { $0.filename })")
                        attachmentService.lastError = attachmentService.lastError ?? "Failed to upload attachments."
                        inputText = messageText
                        return
                    }
                }

                inputText = ""
                isInputFocused = false

                let finalizedAttachments = attachmentsForMessage.filter { $0.remoteURL != nil }
                try await service.sendMessage(messageText, attachments: finalizedAttachments)
                attachmentService.clearAllAttachments()
            } catch {
                print("❌ Failed to send message: \(error)")
                inputText = messageText
            }
        }
    }

    private func sendQuickAction(_ message: String) {
        guard let service = activeService else { return }

        Task { @MainActor in
            do {
                try await service.sendMessage(message, attachments: [])
            } catch {
                print("❌ Failed to send quick action: \(error)")
            }
        }
    }

    // TODO: Re-enable when VoiceManager is added to BuilderOS target
    // private func startVoiceInput() {
    //     // Voice input implementation
    // }

    // MARK: - Attachment Picker Methods

    private func presentPhotoPicker() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("⚠️ Could not find root view controller")
            return
        }

        attachmentService.presentPhotoPicker(from: rootViewController)
    }

    private func presentDocumentPicker() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("⚠️ Could not find root view controller")
            return
        }

        attachmentService.presentDocumentPicker(from: rootViewController)
    }
}

// MARK: - Message Bubble

struct MessageBubbleView: View {
    let message: ClaudeChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(message.isUser ? .terminalText : .terminalText)
                    .textSelection(.enabled)
                    .padding(12)
                    .background(
                        message.isUser
                            ? LinearGradient(
                                colors: [Color.terminalCyan.opacity(0.3), Color.terminalPink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.terminalInputBackground, Color.terminalInputBackground],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .terminalBorder(cornerRadius: 16, color: message.isUser ? .terminalCyan : .terminalInputBorder)

                if !message.attachments.isEmpty {
                    VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                        ForEach(message.attachments) { attachment in
                            MessageAttachmentRow(attachment: attachment, isUser: message.isUser)
                        }
                    }
                }

                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.terminalDim)
            }

            if !message.isUser {
                Spacer()
            }
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Loading Indicator

struct LoadingIndicatorView: View {
    let providerName: String
    let accentColor: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
            Text("\(providerName) is thinking...")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminalDim)
        }
        .padding(12)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 16)
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Quick Action Chip

struct QuickActionChip: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.terminalCyan)
                Text(text)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.terminalText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.terminalInputBackground)
            .terminalBorder(cornerRadius: 16)
        }
        .pressableButton()
    }
}

// MARK: - Preview

#Preview {
    ClaudeChatView(selectedTab: .constant(1))
}
