//
//  MultiTabTerminalView.swift
//  BuilderOS
//
//  Multi-tab PTY terminal container that powers the main terminal experience.
//

import SwiftUI
import Inject

struct MultiTabTerminalView: View {
    @Binding var selectedRootTab: Int
    @ObserveInjection var inject

    @State private var tabs: [TerminalTab]
    @State private var sessions: [UUID: PTYTerminalManager]
    @State private var selectedTabId: UUID

    init(selectedTab: Binding<Int>) {
        _selectedRootTab = selectedTab
        let initialTab = TerminalTab(profile: .claude)  // Start with Claude Code tab
        _tabs = State(initialValue: [initialTab])
        _sessions = State(initialValue: [initialTab.id: PTYTerminalManager()])
        _selectedTabId = State(initialValue: initialTab.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            TerminalTabBar(
                tabs: $tabs,
                selectedTabId: $selectedTabId,
                onAddTab: addTab,
                onCloseTab: closeTab,
                maxTabs: 3
            )

            TabView(selection: $selectedTabId) {
                ForEach(tabs) { tab in
                    if let manager = sessions[tab.id] {
                        PTYTerminalSessionView(
                            manager: manager,
                            profile: tab.profile,
                            onHeaderTap: { selectedRootTab = 0 }
                        )
                        .tag(tab.id)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .enableInjection()
    }

    private func addTab(_ profile: TerminalProfile) {
        guard tabs.count < 3 else { return }
        let newTab = TerminalTab(profile: profile)
        tabs.append(newTab)
        sessions[newTab.id] = PTYTerminalManager()
        selectedTabId = newTab.id
    }

    private func closeTab(_ tabId: UUID) {
        guard tabs.count > 1 else { return }

        if let index = tabs.firstIndex(where: { $0.id == tabId }) {
            tabs.remove(at: index)
            if let manager = sessions.removeValue(forKey: tabId) {
                manager.disconnect()
            }

            if selectedTabId == tabId {
                let newIndex = min(index, tabs.count - 1)
                selectedTabId = tabs[newIndex].id
            }
        }
    }
}

#Preview {
    MultiTabTerminalView(selectedTab: .constant(1))
}
