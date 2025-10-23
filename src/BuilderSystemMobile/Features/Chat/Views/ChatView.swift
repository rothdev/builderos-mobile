import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var voiceManager = VoiceManager()
    @State private var showingQuickActions = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with connection status
            ChatHeaderView()
            
            // Messages list
            ChatMessagesView()
                .environmentObject(chatViewModel)
            
            // Input area
            VoiceInputView()
                .environmentObject(voiceManager)
                .environmentObject(chatViewModel)
        }
        .background(Color.adaptiveBackground)
        .sheet(isPresented: $showingQuickActions) {
            QuickActionsView()
                .environmentObject(chatViewModel)
        }
        .onAppear {
            voiceManager.checkPermissions()
        }
    }
}