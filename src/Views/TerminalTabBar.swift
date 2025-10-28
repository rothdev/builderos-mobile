//
//  TerminalTabBar.swift
//  BuilderOS
//
//  Custom tab bar for multi-tab terminal interface (iTerm2-style)
//

import SwiftUI
import Inject

struct TerminalTabBar: View {
    @Binding var tabs: [TerminalTab]
    @Binding var selectedTabId: UUID
    let onAddTab: (TerminalProfile) -> Void
    let onCloseTab: (UUID) -> Void
    let maxTabs: Int
    @ObserveInjection var inject

    var body: some View{
        HStack(spacing: 0) {
            // Tab buttons
            ForEach(tabs) { tab in
                TerminalTabButton(
                    tab: tab,
                    isSelected: tab.id == selectedTabId,
                    onTap: { selectedTabId = tab.id },
                    onClose: { onCloseTab(tab.id) },
                    canClose: tabs.count > 1
                )
            }

            Spacer()

            // Add tab button (if not at max)
            if tabs.count < maxTabs {
                Menu {
                    Button("New Shell Tab") {
                        onAddTab(.shell)
                    }
                    Button("New Jarvis Tab") {
                        onAddTab(.claude)
                    }
                    Button("New Codex Tab") {
                        onAddTab(.codex)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 40, height: 36)
                }
            }
        }
        .background(Color.black.opacity(0.4))
        .frame(height: 36)
        .enableInjection()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var tabs = [
            TerminalTab(profile: .shell),
            TerminalTab(profile: .claude)
        ]
        @State private var selectedTabId: UUID

        init() {
            let initialTab = TerminalTab(profile: .shell)
            _tabs = State(initialValue: [initialTab, TerminalTab(profile: .claude)])
            _selectedTabId = State(initialValue: initialTab.id)
        }

        var body: some View {
            TerminalTabBar(
                tabs: $tabs,
                selectedTabId: $selectedTabId,
                onAddTab: { profile in
                    tabs.append(TerminalTab(profile: profile))
                },
                onCloseTab: { id in
                    if let index = tabs.firstIndex(where: { $0.id == id }) {
                        tabs.remove(at: index)
                    }
                },
                maxTabs: 3
            )
            .background(Color.black)
        }
    }

    return PreviewWrapper()
}
