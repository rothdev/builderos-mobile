//
//  MainContentView.swift
//  BuilderSystemMobile
//
//  Main app content after onboarding
//

import SwiftUI
import Inject

struct MainContentView: View {
    @ObserveInjection var inject
    @EnvironmentObject var apiClient: BuilderOSAPIClient

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            CapsulesListView()
                .tabItem {
                    Label("Capsules", systemImage: "cube.box.fill")
                }

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }

            TerminalTabView()
                .tabItem {
                    Label("Terminal", systemImage: "terminal.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .enableInjection()
    }
}

// MARK: - Terminal Tab Wrapper

struct TerminalTabView: View {
    @ObserveInjection var inject
    @EnvironmentObject var apiClient: BuilderOSAPIClient

    var body: some View {
        NavigationStack {
            if apiClient.tunnelURL.isEmpty || apiClient.apiKey.isEmpty {
                // Not configured yet
                ContentUnavailableView(
                    "Terminal Not Configured",
                    systemImage: "terminal",
                    description: Text("Configure your tunnel URL and API key in Settings to use the terminal.")
                )
            } else {
                // Multi-tab terminal interface
                MultiTabTerminalView()
                    .navigationTitle("Terminal")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .enableInjection()
    }
}

// MARK: - Chat View Placeholder

struct ChatView: View {
    @ObserveInjection var inject

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Chat Coming Soon",
                systemImage: "message",
                description: Text("Chat interface will be available in a future update.")
            )
            .navigationTitle("Chat")
        }
        .enableInjection()
    }
}

// Simple Dashboard View
struct DashboardView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status Card
                    HStack {
                        Image(systemName: apiClient.isConnected ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(apiClient.isConnected ? .green : .orange)
                            .font(.title2)

                        VStack(alignment: .leading) {
                            Text(apiClient.isConnected ? "Connected" : "Disconnected")
                                .font(.headline)
                            Text(apiClient.tunnelURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("BuilderOS")
        }
    }
}

// Simple Capsules List
struct CapsulesListView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @State private var capsules: [Capsule] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                } else if capsules.isEmpty {
                    ContentUnavailableView(
                        "No Capsules",
                        systemImage: "cube.box",
                        description: Text("Connect to your Mac to view capsules")
                    )
                } else {
                    ForEach(capsules) { capsule in
                        VStack(alignment: .leading) {
                            Text(capsule.title)
                                .font(.headline)
                            Text(capsule.purpose)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Capsules")
            .task {
                await loadCapsules()
            }
        }
    }

    private func loadCapsules() async {
        isLoading = true
        do {
            capsules = try await apiClient.listCapsules()
        } catch {
            print("Error loading capsules: \(error)")
        }
        isLoading = false
    }
}

// Simple Settings View
struct SettingsView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Connection") {
                    LabeledContent("Tunnel URL") {
                        Text(apiClient.tunnelURL)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    LabeledContent("Status") {
                        HStack {
                            Circle()
                                .fill(apiClient.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(apiClient.isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                        }
                    }
                }

                Section("System") {
                    Button("Sleep Mac") {
                        Task {
                            try? await apiClient.sleepMac()
                        }
                    }
                    .foregroundStyle(.orange)

                    Button("Reset Onboarding") {
                        hasCompletedOnboarding = false
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    MainContentView()
        .environmentObject(BuilderOSAPIClient())
}
