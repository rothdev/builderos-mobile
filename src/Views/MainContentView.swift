//
//  MainContentView.swift
//  BuilderOS
//
//  Main tab-based navigation with Dashboard, Terminal, Preview, and Settings
//

import SwiftUI
import Inject

struct MainContentView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @ObserveInjection var inject
    @State private var selectedTab: Int = 1  // Start on Chat tab for testing

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(apiClient)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }
                .tag(0)

            // Chat Terminal - Always uses Claude Agent SDK
            ClaudeChatView(selectedTab: $selectedTab)
                .tabItem { Label("Chat", systemImage: "message.fill") }
                .tag(1)

            LocalhostPreviewView()
                .environmentObject(apiClient)
                .tabItem { Label("Preview", systemImage: "globe") }
                .tag(2)

            SettingsView()
                .environmentObject(apiClient)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .background(Color.terminalDark.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .enableInjection()
    }
}

#Preview {
    MainContentView()
        .environmentObject(BuilderOSAPIClient.mockWithData())
}

#Preview {
    MainContentView()
        .environmentObject(BuilderOSAPIClient.mockWithData())
}

