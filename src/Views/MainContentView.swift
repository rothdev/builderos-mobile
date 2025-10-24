//
//  MainContentView.swift
//  BuilderOS
//
//  Main tab-based navigation with Dashboard, Chat, Preview, and Settings
//

import SwiftUI
import Inject

struct MainContentView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @ObserveInjection var inject

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }

            TerminalChatView()
                .tabItem {
                    Label("Terminal", systemImage: "terminal.fill")
                }

            LocalhostPreviewView()
                .tabItem {
                    Label("Preview", systemImage: "globe")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .enableInjection()
    }
}

#Preview {
    MainContentView()
        .environmentObject(BuilderOSAPIClient.mockWithData())
}
