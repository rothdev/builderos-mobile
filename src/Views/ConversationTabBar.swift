//
//  ConversationTabBar.swift
//  BuilderOS
//
//  Custom tab bar for multi-tab conversation interface
//

import SwiftUI
import Inject

struct ConversationTabBar: View {
    @Binding var tabs: [ConversationTab]
    @Binding var selectedTabId: UUID
    let isConnected: Bool
    let accentColor: Color
    let onAddTab: (ConversationTab.ChatProvider) -> Void
    let onCloseTab: (UUID) -> Void
    let maxTabs: Int
    @ObserveInjection var inject

    var body: some View {
        HStack(spacing: 0) {
            // Connection status indicator (minimal dot)
            Circle()
                .fill(isConnected ? accentColor : .statusError)
                .frame(width: 8, height: 8)
                .padding(.leading, 12)
                .padding(.trailing, 8)

            // Tab buttons with plus icon inline (browser-style)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(tabs) { tab in
                        ConversationTabButton(
                            tab: tab,
                            isSelected: tab.id == selectedTabId,
                            onTap: { selectedTabId = tab.id },
                            onClose: { onCloseTab(tab.id) },
                            canClose: tabs.count > 1
                        )
                    }

                    // Plus icon menu right next to tabs (browser-style)
                    if tabs.count < maxTabs {
                        Menu {
                            Button {
                                onAddTab(.claude)
                            } label: {
                                Label {
                                    Text("New Claude Chat")
                                } icon: {
                                    Image("claude-logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                }
                            }
                            Button {
                                onAddTab(.codex)
                            } label: {
                                Label {
                                    Text("New Codex Chat")
                                } icon: {
                                    Image("openai-logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 36, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 8)
            }

            Spacer()
        }
        .background(Color.black.opacity(0.4))
        .frame(height: 36)
        .enableInjection()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var tabs = [
            ConversationTab(provider: .claude),
            ConversationTab(provider: .codex)
        ]
        @State private var selectedTabId: UUID

        init() {
            let initialTab = ConversationTab(provider: .claude)
            _tabs = State(initialValue: [initialTab, ConversationTab(provider: .codex)])
            _selectedTabId = State(initialValue: initialTab.id)
        }

        var body: some View {
            ConversationTabBar(
                tabs: $tabs,
                selectedTabId: $selectedTabId,
                isConnected: true,
                accentColor: .cyan,
                onAddTab: { provider in
                    tabs.append(ConversationTab(provider: provider))
                },
                onCloseTab: { id in
                    if let index = tabs.firstIndex(where: { $0.id == id }) {
                        tabs.remove(at: index)
                    }
                },
                maxTabs: 5
            )
            .background(Color.black)
        }
    }

    return PreviewWrapper()
}
