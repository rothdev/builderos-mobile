//
//  MultiTabTerminalView.swift
//  BuilderOS
//
//  Multi-tab terminal container (iTerm2-style)
//

import SwiftUI

struct MultiTabTerminalView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @State private var tabs: [TerminalTab] = [TerminalTab(profile: .shell)]
    @State private var selectedTabId: UUID

    init() {
        // Initialize with first tab selected
        let initialTab = TerminalTab(profile: .shell)
        _tabs = State(initialValue: [initialTab])
        _selectedTabId = State(initialValue: initialTab.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar at top
            TerminalTabBar(
                tabs: $tabs,
                selectedTabId: $selectedTabId,
                onAddTab: addTab,
                onCloseTab: closeTab,
                maxTabs: 3
            )

            // Tab content - each tab is its own terminal session
            TabView(selection: $selectedTabId) {
                ForEach(tabs) { tab in
                    WebSocketTerminalView(
                        baseURL: apiClient.tunnelURL,
                        apiKey: apiClient.apiKey,
                        profile: tab.profile
                    )
                    .tag(tab.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }

    // MARK: - Tab Management

    private func addTab(_ profile: TerminalProfile) {
        guard tabs.count < 3 else { return }
        let newTab = TerminalTab(profile: profile)
        tabs.append(newTab)
        selectedTabId = newTab.id
    }

    private func closeTab(_ tabId: UUID) {
        guard tabs.count > 1 else { return }  // Can't close last tab

        if let index = tabs.firstIndex(where: { $0.id == tabId }) {
            tabs.remove(at: index)

            // Select adjacent tab
            if selectedTabId == tabId {
                let newIndex = min(index, tabs.count - 1)
                selectedTabId = tabs[newIndex].id
            }
        }
    }
}

#Preview {
    MultiTabTerminalView()
        .environmentObject(BuilderOSAPIClient())
}
